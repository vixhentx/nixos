{ pkgs, lib, config, ... }:
let
  configDir = "/var/lib/mihomo";
  configFile = "${configDir}/config.yaml";
  apiAddr = "127.0.0.1:9090";

  mihomo-sub = pkgs.writeShellScriptBin "mihomo-sub" ''
    if [ ! -z "$1" ]; then
      SUB_URL="$1"
      echo "$SUB_URL" > ${configDir}/sub_url.txt
    else
      if [ ! -f ${configDir}/sub_url.txt ]; then
        echo "󰇚 错误: 未找到已存储的订阅链接"
        exit 1
      fi
      SUB_URL=$(cat ${configDir}/sub_url.txt)
    fi

    cat > ${configFile} <<EOF
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info
ipv6: false
external-controller: 0.0.0.0:9090
secret: ""

# 性能优化
profile:
  store-selected: true
  store-fake-ip: true

unified-delay: true
tcp-fast-open: true

dns:
  enable: true
  prefer-h3: true
  ipv6: false
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
  fallback:
    - https://8.8.8.8/dns-query
    - https://1.1.1.1/dns-query
    - tls://8.8.4.4
  fallback-filter:
    geoip: true
    geoip-code: CN
    geosite:
      - gfw

tun:
  enable: true
  stack: gvisor
  auto-route: true
  auto-detect-interface: true
  dns-hijack:
    - any:53

proxy-providers:
  subscription:
    type: http
    url: "$SUB_URL"
    interval: 3600
    path: ./subscription.yaml
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300

proxy-groups:
  - name: "Proxy"
    type: select
    use: [subscription]
  - name: "Auto"
    type: url-test
    use: [subscription]
    url: "http://www.gstatic.com/generate_204"
    interval: 300
    tolerance: 50
  - name: "Nix-Speed"
    type: url-test
    use: [subscription]
    url: "https://cache.nixos.org"
    interval: 600
    tolerance: 50

rules:
  - DOMAIN-SUFFIX,nixos.org,Nix-Speed
  - DOMAIN-SUFFIX,cachix.org,Nix-Speed
  - GEOSITE,github,Proxy
  - GEOIP,CN,DIRECT
  - MATCH,Proxy
EOF
    systemctl restart mihomo
  '';

  # 2. Rofi 交互脚本 (增加延迟显示)
  mihomo-rofi = pkgs.writeShellScriptBin "mihomo-rofi" ''
    MENU="󰄭 切换节点\n󰚰 手动更新订阅\n󰏔 导入新链接\n󰜉 重启服务"
    CHOICE=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -p "󱚽 Mihomo" -i)

    case "$CHOICE" in
      "󰄭 切换节点")
        # 获取节点
        DATA=$(curl -s "http://${apiAddr}/proxies/Proxy")
        # 使用 jq 格式化输出为: "[延迟ms] 节点名"
        LIST=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r '.all[]')
        
        SELECTED=$(echo "$LIST" | ${pkgs.rofi}/bin/rofi -dmenu -p "󱚽 选择节点" -i)
        
        if [ ! -z "$SELECTED" ]; then
          NODE_NAME=$(echo "$SELECTED" | sed 's/^\[.*\] //')
          curl -X PUT -d "{\"name\":\"$NODE_NAME\"}" "http://${apiAddr}/proxies/Proxy"
          ${pkgs.libnotify}/bin/notify-send "󱚽 Mihomo" "已切换: $NODE_NAME"
        fi
        ;;
      "󰚰 手动更新订阅")
        pkexec ${mihomo-sub}/bin/mihomo-sub
        ;;
      "󰏔 导入新链接")
        LINK=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu -p "󰏔 粘贴订阅链接")
        if [ ! -z "$LINK" ]; then
          pkexec ${mihomo-sub}/bin/mihomo-sub "$LINK"
        fi
        ;;
      "󰜉 重启服务")
        systemctl restart mihomo
        ;;
    esac
  '';
in
{
  services.mihomo = {
    enable = true;
    tunMode = true;
    configFile = configFile;
    webui = pkgs.metacubexd;
  };

  systemd.services.mihomo = {
    serviceConfig = {
      ExecStart = lib.mkForce "${lib.getExe pkgs.mihomo} -d ${configDir} -f ${configFile}";
    };
  };

  # 权限设置：允许 wheel 组修改配置，且服务能读取
  systemd.tmpfiles.rules = [ 
    "d ${configDir} 0775 root wheel - -"
    "f ${configFile} 0664 root wheel - {}"
  ];

  # Polkit 规则：允许免密管理 mihomo 服务
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "mihomo.service" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = [
    mihomo-sub
    mihomo-rofi
    pkgs.metacubexd
    pkgs.jq
  ];
}
