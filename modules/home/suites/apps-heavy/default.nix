{ config, lib, ... }:

let
  cfg = config.vix.suites.apps-heavy;
in
{
  options.vix.suites.apps-heavy = {
    enable = lib.mkEnableOption "Professional/heavy applications suite (user level)";
  };

  config = lib.mkIf cfg.enable {
    vix.program.blender.enable = true;
    vix.program.kicad.enable = true;
    vix.program.libreoffice.enable = true;
    vix.program.apps-heavy.enable = true;

    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
