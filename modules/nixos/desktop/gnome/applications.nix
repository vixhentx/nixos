{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.vix.desktop.gnome.enable {
    services.desktopManager.gnome.favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'firefox.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Music.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop' ]
    '';

    environment.gnome.excludePackages = with pkgs; [
      # Firefox and Kitty provide the browser and terminal.
      epiphany
      gnome-console

      # Optional help and accessibility applications.
      gnome-tour
      yelp
      gnome-user-docs
      gnome-tecla
      orca
    ];
  };
}
