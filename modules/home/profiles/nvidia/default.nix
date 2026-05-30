{ config, lib, ... }:

let
  cfg = config.vix.profiles.nvidia;
in
{
  options.vix.profiles.nvidia = {
    enable = lib.mkEnableOption "NVIDIA user-level environment profiles";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # 在 NVIDIA 环境下通常需要禁用硬件光标以避免闪烁或不显示
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}