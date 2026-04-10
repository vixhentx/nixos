{ config, pkgs, ... }:

{
  # 启用显卡驱动
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # 模式设置是 Wayland 必需的
    modesetting.enable = true;
    
    # NVIDIA 开源内核模块（对于 4060 这种新卡，推荐开启）
    open = true;

    # 笔记本双显卡配置 (Prime)
    # 请确认这些 ID 是否与你之前 lspci 查到的一致
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # 屏幕撕裂修复与电源管理
    powerManagement.enable = false; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
