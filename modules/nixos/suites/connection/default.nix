{ pkgs, config, lib, ... }:
let
  cfg = config.vix.suites.connection;
in
{
  options.vix.suites.connection = {
    enable = lib.mkEnableOption "Enable the connection utilities";
  };
  config = lib.mkIf cfg.enable {
    programs.kdeconnect = {
      enable = true;
      # package 可以被覆盖, 默认是kde, gnome以后再说
    };
    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--accept-dns=false" ];
      # TODO: 自动auth key
    };
    networking.firewall = {
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
    systemd.services.tailscaled.serviceConfig.Environment = [ 
      "TS_DEBUG_FIREWALL_MODE=nftables" 
    ];
  };
}