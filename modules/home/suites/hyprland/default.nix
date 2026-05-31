{ config, lib, ... }:

let
  cfg = config.vix.suites.hyprland;
in
{
  options.vix.suites.hyprland = {
    enable = lib.mkEnableOption "Hyprland user scenario suite";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.hyprland.enable = true;
    vix.program.tomat.enable = true;
    vix.program.fcitx.enable = true;

    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
