
{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.gaming;
  displayCfg = config.vix.display;
in
{
  options.vix.suites.gaming = {
    enable = lib.mkEnableOption "Gaming basics";
    vr = lib.mkEnableOption "VR support";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          GDK_SCALE = toString displayCfg.xwaylandScale;
        };
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # VR Related
    services.wivrn = lib.mkIf cfg.vr {
      enable = true;
      openFirewall = true;
      steam.enable = true;
    };
  };
}
