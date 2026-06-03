{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.apps-heavy;
in
{
  options.vix.program.apps-heavy = {
    enable = lib.mkEnableOption "Professional/heavy desktop applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.kdenlive
      krita
      inkscape-with-extensions
      zotero
      # bottles # TODO: 上游有bug, 暂时关闭
    ];
  };
}
