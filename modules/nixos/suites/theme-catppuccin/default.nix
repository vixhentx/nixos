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
    enable = lib.mkEnableOption "Catppuccin theme suite (Stylix + catppuccin/nix)";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      image = wallpaper;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      targets = {
        plymouth.enable = false;
      };
    };

    catppuccin = {
      enable = true;
      autoEnable = false;
      flavor = "mocha";
      accent = "lavender";
      sddm.enable = true;
      plymouth.enable = true;
    };
  };
}
