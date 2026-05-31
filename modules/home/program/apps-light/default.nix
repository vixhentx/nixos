{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.apps-light;

  # Desktop file names: minimal explicit mapping for KDE reverse-domain + special cases.
  # Simple non-KDE apps follow <pname>.desktop; these are the ones that don't.
  desktop = {
    dolphin  = "org.kde.dolphin.desktop";
    gwenview = "org.kde.gwenview.desktop";
    haruna   = "org.kde.haruna.desktop";
    okular   = "org.kde.okular.desktop";
    ark      = "org.kde.ark.desktop";
    nvim     = "nvim.desktop";          # neovim pname ≠ desktop name
  };

  # Konsole profile: terminal area font (colors come from Stylix Qt theming)
  # Lives here because Konsole is installed by this module.
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
  options.vix.program.apps-light = {
    enable = lib.mkEnableOption "Lightweight desktop applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Chat
      element-desktop
      qq
      wechat
      feishu
      telegram-desktop

      # Internet
      localsend
      motrix-next

      # Media
      haruna
      mpv
      netease-cloud-music-gtk
      kdePackages.elisa
      kdePackages.gwenview
      ffmpeg
      alsa-utils
      pamixer

      # KDE utilities
      kdePackages.kde-cli-tools
      kdePackages.kcmutils
      kdePackages.dolphin-plugins
      kdePackages.kio-extras
      kdePackages.kservice
      kdePackages.ark
      kdePackages.okular
      kdePackages.filelight
      kdePackages.konsole
      desktop-file-utils
      shared-mime-info
      xdg-user-dirs
      xdg-utils

      # System
      mission-center
      wl-color-picker
    ];

    catppuccin.element-desktop.enable = true;

    # Konsole: profile with terminal font, colors from Stylix
    xdg = {
      configFile."konsolerc".text = konsoleRc;
      dataFile."konsole/${konsoleProfileName}.profile".text = konsoleProfile;
    };

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = [ desktop.dolphin ];
      "application/x-directory" = [ desktop.dolphin ];
      "x-scheme-handler/file" = [ desktop.dolphin ];

      "application/pdf" = [ desktop.okular ];

      "image/avif" = [ desktop.gwenview ];
      "image/gif" = [ desktop.gwenview ];
      "image/jpeg" = [ desktop.gwenview ];
      "image/png" = [ desktop.gwenview ];
      "image/webp" = [ desktop.gwenview ];

      "video/mp4" = [ desktop.haruna ];
      "video/x-matroska" = [ desktop.haruna ];
      "video/x-msvideo" = [ desktop.haruna ];

      "application/7z-compressed" = [ desktop.ark ];
      "application/gzip" = [ desktop.ark ];
      "application/vnd.rar" = [ desktop.ark ];
      "application/x-7z-compressed" = [ desktop.ark ];
      "application/x-compressed-tar" = [ desktop.ark ];
      "application/x-rar-compressed" = [ desktop.ark ];
      "application/x-tar" = [ desktop.ark ];
      "application/zip" = [ desktop.ark ];

      "text/plain" = [ desktop.nvim ];
      "text/markdown" = [ desktop.nvim ];
      "text/x-shellscript" = [ desktop.nvim ];
      "text/x-python" = [ desktop.nvim ];
      "text/x-csrc" = [ desktop.nvim ];
      "text/x-chdr" = [ desktop.nvim ];
      "text/x-c++src" = [ desktop.nvim ];
      "text/x-c++hdr" = [ desktop.nvim ];
      "text/css" = [ desktop.nvim ];
      "text/javascript" = [ desktop.nvim ];
      "text/xml" = [ desktop.nvim ];
      "application/json" = [ desktop.nvim ];
      "application/xml" = [ desktop.nvim ];
      "application/javascript" = [ desktop.nvim ];
      "application/x-javascript" = [ desktop.nvim ];
      "application/x-php" = [ desktop.nvim ];
      "application/x-perl" = [ desktop.nvim ];
      "application/x-ruby" = [ desktop.nvim ];
      "application/x-shellscript" = [ desktop.nvim ];
      "application/x-yaml" = [ desktop.nvim ];
      "application/x-toml" = [ desktop.nvim ];
      "application/x-nix" = [ desktop.nvim ];
      "application/x-wine-extension-ini" = [ desktop.nvim ];
      "application/x-wine-extension-txt" = [ desktop.nvim ];
    };
  };
}
