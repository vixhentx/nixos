{ config, lib, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  imports = [
    ./panels.nix
    ./kwin.nix
    ./scale.nix
  ];

  options.vix.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop (home level)";

    mobile = {
      enable = lib.mkEnableOption "Mobile (touchscreen) optimization for Plasma";
    };

    outputs = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          output = lib.mkOption { type = lib.types.str; };
          scale = lib.mkOption { type = lib.types.float; };
        };
      });
      default = [];
      description = "Plasma Wayland per-output scale (applied via kscreen-doctor).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Qt 应用主题由 stylix.targets.kde (kdeglobals) 负责, qtct 平台不支持 kde, 关闭以消除警告
    stylix.targets.qt.enable = false;

    # 自动开启 KDE 应用套件并传递 mobile 选项
    vix.suites.kde.enable = lib.mkDefault true;
    vix.suites.kde.mobile.enable = cfg.mobile.enable;

    programs.plasma = {
      enable = true;

      # 默认终端由 plasma-manager 写真实 kdeglobals (xdg 模块不再写, 避免符号链接冲突)
      configFile."kdeglobals" = {
        General.TerminalApplication = config.vix.program.xdg.terminal.application;
        General.TerminalService = config.vix.program.xdg.terminal.desktopFile;
      };
    };

    # Electron/Chromium 应用 (QQ/Feishu/WeChat 等) 原生 Wayland
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
