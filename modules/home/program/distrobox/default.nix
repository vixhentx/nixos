{ config, lib, ... }:

let
  cfg = config.vix.program.distrobox;
  hostProfile = "/etc/profiles/per-user/${config.home.username}/bin";
  hostNixProfile = "/nix/var/nix/profiles/system/sw/bin";
  containerFlags =
    "--env NIX_REMOTE=daemon --env ZSH_DISABLE_COMPFIX=true --env PATH=${hostProfile}:${hostNixProfile} --env NIX_PROFILES=${hostNixProfile}:${hostProfile}";
in
{
  options.vix.program.distrobox = {
    enable = lib.mkEnableOption "Distrobox development containers";
  };

  config = lib.mkIf cfg.enable {
    programs.distrobox = {
      enable = true;
      settings = {
        # Keep the Nix store and daemon shared by every container. The Nix
        # package also installs this mount, but declaring it here makes the
        # container contract explicit.
        container_additional_volumes =
          "/nix:/nix /etc/profiles/per-user/${config.home.username}:/etc/profiles/per-user/${config.home.username}:ro";

      };
      containers = {
        ubuntu-22-04 = {
          image = "ubuntu:22.04";
          additional_flags = containerFlags;
          replace = true;
        };
        ubuntu-26-04 = {
          image = "ubuntu:26.04";
          additional_flags = containerFlags;
          replace = true;
        };
        fedora-44 = {
          image = "fedora:44";
          additional_flags = containerFlags;
          replace = true;
        };
        arch-linux = {
          image = "archlinux:latest";
          additional_flags = containerFlags;
          replace = true;
        };
        alpine = {
          image = "alpine:latest";
          additional_flags = containerFlags;
          replace = true;
        };
      };
    };
  };
}
