{ config, lib, pkgs, ... }:
{
  config = {
    assertions = [
      {
        assertion = config.vix.suites.theme-catppuccin.enable
          || config.vix.suites.theme-tokyo-night.enable;
        message = "vix.theme: You must enable at least one theme suite (vix.suites.theme-catppuccin or vix.suites.theme-tokyo-night).";
      }
    ];

    # 字体：所有主题共享，不由单个 suite 重复定义
    stylix.fonts = {
      serif = {
        package = pkgs.sarasa-gothic;
        name = "Sarasa UI SC";
      };
      sansSerif = {
        package = pkgs.sarasa-gothic;
        name = "Sarasa UI SC";
      };
      monospace = {
        package = pkgs.sarasa-gothic;
        name = "Sarasa Mono SC";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 10;
        popups = 12;
        terminal = 14;
      };
    };

    # 禁用 Stylix 自动 Waybar CSS，改用自定义 style.css + @wb-* 注入
    home-manager.sharedModules = [
      {
        stylix.targets.waybar.enable = lib.mkDefault false;
      }
      # Waybar 颜色注入：从 Stylix base16 调色盘 → @wb-* 抽象变量
      # 此注入是通用的，任何 base16 主题都能正确映射
      {
        vix.desktop.hyprland.waybar.extraStyle = with config.lib.stylix.colors; ''
          @define-color base   #${base00};
          @define-color text   #${base05};
          @define-color mauve  #${base0E};
          @define-color blue   #${base0D};
          @define-color red    #${base08};
          @define-color green  #${base0B};
          @define-color yellow #${base0A};
          @define-color surface0 #${base02};
          @define-color surface1 #${base03};
          @define-color surface2 #${base04};

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
      }
    ];
  };
}
