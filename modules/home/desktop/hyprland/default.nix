{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.vix.desktop.hyprland;
  fontCfg = osConfig.vix.system.font;

  # 定义核心工具的绝对路径
  awww_bin = lib.getExe pkgs.awww;
  waybar_bin = lib.getExe pkgs.waybar;
  nm_applet_bin = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  wl_paste_bin = "${pkgs.wl-clipboard}/bin/wl-paste";
  cliphist_bin = lib.getExe pkgs.cliphist;
  polkitAgent = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
  
  # 内部脚本处理（使用 substituteAll 确保路径闭环）
  scripts = pkgs.runCommand "hyprland-scripts" {
    # 定义所有可能用到的工具路径
    grim = "${pkgs.grim}/bin/grim";
    slurp = "${pkgs.slurp}/bin/slurp";
    wl_copy = "${pkgs.wl-clipboard}/bin/wl-copy";
    notify_send = "${pkgs.libnotify}/bin/notify-send";
    wf_recorder = "${pkgs.wf-recorder}/bin/wf-recorder";
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    jq = "${pkgs.jq}/bin/jq";
    rofi = "${pkgs.rofi}/bin/rofi";
  } ''
    mkdir -p $out/workspace
    
    # 处理根目录脚本
    substituteAll ${./scripts/screenshot.sh.in} $out/screenshot.sh
    substituteAll ${./scripts/screenrecord.sh.in} $out/screenrecord.sh
    
    # 处理工作区脚本
    substituteAll ${./scripts/workspace/common.sh.in} $out/workspace/common.sh
    substituteAll ${./scripts/workspace/action.sh.in} $out/workspace/action.sh
    substituteAll ${./scripts/workspace/rofi.sh.in} $out/workspace/rofi.sh
    
    chmod +x $out/*.sh $out/workspace/*.sh
  '';

  screenshot_sh = "${scripts}/screenshot.sh";
  screenrecord_sh = "${scripts}/screenrecord.sh";
  workspace_scripts = "${scripts}/workspace";

in
{
  imports = [
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
  ];

  options.vix.desktop.hyprland = {
    enable = lib.mkEnableOption "Integrated Hyprland Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    # 默认开启强相关的核心组件
    vix.desktop.hyprland.waybar.enable = lib.mkDefault true;
    vix.desktop.hyprland.rofi.enable = lib.mkDefault true;
    vix.desktop.hyprland.dunst.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      brightnessctl grim libnotify networkmanagerapplet slurp
      awww wl-clipboard wf-recorder wlogout cliphist jq
    ];

    services.cliphist.enable = true;

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      # Explicitly set configType to silence warning and use standard format
      configType = "hyprlang";
      
      settings = {
        "$mainMod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";

        "exec-once" = [
          "${awww_bin} init"
          "${waybar_bin}"
          "${nm_applet_bin} --indicator"
          "${wl_paste_bin} --type text --watch ${cliphist_bin} store"
          "${wl_paste_bin} --type image --watch ${cliphist_bin} store"
          polkitAgent
        ];

        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          shadow.enabled = true;
          blur.enabled = true;
        };

        bind = [
          "$mainMod, T, exec, $terminal"
          "$mainMod, C, killactive,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, rofi -show drun"
          "$mainMod, W, exec, rofi -show window"

          ", Print, exec, ${screenshot_sh} region"
          "SHIFT, Print, exec, ${screenshot_sh} output"
          "$mainMod SHIFT, R, exec, ${screenrecord_sh} output"
          "$mainMod ALT, R, exec, ${screenrecord_sh} region"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod, Backspace, workspace, previous"

          # 动态工作区选择
          "$mainMod, Q, exec, ${workspace_scripts}/rofi.sh switch"
          "$mainMod SHIFT, Q, exec, ${workspace_scripts}/rofi.sh move"

          # Scratchpad
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
        ] 
        ++ (
          # 自动生成 1-10 的工作区绑定
          builtins.concatLists (builtins.genList (i:
            let
              ws = i + 1;
              # 这里的 10 对应按键 0
              key = if ws == 10 then "0" else toString ws;
            in [
              "$mainMod, ${key}, exec, ${workspace_scripts}/action.sh switch ${toString ws}"
              "$mainMod SHIFT, ${key}, exec, ${workspace_scripts}/action.sh move ${toString ws}"
            ]
          ) 10)
        );

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];
      };
    };
  };
}
