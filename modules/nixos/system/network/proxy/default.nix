{ config, lib, ... }:
let
  cfg = config.vix.system.network.proxy;

in {
  options.vix.system.network.proxy = {
    enable = lib.mkEnableOption "Mihomo Proxy Module (TUN mode)";
  };

  config = lib.mkIf cfg.enable {
    programs.clash-verge = {
      enable = true;
      autoStart = true;
      group = "mihomo";
      tunMode = true;
      serviceMode = true;
    };
    users.groups.mihomo = {};
  };
}
