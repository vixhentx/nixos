{ pkgs, ... }:

{
  programs.hyprland.enable = true;
  programs.dconf.enable = true;

  # Dolphin's "Open With" integration depends on the XDG applications menu
  # being present even outside a full Plasma session.
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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
