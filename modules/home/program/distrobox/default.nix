{ config, lib, ... }:

let
  cfg = config.vix.program.distrobox;
in
{
  options.vix.program.distrobox = {
    enable = lib.mkEnableOption "Distrobox development containers";
  };

  config = lib.mkIf cfg.enable {
    programs.distrobox = {
      enable = true;
      containers = {
        ubuntu-22-04.image = "ubuntu:22.04";
        ubuntu-26-04.image = "ubuntu:26.04";
        fedora-44.image = "fedora:44";
        arch-linux.image = "archlinux:latest";
        alpine.image = "alpine:latest";
      };
    };
  };
}
