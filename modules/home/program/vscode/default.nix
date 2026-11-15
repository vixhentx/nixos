{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.vscode;
  vscode-wrapped = pkgs.symlinkJoin {
    name = "vscode-wrapped-${pkgs.vscode-fhs.version}";
    paths = [ pkgs.vscode-fhs ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/code" \
        --set SHELL ${lib.getExe pkgs.zsh} \
        --set ZELLIJ 0
    '';
  };
in
{
  options.vix.program.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code (FHS variant)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ vscode-wrapped ];
  };
}
