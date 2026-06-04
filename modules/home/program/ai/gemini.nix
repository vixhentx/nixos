{ config, lib, ... }:
let
  cfg = config.vix.program.ai;
in
{
  config = lib.mkIf (cfg.enable && cfg.gemini.enable) {
    programs.gemini-cli = {
      enable = true;
      enableMcpIntegration = true;
      context.GEMINI = cfg.sharedPrompt;
      settings = {
        security.auth.selectedType = "oauth-personal";
        general = {
          vimMode = true;
          previewFeatures = true;
        };
        hasSeenIdeIntegrationNudge = true;
        ide.enabled = true;
        context.fileName = [
          "GEMINI.md"
          "AGENTS.md"
          "CONTEXT.md"
        ];
      };
    };
  };
}
