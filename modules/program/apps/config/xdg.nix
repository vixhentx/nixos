{ config, lib, pkgs, ... }:
let
  homeDir = config.home.homeDirectory;
  browser = "firefox.desktop";
  fileManager = "org.kde.dolphin.desktop";
  imageViewer = "org.kde.gwenview.desktop";
  mediaPlayer = "org.kde.haruna.desktop";
  pdfViewer = "org.kde.okular.desktop";
  archiveManager = "org.kde.ark.desktop";
  konsoleProfileName = "Kitty";
  terminalFont = "Sarasa Mono SC,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
  kdeGlobals = lib.generators.toINI { } {
    General = {
      TerminalApplication = "kitty";
      TerminalService = "kitty.desktop";
    };
  };
  konsoleProfile = lib.generators.toINI { } {
    Appearance = {
      Font = terminalFont;
    };
    General = {
      Name = konsoleProfileName;
      Parent = "FALLBACK/";
    };
  };
  konsoleRc = lib.generators.toINI { } {
    "Desktop Entry" = {
      DefaultProfile = "${konsoleProfileName}.profile";
    };
    General = {
      ConfigVersion = 1;
    };
    UiSettings = {
      ColorScheme = "";
    };
  };
  defaultMimeApps = {
    "inode/directory" = [ fileManager ];
    "application/x-directory" = [ fileManager ];
    "x-scheme-handler/file" = [ fileManager ];

    "x-scheme-handler/http" = [ browser ];
    "x-scheme-handler/https" = [ browser ];
    "text/html" = [ browser ];

    "application/pdf" = [ pdfViewer ];

    "image/avif" = [ imageViewer ];
    "image/gif" = [ imageViewer ];
    "image/jpeg" = [ imageViewer ];
    "image/png" = [ imageViewer ];
    "image/webp" = [ imageViewer ];

    "video/mp4" = [ mediaPlayer ];
    "video/x-matroska" = [ mediaPlayer ];
    "video/x-msvideo" = [ mediaPlayer ];

    "application/7z-compressed" = [ archiveManager ];
    "application/gzip" = [ archiveManager ];
    "application/vnd.rar" = [ archiveManager ];
    "application/x-7z-compressed" = [ archiveManager ];
    "application/x-compressed-tar" = [ archiveManager ];
    "application/x-rar-compressed" = [ archiveManager ];
    "application/x-tar" = [ archiveManager ];
    "application/zip" = [ archiveManager ];

    "x-scheme-handler/bitwarden" = [ "bitwarden.desktop" ];
  };
in
{
  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "${homeDir}/Desktop";
      documents = "${homeDir}/Documents";
      download = "${homeDir}/Downloads";
      music = "${homeDir}/Music";
      pictures = "${homeDir}/Pictures";
      publicShare = "${homeDir}/Public";
      templates = "${homeDir}/Templates";
      videos = "${homeDir}/Videos";
      extraConfig = {
        RECORDINGS = "${homeDir}/Videos/Recordings";
        SCREENSHOTS = "${homeDir}/Pictures/Screenshots";
      };
    };

    mimeApps = {
      enable = true;
      associations.added = defaultMimeApps;
      defaultApplications = defaultMimeApps;
    };

    configFile."kdeglobals".text = kdeGlobals;
    configFile."konsolerc".text = konsoleRc;
    dataFile."konsole/${konsoleProfileName}.profile".text = konsoleProfile;
  };

  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "${config.xdg.cacheHome}"/ksycoca*
    $DRY_RUN_CMD ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
  '';
}
