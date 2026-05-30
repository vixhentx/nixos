{ config, lib, ... }:

let
  cfg = config.vix.suites.hyprland;
in
{
  options.vix.suites.hyprland = {
    enable = lib.mkEnableOption "Hyprland user scenario suite";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.hyprland.enable = true;
    vix.program.tomat.enable = true;
    vix.program.fcitx.enable = true;

    vix.suites.desktop.enable = lib.mkDefault true;

    # 样式接口映射：让 style.css 保持抽象
    # 这里定义了 Waybar 需要的所有抽象颜色变量
    # TODO: 使用Stylix
    vix.desktop.hyprland.waybar.extraStyle = ''
      /* 基础调色盘 (Catppuccin Mocha 风格) */
      /* 未来这部分可以抽离到独立的主题模块，通过 Nix 变量动态注入 */
      @define-color base   #1e1e2e;
      @define-color text   #cdd6f4;
      @define-color mauve  #cba6f7;
      @define-color blue   #89b4fa;
      @define-color red    #f38ba8;
      @define-color green  #a6e3a1;
      @define-color yellow #f9e2af;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color surface2 #585b70;

      /* Waybar 抽象接口：解耦具体主题颜色名 */
      @define-color wb-bg         @base;
      @define-color wb-fg         @text;
      @define-color wb-module-bg  @surface0;
      @define-color wb-accent-bg  @surface1;
      @define-color wb-accent-fg  @blue;
      @define-color wb-clock-fg   @mauve;
      @define-color wb-urgent     @red;
      @define-color wb-active     @green;
      @define-color wb-active-bg  @surface2;
      @define-color wb-warning    @yellow;
      @define-color wb-accent     @blue;
    '';
  };
}
