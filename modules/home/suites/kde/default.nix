{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.kde;
in
{
  imports = [ ./mobile.nix ];

  options.vix.suites.kde = {
    enable = lib.mkEnableOption "KDE application suite (home level)";
    mobile = {
      enable = lib.mkEnableOption "Mobile (touchscreen) KDE apps";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.kdePackages; [
      # File manager
      dolphin
      dolphin-plugins

      # Screenshot
      spectacle

      # Media viewers
      gwenview    # images
      pkgs.haruna                   # video
      elisa        # music
      okular       # PDF
      ark          # archives
      filelight    # disk usage

      # Terminal (backup)
      konsole

      # KDE runtime
      kde-cli-tools
      kcmutils
      kio-extras
      kservice

      # Connnectivity
      kdeconnect-kde
      krdc
    ];

    # Konsole profile: 字体来自 Stylix, 其余走 plasma-manager 默认
    programs.konsole = {
      enable = true;
      defaultProfile = "Stylix";
      profiles.Stylix.font = {
        name = config.stylix.fonts.monospace.name;
        size = config.stylix.fonts.sizes.desktop;
      };
    };

    # MIME: KDE apps as defaults (native glob support)
    xdg.mimeApps.defaultApplications = {
      "inode/directory"       = [ "org.kde.dolphin.desktop" ];
      "image/*"               = [ "org.kde.gwenview.desktop" ];
      "video/*"               = [ "org.kde.haruna.desktop" ];
      "application/pdf"       = [ "org.kde.okular.desktop" ];
      "application/*archive*"    = [ "org.kde.ark.desktop" ];
      "application/*compressed*" = [ "org.kde.ark.desktop" ];
      "application/zip"       = [ "org.kde.ark.desktop" ];
      "application/gzip"      = [ "org.kde.ark.desktop" ];
    };
  };
}
