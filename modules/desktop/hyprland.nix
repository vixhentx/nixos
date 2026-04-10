{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # 环境变量：解决 NVIDIA 在 Wayland 下的各种“灵异”问题
  environment.sessionVariables = {
    # 如果光标看不见，请开启这一行
    # WLR_NO_HARDWARE_CURSORS = "1";
    # 强制 Electron 应用（如 VSCode）使用 Wayland
    NIXOS_OZONE_WL = "1";
    # 硬件加速驱动
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  environment.systemPackages = with pkgs; [
    kitty
    waybar                # 状态栏
    rofi          # 应用菜单 (Hyprland 常用)
    dunst                 # 通知守护进程
    swww                  # 壁纸管理
    grim                  # 截图
    slurp                 # 选区截图
    wl-clipboard          # 剪贴板管理
    kanshi                # 显示器动态配置
    libnotify             # 通知工具
  ];

  # 解决应用打开慢、字体发虚等问题的 Portal
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  fonts.packages = with pkgs; [
    # nerdfonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

}
