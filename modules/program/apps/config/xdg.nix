{ config, ... }:
let
  homeDir = config.home.homeDirectory;
  browser = "firefox.desktop";
  fileManager = "org.kde.dolphin.desktop";
  imageViewer = "org.kde.gwenview.desktop";
  mediaPlayer = "org.kde.haruna.desktop";
  pdfViewer = "org.kde.okular.desktop";
  archiveManager = "org.kde.ark.desktop";
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
  };
}
