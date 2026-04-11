{ config, pkgs, ... }:

{
  services.displayManager = {
    sddm = {
      enable = true;
      # 建议开启 Wayland 支持，让 SDDM 运行在 Wayland 而不是 X11 上
      wayland.enable = true;
    };
    # 设置默认启动 Hyprland
    defaultSession = "hyprland";
  };

  # 某些主题可能需要的依赖
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects # 很多 SDDM 主题依赖这个
  ];
}
