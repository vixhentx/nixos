{ config, lib, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  config = lib.mkIf cfg.enable {
    # kwin 输入法后端: 统一指向 fcitx5 wayland launcher (所有设备键盘都是 fcitx5).
    # 对应 KWin 虚拟键盘下拉里的 "Fcitx 5 Wayland Launcher".
    # plasma-manager 无专门选项, 只能手写 kwinrc.
    # 触屏设备额外启用 VirtualKeyboardEnabled 自动弹出 OSK (后续实验项).
    programs.plasma.configFile.kwinrc = lib.mkMerge [
      {
        Wayland.InputMethod = "fcitx5-wayland-launcher.desktop";
      }
      (lib.mkIf cfg.mobile.enable {
        Wayland.VirtualKeyboardEnabled = true;
      })
    ];
  };
}
