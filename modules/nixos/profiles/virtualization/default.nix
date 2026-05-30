{ config, lib, ... }:
let
  cfg = config.vix.profiles.virtualization;
in
{
  options.vix.profiles.virtualization = {
    enable = lib.mkEnableOption "Common virtualization configurations for VMs";
  };

  config = lib.mkIf cfg.enable {
    # 这里的配置仅在运行 nixos-rebuild build-vm 时生效
    virtualisation.vmVariant = {
      # 1. 禁用 facter 以避免硬件不匹配导致的构建失败
      hardware.facter.enable = lib.mkForce false;
      
      # 2. 硬件补丁: 强制覆盖内核模块, 移除物理机特有的驱动 (如 nvidia)
      # 否则精简版 VM 内核会因为找不到模块而崩溃
      boot.initrd.kernelModules = lib.mkForce [ "virtio_pci" "virtio_blk" "virtio_input" "virtio_net" "virtio_rng" ];
      
      # 3. 显卡补丁: VM 强制使用 modesetting
      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

      # 4. 终端与输出支持
      boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
      virtualisation.qemu.options = [ 
        "-serial mon:stdio"
        "-vga virtio"
        "-display gtk,gl=on"
      ];

      services.getty.autologinUser = config.vix.system.user.name;
    };
  };
}
