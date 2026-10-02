{ config, lib, ... }:
let
  cfg = config.vix.suites.desktop-base;
in
{
  options.vix.suites.desktop-base.enable =
    lib.mkEnableOption "Base system configuration for desktop hosts";

  config = lib.mkIf cfg.enable {
    vix.system.boot.enable = true;
    vix.system.ssh.enable = true;
    vix.system.kmscon.enable = true;
    vix.system.performance.enable = true;

    vix.system.network = {
      enable = true;
      backend = "networkmanager";
    };
    vix.system.network.avahi.enable = true;
    vix.system.network.tuning.enable = true;
  };
}
