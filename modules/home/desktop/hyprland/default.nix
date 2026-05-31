{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland;

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
      wl-clipboard wf-recorder wlogout cliphist jq
    ];

    services.cliphist.enable = true;
    services.hyprpaper.enable = true; # 有bug, 禁用

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      AQ_NO_MODIFIERS = "1";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      configType = "lua";

      settings = {
        # _var suffix generates `local <name> = <value>` in Lua
        mainMod = { _var = "SUPER"; };
        terminal = { _var = "kitty"; };
        fileManager = { _var = "dolphin"; };

        # 颜色和壁纸由 stylix.targets.hyprland + hyprpaper 管理
        config = {
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
          misc = {
            disable_hyprland_logo = true;
          };
        };

        # Keybinds: unified hl.bind() with _args for multi-argument calls
        bind = [
          # Launch
          { _args = [ "SUPER + T"       (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("kitty")'') ]; }
          { _args = [ "SUPER + C"       (lib.generators.mkLuaInline "hl.dsp.window.close()") ]; }
          { _args = [ "SUPER + E"       (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("dolphin")'') ]; }
          { _args = [ "SUPER + V"       (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'') ]; }
          { _args = [ "SUPER + R"       (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("rofi -show drun")'') ]; }
          { _args = [ "SUPER + W"       (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("rofi -show window")'') ]; }

          # Screenshots
          { _args = [ "Print"            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${screenshot_sh} region")'') ]; }
          { _args = [ "SHIFT + Print"    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${screenshot_sh} output")'') ]; }
          { _args = [ "SUPER + SHIFT + R" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${screenrecord_sh} output")'') ]; }
          { _args = [ "SUPER + ALT + R"   (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${screenrecord_sh} region")'') ]; }

          # Focus movement (via hyprctl dispatch for guaranteed compatibility)
          { _args = [ "SUPER + left"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch movefocus l")'') ]; }
          { _args = [ "SUPER + right" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch movefocus r")'') ]; }
          { _args = [ "SUPER + up"    (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch movefocus u")'') ]; }
          { _args = [ "SUPER + down"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch movefocus d")'') ]; }

          # Previous workspace
          { _args = [ "SUPER + Backspace" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch workspace previous")'') ]; }

          # Dynamic workspace selection
          { _args = [ "SUPER + Q"        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/rofi.sh switch")'') ]; }
          { _args = [ "SUPER + SHIFT + Q" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/rofi.sh move")'') ]; }

          # Scratchpad
          { _args = [ "SUPER + S"        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace magic")'') ]; }
          { _args = [ "SUPER + SHIFT + S" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:magic")'') ]; }
        ]
        ++ (
          # Workspace binds 1-10
          builtins.concatLists (builtins.genList (i:
            let
              ws = i + 1;
              key = if ws == 10 then "0" else toString ws;
            in [
              { _args = [ "SUPER + ${key}"        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/action.sh switch ${toString ws}")'') ]; }
              { _args = [ "SUPER + SHIFT + ${key}" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/action.sh move ${toString ws}")'') ]; }
            ]
          ) 10)
        )
        ++ [
          # Volume/brightness: repeating + locked flag replaces bindel
          { _args = [ "XF86AudioRaiseVolume"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86AudioLowerVolume"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86AudioMute"         (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'') { repeating = true; locked = true; } ]; }
          { _args = [ "XF86MonBrightnessUp"   (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%+")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'')  { repeating = true; locked = true; } ]; }

          # Mouse binds: mouse flag replaces bindm
          { _args = [ "SUPER + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()")   { mouse = true; } ]; }
          { _args = [ "SUPER + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") { mouse = true; } ]; }
        ];
      };
    };
  };
}
