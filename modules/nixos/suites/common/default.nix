{ config, lib, ... }:
let
  cfg = config.vix.suites.common;
in
{
  options.vix.suites.common = {
    enable = lib.mkEnableOption "Common system-level configuration suite";
  };

  config = lib.mkIf cfg.enable {
    vix.program.zsh.enable = true;
    vix.system.font.enable = true;
    vix.system.kmscon.enable = true;
  };
}
