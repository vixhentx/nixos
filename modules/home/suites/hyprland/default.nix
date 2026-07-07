{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.hyprland;
  kittyBin = pkgs.kitty.meta.mainProgram or "kitty";
in
{
  options.vix.suites.hyprland = {
    enable = lib.mkEnableOption "Hyprland user scenario suite";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.hyprland.enable = true;
    vix.program.tomat.enable = true;
    vix.program.fcitx.enable = true;
    vix.suites.apps-kde.enable = true;

    # Hyprland's default terminal
    vix.program.xdg.terminal = {
      application = kittyBin;
      desktopFile = "${kittyBin}.desktop";
    };
    home.packages = [ pkgs.kitty ];
  };
}
