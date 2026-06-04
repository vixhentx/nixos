{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.theme-catppuccin;
in
{
  options.vix.suites.theme-catppuccin = {
    enable = lib.mkEnableOption "Catppuccin theme suite (Stylix + catppuccin/nix)";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      override.base0E = "#cba6f7";

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
