{ config, lib, ... }:

let
  cfg = config.vix.suites.apps-light;
in
{
  options.vix.suites.apps-light = {
    enable = lib.mkEnableOption "Lightweight desktop suite (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
