{ config, lib, ... }:

let
  cfg = config.vix.suites.apps-heavy;
in
{
  options.vix.suites.apps-heavy = {
    enable = lib.mkEnableOption "Heavy/professional applications suite (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    vix.program.docker.enable = true;
    vix.program.wireshark.enable = true;

    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
