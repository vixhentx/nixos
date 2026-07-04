{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland;

  scripts = pkgs.runCommand "hyprland-scripts" {
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

    substituteAll ${./scripts/screenshot.sh.in} $out/screenshot.sh
    substituteAll ${./scripts/screenrecord.sh.in} $out/screenrecord.sh

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
    vix.desktop.hyprland.waybar.enable = lib.mkDefault true;
    vix.desktop.hyprland.rofi.enable = lib.mkDefault true;
    vix.desktop.hyprland.dunst.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      brightnessctl grim libnotify slurp
      wf-recorder wlogout jq
      wl-clipboard
    ];

    services.cliphist.enable = true;
    services.hyprpaper.enable = true;
    services.network-manager-applet.enable = true;

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;
      configType = "lua";

      settings = {
        mainMod = { _var = "SUPER"; };
        terminal = { _var = "kitty"; };
        fileManager = { _var = "dolphin"; };

        # ── hl.config({...}) ──────────────────────────────
        config = {
          general = {
            gaps_in = 5;
            gaps_out = 20;
            border_size = 2;
            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
            };
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          dwindle = {
            preserve_split = true;
          };

          xwayland = {
            force_zero_scaling = true;
          };

          cursor = {
            no_hardware_cursors = true;
          };

          input = {
            kb_layout = "us";
            follow_mouse = 1;
          };

          misc = {
            disable_hyprland_logo = true;
          };
        };

        # ── hl.curve("name", {type, points}) ─────────────
        curve = [
          {
            _args = [
              "easeOutQuint"
              {
                type = "bezier";
                points = [ [ 0.23 1 ] [ 0.32 1 ] ];
              }
            ];
          }
          {
            _args = [
              "easeInOutCubic"
              {
                type = "bezier";
                points = [ [ 0.65 0.05 ] [ 0.36 1 ] ];
              }
            ];
          }
          {
            _args = [
              "linear"
              {
                type = "bezier";
                points = [ [ 0 0 ] [ 1 1 ] ];
              }
            ];
          }
          {
            _args = [
              "almostLinear"
              {
                type = "bezier";
                points = [ [ 0.5 0.5 ] [ 0.75 1 ] ];
              }
            ];
          }
          {
            _args = [
              "quick"
              {
                type = "bezier";
                points = [ [ 0.15 0 ] [ 0.1 1 ] ];
              }
            ];
          }
        ];

        # ── hl.animation({leaf, enabled, speed, bezier, style}) ───
        animation = [
          { leaf = "global";        enabled = true; speed = 10;   bezier = "default";      }
          { leaf = "border";        enabled = true; speed = 5.39; bezier = "easeOutQuint";  }
          { leaf = "windows";       enabled = true; speed = 4.79; bezier = "easeOutQuint";  }
          { leaf = "windowsIn";     enabled = true; speed = 4.1;  bezier = "easeOutQuint";  style = "popin 87%"; }
          { leaf = "windowsOut";    enabled = true; speed = 1.49; bezier = "linear";        style = "popin 87%"; }
          { leaf = "fadeIn";        enabled = true; speed = 1.73; bezier = "almostLinear";  }
          { leaf = "fadeOut";       enabled = true; speed = 1.46; bezier = "almostLinear";  }
          { leaf = "fade";          enabled = true; speed = 3.03; bezier = "quick";         }
          { leaf = "layers";        enabled = true; speed = 3.81; bezier = "easeOutQuint";  }
          { leaf = "layersIn";      enabled = true; speed = 4;    bezier = "easeOutQuint";  style = "fade"; }
          { leaf = "layersOut";     enabled = true; speed = 1.5;  bezier = "linear";        style = "fade"; }
          { leaf = "fadeLayersIn";  enabled = true; speed = 1.79; bezier = "almostLinear";  }
          { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear";  }
          { leaf = "workspaces";    enabled = true; speed = 1.94; bezier = "almostLinear";  style = "fade"; }
          { leaf = "workspacesIn";  enabled = true; speed = 1.21; bezier = "almostLinear";  style = "fade"; }
          { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear";  style = "fade"; }
        ];

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

          # Focus movement
          { _args = [ "SUPER + left"  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "l" })'') ]; }
          { _args = [ "SUPER + right" (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "r" })'') ]; }
          { _args = [ "SUPER + up"    (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "u" })'') ]; }
          { _args = [ "SUPER + down"  (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "d" })'') ]; }

          # Previous workspace
          { _args = [ "SUPER + Backspace" (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "previous" })'') ]; }

          # Dynamic workspace selection
          { _args = [ "SUPER + Q"        (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/rofi.sh switch")'') ]; }
          { _args = [ "SUPER + SHIFT + Q" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("${workspace_scripts}/rofi.sh move")'') ]; }

          # Scratchpad
          { _args = [ "SUPER + S"        (lib.generators.mkLuaInline ''hl.dsp.workspace.toggle_special("magic")'') ]; }
          { _args = [ "SUPER + SHIFT + S" (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "special:magic" })'') ]; }
        ]
        ++ (
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
          # Volume/brightness
          { _args = [ "XF86AudioRaiseVolume"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86AudioLowerVolume"  (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86AudioMute"         (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'') { repeating = true; locked = true; } ]; }
          { _args = [ "XF86MonBrightnessUp"   (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%+")'')  { repeating = true; locked = true; } ]; }
          { _args = [ "XF86MonBrightnessDown" (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'')  { repeating = true; locked = true; } ]; }

          # Mouse binds
          { _args = [ "SUPER + mouse:272" (lib.generators.mkLuaInline "hl.dsp.window.drag()")   { mouse = true; } ]; }
          { _args = [ "SUPER + mouse:273" (lib.generators.mkLuaInline "hl.dsp.window.resize()") { mouse = true; } ]; }
        ];
      };
    };
  };
}
