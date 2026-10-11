{ config, lib, ... }:
let
  cfg = config.vix.suites.connection;
in
{
  options.vix.suites.connection = {
    enable = lib.mkEnableOption "Enable the connection utilities";
  };
  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--accept-dns=false" ];
      # TODO: 自动auth key
    };
    networking.firewall =
    let
      kdeconnectPortRanges = { from = 1714; to = 1764; };
    in{
      trustedInterfaces = [
        config.services.tailscale.interfaceName
      ];
      allowedUDPPorts = [
        config.services.tailscale.port
      ];
      allowedUDPPortRanges = [
        kdeconnectPortRanges
      ];
      allowedTCPPortRanges = [
        kdeconnectPortRanges
      ];
    };
    systemd.services.tailscaled.serviceConfig.Environment = [ 
      "TS_DEBUG_FIREWALL_MODE=nftables" 
    ];
  };
}