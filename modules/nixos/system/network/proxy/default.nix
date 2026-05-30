{ config, lib, pkgs, ... }:
let
  cfg = config.vix.system.network.proxy;
  
  # 打包 CLI 工具
  mihomo-ctl = pkgs.writers.writePython3Bin "mihomo-ctl" {
    libraries = [ pkgs.python3Packages.pyyaml ];
    flakeIgnore = [ "E501" "E265" ];
  } (builtins.readFile ./mihomo-ctl.py);

in {
  options.vix.system.network.proxy = {
    enable = lib.mkEnableOption "Mihomo Proxy Module (TUN mode)";
  };

  config = lib.mkIf cfg.enable {
    # 专用系统用户
    users.users.mihomo = {
      isSystemUser = true;
      group = "mihomo";
      description = "Mihomo proxy service user";
    };
    users.groups.mihomo = {};

    # 目录权限控制: 仅 root 和 mihomo, wheel 组可以通过 sudo/polkit 或直接加入组来读取 (按需)
    # 这里我们让 wheel 组也有读写权限方便手动调试，但核心是 mihomo 用户运行
    systemd.tmpfiles.rules = [
      "d /var/lib/mihomo 0770 mihomo wheel - -"
      "d /var/lib/mihomo/subs 0770 mihomo wheel - -"
      "d /var/lib/mihomo/proxies 0770 mihomo wheel - -"
    ];

    # 基础服务配置
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = "/var/lib/mihomo/config.yaml";
    };

    # 动态注入启动逻辑
    systemd.services.mihomo = {
      serviceConfig = {
        User = lib.mkForce "mihomo";
        Group = lib.mkForce "mihomo";
        
        # 权限加固与 TUN 支持
        AmbientCapabilities = lib.mkForce [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        CapabilityBoundingSet = lib.mkForce [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
        
        # 启动前生成配置
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/mkdir -p /var/lib/mihomo/subs /var/lib/mihomo/proxies"
          "+${pkgs.coreutils}/bin/chown -R mihomo:wheel /var/lib/mihomo"
          "${lib.getExe mihomo-ctl} generate"
        ];
      };
      # 确保在网络准备好后启动
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    environment.systemPackages = [
      mihomo-ctl
      pkgs.metacubexd
    ];

    # Polkit: 允许 wheel 组免密重启 mihomo 服务 (CLI update 内部可能需要)
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "mihomo.service" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
