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

      # kwin 虚拟键盘 (maliit): plasma-manager 无专门选项, 走原始 kwinrc.
      # InputMethod 指向 maliit-keyboard 的桌面文件, VirtualKeyboardEnabled 让 KWin 在聚焦文本框时自动弹出.
      configFile.kwinrc.Wayland.VirtualKeyboardEnabled = true;
      configFile.kwinrc.Wayland.InputMethod =
        "/run/current-system/sw/share/applications/com.github.maliit.keyboard.desktop";
    };

    # Electron/Chromium 应用 (QQ/Feishu/WeChat 等) 原生 Wayland:
    # NIXOS_OZONE_WL 让 nixpkgs 的 qq 启动器启用 wayland 参数; ozone hint 让其余 Electron 应用尝试 Wayland.
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    # 会话启动后按 monitors 单一来源应用每屏缩放 (kscreen-doctor).
    systemd.user.services.kscreen-scale = {
      Unit = {
        Description = "Apply Plasma Wayland output scale";
        After = [ "plasma-kwin_wayland.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = let
          args = lib.concatMapStringsSep " "
            (o: "output.${o.output}.scale.${builtins.toString o.scale}") cfg.outputs;
        in "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor ${args}";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    home.packages = lib.mkIf cfg.apps-mobile.enable (with pkgs.kdePackages; [
      angelfish # 触屏浏览器
      koko      # 触屏图库
      tokodon   # Mastodon
    ]);
  };
}
