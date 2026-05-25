{ lib, pkgs, ... }:
{
  system.stateVersion = "24.05";

  # 启用基础套件
  vix.suites.common.enable = true;
  
  # 启用虚拟化配置
  vix.profiles.virtualization.enable = true;

  # VM 专用基础配置
  boot.loader.systemd-boot.enable = true;
  fileSystems."/" = { 
    device = "/dev/vda1"; 
    fsType = "ext4";
  };
}
