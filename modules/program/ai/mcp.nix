{ config, lib, osConfig ? { }, pkgs, ... }:
let
  ai = import ./catalog.nix { inherit config lib osConfig pkgs; };
in
{
  programs.mcp = {
    enable = true;
    servers = ai.mcpServers;
  };
}
