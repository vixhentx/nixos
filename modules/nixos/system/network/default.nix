{ config, lib, ... }:
let
  cfg = config.vix.system.network;
in
{
  options.vix.system.network = {
    enable = lib.mkEnableOption "System network configuration";
    backend = lib.mkOption {
      type = lib.types.enum [ "networkmanager" "networkd" ];
      default = "networkmanager";
      description = "Network configuration backend for this host";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      networking.nftables.enable = true;
    })
    (lib.mkIf (cfg.enable && cfg.backend == "networkmanager") {
      networking.networkmanager.enable = true;
      networking.useDHCP = false;
      networking.dhcpcd.enable = false;
    })
    (lib.mkIf (cfg.enable && cfg.backend == "networkd") {
      networking.networkmanager.enable = false;
      networking.useNetworkd = true;
      networking.useDHCP = true;
      networking.dhcpcd.enable = false;
    })
  ];
}
