{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.theme-catppuccin;
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/harilvfs/wallpapers/main/catppuccin_page_curl.png";
    hash = "sha256-9dPFnDUm4igYcEtYvjlu1F/jbZueMmb6oO3BZ+NEy0w=";
  };
in
{
  options.vix.suites.theme-catppuccin = {
    enable = lib.mkEnableOption "Catppuccin home theme suite";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      image = wallpaper;
    };
    catppuccin = {
      enable = true;
      autoEnable = false;
      flavor = "mocha";
      accent = "lavender";
      cursors.enable = true;
      gtk.icon.enable = true;
      wlogout.enable = true;
    };
  };
}
