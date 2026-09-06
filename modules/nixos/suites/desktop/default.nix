{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.desktop;
in
{
  options.vix.suites = {
    desktop.enable = lib.mkEnableOption "Generic desktop services (audio, bluetooth, etc.)";
  };

  config = lib.mkIf cfg.enable {
    # 基础图形支持
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 音频支持
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # 蓝牙支持
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # 开启系统核心标准件 (Polkit/DBus/Dconf)
    vix.system.core.enable = true;

    # 输入设备支持
    services.libinput.enable = true;

    # 开机动画
    boot.plymouth.enable = true;
  };
}