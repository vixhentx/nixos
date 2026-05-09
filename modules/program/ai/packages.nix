{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mcp-server-sequential-thinking
  ];
}
