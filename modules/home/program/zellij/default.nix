{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.zellij;
in
{
  options.vix.program.zellij = {
    enable = lib.mkEnableOption "Enable the zellij";
  };
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      plugins = (with pkgs.zellijPlugins; [
        jbz
        vim-zellij-navigator
        zjstatus
      ]);
      settings = {
        "show_startup_tips" = false;
      };
    };
  };
}