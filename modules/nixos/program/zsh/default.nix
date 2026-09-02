{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.zsh;
in
{
  options.vix.program.zsh = {
    enable = lib.mkEnableOption "System-level Zsh shell";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
