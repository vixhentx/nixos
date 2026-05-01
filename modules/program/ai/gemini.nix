{ config, lib, osConfig ? { }, pkgs, ... }:
let
  ai = import ./catalog.nix { inherit config lib osConfig pkgs; };
in
{
  programs.gemini-cli = {
    enable = true;
    enableMcpIntegration = true;
    context = {
      GEMINI = ai.sharedPrompt;
    };
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
}
