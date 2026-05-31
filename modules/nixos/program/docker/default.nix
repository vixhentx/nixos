{ config, lib, ... }:

let
  cfg = config.vix.program.docker;
in
{
  options.vix.program.docker = {
    enable = lib.mkEnableOption "Docker container runtime with btrfs storage";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };
}
