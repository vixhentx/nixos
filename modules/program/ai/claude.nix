{ config, lib, osConfig ? { }, pkgs, ... }:
let
  ai = import ./catalog.nix { inherit config lib osConfig pkgs; };
in
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    memory.text = ai.sharedPrompt;
    settings = {
      includeCoAuthoredBy = false;
      permissions.additionalDirectories = [
        config.home.homeDirectory
        "/tmp"
        ai.knowledgeBaseDir
      ];
    };
  };
}
