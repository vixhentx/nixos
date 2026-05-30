{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.desktop;
in
{
  options.vix.suites.desktop = {
    enable = lib.mkEnableOption "Generic user-level desktop tools";
  };

  config = lib.mkIf cfg.enable {
    # 任何桌面都会用到的 GUI 应用
    home.packages = with pkgs; [
      kitty
      kdePackages.dolphin
      kdePackages.spectacle
      gsimplecal
      pavucontrol
      playerctl
    ];
  };
}