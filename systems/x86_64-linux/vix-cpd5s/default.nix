{ lib, ... }:
{
  # 状态版本
  system.stateVersion = "25.11";

  # 启用核心功能套件
  vix.suites.common.enable = true;
  
  # 启用虚拟化 Profile (仅影响 build-vm)
  vix.profiles.virtualization.enable = true;

  # 硬件与引导
  hardware.facter.reportPath = ./facter.json;
  
  # 文件系统挂载
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/18AC-8C80";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/37ba61c1-9d96-4bc3-b204-c2b6b2d4bff4";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ ];

  # Home Manager 全局一致性
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
