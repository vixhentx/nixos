{ config, lib, pkgs, ... }:

let
  cfg = config.vix.profiles.nvidia;
in
{
  options.vix.profiles.nvidia = {
    enable = lib.mkEnableOption "NVIDIA driver and hardware configuration";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = true;

      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };

      powerManagement.enable = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
