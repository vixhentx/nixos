{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.bitwarden;
in
{
  options.vix.program.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden desktop password manager";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bitwarden-desktop ];

    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/bitwarden" = [ "bitwarden.desktop" ];
    };
  };
}
