{ lib, pkgs, ... }:
{
  system.stateVersion = "26.05";

  # 启用基础套件 (自动继承默认用户配置)
  vix.suites.common.enable = true;
  vix.system.boot.enable = true;
  vix.system.ssh.enable = true;
  vix.system.network = {
    enable = true;
    backend = "networkd";
  };

  # 主题 (Catppuccin Mocha)
  vix.suites.theme-catppuccin.enable = true;
  
  # 启用虚拟化 Profile
  vix.profiles.virtualization.enable = true;

  # VM 专用硬件配置
  fileSystems."/" = { 
    device = "/dev/vda1"; 
    fsType = "ext4";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
