{ config, lib, ... }:
let
  cfg = config.vix.profiles.virtualization;
in
{
  options.vix.profiles.virtualization = {
    enable = lib.mkEnableOption "Common virtualization configurations for VMs";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.vmVariant = {
      # 禁用 facter 以避免硬件不匹配导致的构建失败 (如 NVIDIA 模块缺失)
      hardware.facter.enable = lib.mkForce false;
      
      # 终端输出支持
      boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
      
      # QEMU 串口重定向到标准输出
      virtualisation.qemu.options = [ 
        "-serial mon:stdio"
        "-vga virtio"
        "-display gtk,gl=on"
      ];

      # 自动登录
      services.getty.autologinUser = config.vix.system.user.name;
    };
  };
}
