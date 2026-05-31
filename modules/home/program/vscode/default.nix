{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.vscode;
in
{
  options.vix.program.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code (FHS variant)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.vscode-fhs ];
  };
}
