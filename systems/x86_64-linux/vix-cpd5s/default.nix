{ lib, pkgs, ... }:
{
  # TODO: 迁移硬件配置和系统基础配置
  system.stateVersion = "24.05";

  hardware.facter.reportPath = ./facter.json;

  boot.loader.systemd-boot.enable = true;
  fileSystems."/" = { 
    device = "/dev/sda1"; 
    fsType = "btrfs"; # TODO: 替换为实际的硬件配置
  };
}
