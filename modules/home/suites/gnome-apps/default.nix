{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.gnome-apps;
in
{
  options.vix.suites.gnome-apps = {
    enable = lib.mkEnableOption "GNOME application suite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      loupe
      showtime
      decibels
      papers
      file-roller
      baobab
      gnome-connections
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "image/*" = [ "org.gnome.Loupe.desktop" ];
      "video/*" = [ "org.gnome.Showtime.desktop" ];
      "audio/*" = [ "org.gnome.Decibels.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "application/*archive*" = [ "org.gnome.FileRoller.desktop" ];
      "application/*compressed*" = [ "org.gnome.FileRoller.desktop" ];
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
    };

    # kde connect
    services.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
  };
}
