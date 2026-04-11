{ pkgs, lib, ... }:
let
  categories = [
    "internet"
    "dev"
    "chat"
    "media"
    "work"
    "utils"
  ];
in
{
  home.packages = lib.flatten (map (name: import ./${name}.nix { inherit pkgs; }) categories);
}
