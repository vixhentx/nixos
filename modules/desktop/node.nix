{ pkgs, ... }:
{
  home.packages = [
    pkgs.nodejs_20
    pkgs.pnpm
  ];
}
