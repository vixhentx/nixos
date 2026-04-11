{ pkgs, lib, ... }:
let
  categories = [
    "internet"
    "dev"
    "chat"
    "media"
  ];
in
{
  home.packages = lib.flatten (map (name: import ./${name}.nix { inherit pkgs; }) categories);
}
