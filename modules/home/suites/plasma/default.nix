{ config, lib, ... }:

let
  cfg = config.vix.suites.plasma;
in
{
  options.vix.suites.plasma = {
    enable = lib.mkEnableOption "KDE Plasma user scenario suite";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.plasma.enable = true;
    vix.program.fcitx.enable = true;

    # Plasma 默认终端
    vix.program.xdg.terminal = {
      application = "konsole";
      desktopFile = "org.kde.konsole.desktop";
    };
  };
}
