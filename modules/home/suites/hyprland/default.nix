{ config, lib, ... }:

let
  cfg = config.vix.suites.hyprland;
in
{
  options.vix.suites.hyprland = {
    enable = lib.mkEnableOption "Hyprland user scenario suite";
  };

  config = lib.mkIf cfg.enable {
    # 开启 Hyprland 及其内聚组件
    vix.desktop.hyprland.enable = true;
    vix.program.tomat.enable = true;
    vix.program.fcitx.enable = true;

    # 依赖通用桌面应用
    vix.suites.desktop.enable = lib.mkDefault true;

    # 注入样式（这是目前集成的核心）
    vix.desktop.hyprland.waybar.extraStyle = ''
      @define-color base #1e1e2e;
      @define-color text #cdd6f4;
      @define-color surface0 rgba(49, 50, 68, 0.6);
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;
      @define-color accent #89b4fa;
      @define-color accent-alpha rgba(137, 180, 250, 0.2);
      @define-color urgent #f38ba8;
      @define-color active #a6e3a1;

      :root {
        --theme-base: @base;
        --theme-text: @text;
        --theme-surface0: @surface0;
        --theme-surface1: @surface1;
        --theme-surface2: @surface2;
        --theme-accent: @accent;
        --theme-accent-alpha: @accent-alpha;
        --theme-urgent: @urgent;
        --theme-active: @active;
      }
    '';
  };
}