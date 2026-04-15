{ config, pkgs, lib, ... }:
let
  categories = [
    "internet"
    "dev"
    "chat"
    "media"
    "work"
    "utils"
  ];

  homeDir = config.home.homeDirectory;
  browser = "microsoft-edge.desktop";
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
  };
  mkMimeSection = apps:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (mime: desktopFiles:
        "${mime}=${lib.concatStringsSep ";" desktopFiles}"
      ) apps
    );
  defaultMimeAppsFile = pkgs.writeText "default-mimeapps.list" ''
    [Added Associations]
    ${mkMimeSection defaultMimeApps}

    [Default Applications]
    ${mkMimeSection defaultMimeApps}

    [Removed Associations]
  '';
in
{
  home.packages = lib.flatten (map (name: import ./${name}.nix { inherit pkgs; }) categories);

  xdg = {
    enable = true;
    cacheHome = "${homeDir}/.cache";
    configHome = "${homeDir}/.config";
    dataHome = "${homeDir}/.local/share";
    stateHome = "${homeDir}/.local/state";

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
        SCREENSHOTS = "${homeDir}/Pictures/Screenshots";
      };
    };
  };

  xdg.configFile."user-dirs.dirs".force = true;

  home.activation.createXdgExtraDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${homeDir}/Pictures/Screenshots" "${homeDir}/Videos/Recordings"
  '';

  home.activation.seedMutableMimeApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    seed_mimeapps() {
      local mimeapps="$1"
      if [ -L "$mimeapps" ]; then
        case "$(readlink "$mimeapps")" in
          /nix/store/*)
            run rm "$mimeapps"
            ;;
        esac
      fi
      if [ ! -e "$mimeapps" ]; then
        run mkdir -p "$(dirname "$mimeapps")"
        run install -m 0644 "${defaultMimeAppsFile}" "$mimeapps"
      fi
    }

    seed_mimeapps "${config.xdg.configHome}/mimeapps.list"
    seed_mimeapps "${config.xdg.dataHome}/applications/mimeapps.list"
  '';
}
