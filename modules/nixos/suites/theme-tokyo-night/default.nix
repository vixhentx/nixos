{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.theme-tokyo-night;
in
{
  options.vix.suites.theme-tokyo-night = {
    enable = lib.mkEnableOption "Tokyo Night theme suite (Stylix)";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      polarity = "dark";
      image = config.lib.stylix.pixel "base00";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-storm.yaml";

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };
  };
}
