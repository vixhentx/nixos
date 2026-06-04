{ config, lib, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.codex.enable) {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      context = cfg.sharedPrompt;
    };
  };
}
