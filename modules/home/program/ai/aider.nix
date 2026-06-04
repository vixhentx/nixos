{ config, lib, pkgs, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.aider.enable) {
    programs.aider-chat = {
      enable = true;
    };
  };
}
