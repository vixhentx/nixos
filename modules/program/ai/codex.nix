{ config, lib, osConfig ? { }, pkgs, ... }:
let
  ai = import ./catalog.nix { inherit config lib osConfig pkgs; };
in
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    custom-instructions = ai.sharedPrompt;
  };
}
