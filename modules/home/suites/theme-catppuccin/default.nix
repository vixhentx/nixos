{ config, lib, ... }:

let
  cfg = config.vix.suites.theme-catppuccin;
in
{
  options.vix.suites.theme-catppuccin = {
    enable = lib.mkEnableOption "Catppuccin home theme suite";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
    };
    catppuccin = {
      enable = true;
      autoEnable = false;
      flavor = "mocha";
      accent = "lavender";
      hyprland.enable = true;
    };
  };
}
