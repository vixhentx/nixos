{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.apps-kde;

  # Konsole profile: terminal font from Stylix, colors from Stylix Qt theming
  monospaceName = config.stylix.fonts.monospace.name;
  monospaceSize = config.stylix.fonts.sizes.desktop;
  terminalFont = "${monospaceName},${builtins.toString monospaceSize},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
  konsoleProfileName = "Stylix";

  konsoleProfile = lib.generators.toINI { } {
    Appearance.Font = terminalFont;
    General = {
      Name = konsoleProfileName;
      Parent = "FALLBACK/";
    };
  };
  konsoleRc = lib.generators.toINI { } {
    "Desktop Entry".DefaultProfile = "${konsoleProfileName}.profile";
    General.ConfigVersion = 1;
    UiSettings.ColorScheme = "";
  };
in
{
  options.vix.program.apps-kde = {
    enable = lib.mkEnableOption "KDE desktop applications (file manager, viewers, utilities)";
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
    ];

    # Konsole profile
    xdg = {
      configFile."konsolerc".text = konsoleRc;
      dataFile."konsole/${konsoleProfileName}.profile".text = konsoleProfile;
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
