{ lib, pkgs, ... }:
let
  apps = import ./packages { inherit lib pkgs; };
in
{
  imports = [ ./config ];

  home.packages = apps.all;
}
