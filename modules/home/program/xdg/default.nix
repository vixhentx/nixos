{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.xdg;
  homeDir = config.home.homeDirectory;
in
{
  options.vix.program.xdg = {
    enable = lib.mkEnableOption "XDG base directories, MIME associations, and KDE config";

    # Required: set by the module that provides the terminal (e.g. desktop suite)
    terminal = {
      application = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Default terminal binary name (e.g. 'kitty')";
      };
      desktopFile = lib.mkOption {
        type = lib.types.nonEmptyStr;
        description = "Desktop file for the default terminal (e.g. 'kitty.desktop')";
      };
    };
  };

  config = lib.mkIf cfg.enable {
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

      mimeApps.enable = true;
    };

    home.activation.rebuildKdeSycoca = ''
      rm -f "${config.xdg.cacheHome}"/ksycoca*
      $DRY_RUN_CMD ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
    '';
    
    home.packages = with pkgs;[
      desktop-file-utils
      shared-mime-info
      xdg-user-dirs
      xdg-utils
    ];
  };
}
