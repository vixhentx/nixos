{ pkgs, ... }:

{
  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  services.dbus = {
    enable = true;
    packages = [ pkgs.kdePackages.dolphin ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "hyprland" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };
}
