{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
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

      # 触屏优先的底部 dock 面板 (仅触屏设备)
      panels = lib.mkIf cfg.mobile.enable [
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

      # kwin 输入法后端: 统一指向 fcitx5 wayland launcher (所有设备键盘都是 fcitx5).
      # 对应 KWin 虚拟键盘下拉里的 "Fcitx 5 Wayland Launcher".
      # plasma-manager 无专门选项, 只能手写 kwinrc.
      # 触屏设备额外启用 VirtualKeyboardEnabled 自动弹出 OSK (后续实验项).
      configFile.kwinrc = lib.mkMerge [
        {
          Wayland.InputMethod = "fcitx5-wayland-launcher.desktop";
        }
        (lib.mkIf cfg.mobile.enable {
          Wayland.VirtualKeyboardEnabled = true;
        })
      ];
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
  };
}
