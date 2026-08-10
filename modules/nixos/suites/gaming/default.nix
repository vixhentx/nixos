
{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.gaming;
in
{
  options.vix.suites.gaming = {
    enable = lib.mkEnableOption "Gaming basics";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # VR Related
    services.wivrn = {
      enable = true;
      openFirewall = true;
    };
  };
}
