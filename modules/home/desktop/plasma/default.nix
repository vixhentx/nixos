{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  options.vix.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop (home level)";

    apps-mobile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Plasma Mobile 触屏应用 (angelfish, koko, tokodon)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Qt 应用主题由 stylix.targets.kde (kdeglobals) 负责, qtct 平台不支持 kde, 关闭以消除警告
    stylix.targets.qt.enable = false;
    programs.plasma = {
      enable = true;

      # 默认终端由 plasma-manager 写真实 kdeglobals (xdg 模块不再写, 避免符号链接冲突)
      configFile."kdeglobals" = {
        General.TerminalApplication = config.vix.program.xdg.terminal.application;
        General.TerminalService = config.vix.program.xdg.terminal.desktopFile;
      };

      # 触屏优先的底部 dock 面板
      panels = [
        {
          location = "bottom";
          height = 56;
          floating = false;
          widgets = [
            { name = "org.kde.plasma.kickoff"; }
            { name = "org.kde.plasma.icontasks"; }
            { name = "org.kde.plasma.systemtray"; }
            { name = "org.kde.plasma.digitalclock"; }
          ];
        }
      ];

      # kwin 虚拟键盘 (plasma-keyboard): plasma-manager 无专门选项, 走原始 kwinrc
      configFile.kwinrc.Wayland.VirtualKeyboardEnabled = true;
    };

    home.packages = lib.mkIf cfg.apps-mobile.enable (with pkgs.kdePackages; [
      angelfish # 触屏浏览器
      koko      # 触屏图库
      tokodon   # Mastodon
    ]);
  };
}
