{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.apps-heavy;
in
{
  options.vix.suites.apps-heavy = {
    enable = lib.mkEnableOption "Professional/heavy applications suite (home level)";
  };

  config = lib.mkIf cfg.enable {
    vix.program.blender.enable = true;
    vix.program.kicad.enable = true;
    vix.program.libreoffice.enable = true;

    home.packages = with pkgs; [
      kdePackages.kdenlive
      krita
      inkscape-with-extensions
      zotero
      # bottles # TODO: 上游有bug, 暂时关闭
    ];
  };
}