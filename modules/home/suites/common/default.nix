{ config, lib, ... }:
let
  cfg = config.vix.suites.common;
in
{
  options.vix.suites.common = {
    enable = lib.mkEnableOption "Common user-level configuration suite";
  };

  config = lib.mkIf cfg.enable {
    vix.program.zsh.enable = true;
    vix.program.cli.enable = true;
    vix.program.nvim.enable = true;
  };
}
