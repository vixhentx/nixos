# lib/default.nix
{ lib, ... }:
{
  inherit lib;

  modules = import ./module.nix { inherit lib; };
}
