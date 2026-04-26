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
      context.fileName = [
        "GEMINI.md"
        "AGENTS.md"
        "CONTEXT.md"
      ];
      general = {
        preferredEditor = "nvim";
        vimMode = true;
      };
    };
  };
}
