{ pkgs, lib, config, ... }:
let
  configDir = "/var/lib/mihomo";
  configFile = "${configDir}/config.yaml";
  apiAddr = "127.0.0.1:9090";

  # 1. 订阅管理脚本 (移除 sudo, 增加即时 API 触发)
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
external-controller: 0.0.0.0:9090
secret: ""

dns:
  enable: true
  enhanced-mode: fake-ip
  nameserver: [114.114.114.114, 8.8.8.8]

proxy-providers:
  subscription:
    type: http
    url: "$SUB_URL"
    interval: 0
    path: ./subscription.yaml
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 60

proxy-groups:
  - name: "Proxy"
    type: select
    use: [subscription]
  - name: "Auto"
    type: url-test
    use: [subscription]
    url: "http://www.gstatic.com/generate_204"
    interval: 300

rules:
  - GEOIP,CN,DIRECT
  - MATCH,Proxy
EOF
    systemctl restart mihomo
    
    # 核心：通过 API 强制触发一次提供者更新，确保节点立刻刷新
    sleep 2
    curl -X PUT "http://${apiAddr}/providers/proxies/subscription"
    ${pkgs.libnotify}/bin/notify-send "󱚽 Mihomo" "配置已重载，正在强制拉取节点..."
  '';

  # 2. Rofi 交互脚本 (增加延迟显示)
  mihomo-rofi = pkgs.writeShellScriptBin "mihomo-rofi" ''
    MENU="󰄭 切换节点\n󰚰 手动更新订阅\n󰏔 导入新链接\n󰜉 重启服务"
    CHOICE=$(echo -e "$MENU" | ${pkgs.rofi}/bin/rofi -dmenu -p "󱚽 Mihomo" -i)

    case "$CHOICE" in
      "󰄭 切换节点")
        # 获取节点及其延迟信息
        DATA=$(curl -s "http://${apiAddr}/proxies/Proxy")
        # 使用 jq 格式化输出为: "[延迟ms] 节点名"
        LIST=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r '.all[] as $name | .proxies[$name] | "[\((.history[-1].delay // "N/A"))ms] \($name)"')
        
        SELECTED=$(echo "$LIST" | ${pkgs.rofi}/bin/rofi -dmenu -p "󱚽 选择节点" -i)
        
        if [ ! -z "$SELECTED" ]; then
          # 提取原始节点名（过滤掉前面的延迟标识）
          NODE_NAME=$(echo "$SELECTED" | sed 's/^\[.*\] //')
          curl -X PUT -d "{\"name\":\"$NODE_NAME\"}" "http://${apiAddr}/proxies/Proxy"
          ${pkgs.libnotify}/bin/notify-send "󱚽 Mihomo" "已切换: $NODE_NAME"
        fi
        ;;
      "󰚰 手动更新订阅")
        ${mihomo-sub}/bin/mihomo-sub
        ;;
      "󰏔 导入新链接")
        LINK=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu -p "󰏔 粘贴订阅链接")
        if [ ! -z "$LINK" ]; then
          ${mihomo-sub}/bin/mihomo-sub "$LINK"
        fi
        ;;
      "󰜉 重启服务")
        systemctl restart mihomo
        ;;
    esac
  '';

  # 3. 监控脚本
  mihomo-monitor = pkgs.writeShellScriptBin "mihomo-monitor" ''
    PREV_STATE="ok"
    while true; do
      DELAY=$(curl -s "http://${apiAddr}/proxies/Proxy" | ${pkgs.jq}/bin/jq '.history[-1].delay' 2>/dev/null)
      if [ "$DELAY" = "0" ] || [ -z "$DELAY" ] || [ "$DELAY" = "null" ]; then
        if [ "$PREV_STATE" = "ok" ]; then
          ${pkgs.libnotify}/bin/notify-send -u critical "󰀦 Mihomo 警告" "当前节点连接超时，请检查网络或切换节点！"
          PREV_STATE="fail"
        fi
      else
        PREV_STATE="ok"
      fi
      sleep 30
    done
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

  systemd.user.services.mihomo-monitor = {
    description = "Mihomo Node Monitor";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${mihomo-monitor}/bin/mihomo-monitor";
  };

  environment.systemPackages = [
    mihomo-sub
    mihomo-rofi
    pkgs.metacubexd
    pkgs.jq
  ];
}
