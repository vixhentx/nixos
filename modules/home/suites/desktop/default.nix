{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.desktop;
  kittyBin = pkgs.kitty.meta.mainProgram or "kitty";
in
{
  options.vix.suites.desktop = {
    enable = lib.mkEnableOption "Generic user-level desktop tools";
  };

  config = lib.mkIf cfg.enable {
    # XDG base: desktop infrastructure, required by all DEs
    vix.program.xdg = {
      enable = true;
      terminal = {
        application = kittyBin;
        desktopFile = "${kittyBin}.desktop";
      };
    };

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
