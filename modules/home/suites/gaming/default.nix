{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.gaming;
in
{
  options.vix.suites.gaming = {
    enable = lib.mkEnableOption "Gaming items";
  };

  config = lib.mkIf cfg.enable {
    # Minecraft Launcher
    programs.prismlauncher.enable = true;
  };
}
