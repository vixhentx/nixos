{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.desktop;
in
{
  options.vix.suites.desktop = {
    enable = lib.mkEnableOption "Generic user-level desktop tools";
  };

  config = lib.mkIf cfg.enable {
    vix.program.xdg.enable = true;

    # DE-agnostic GUI tools
    home.packages = with pkgs; [
      playerctl
      gsimplecal
    ] ++ lib.optional (!config.vix.desktop.gnome.enable) pavucontrol;
  };
}
