{ config, pkgs, ... }:
let
  hyprScripts = "${config.xdg.configHome}/hypr/scripts";
  polkitAgent = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
in
{
  wayland.windowManager.hyprland.settings = {
    # --- PROGRAMS ---
    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$menu" = "rofi -show drun";
    "$winMenu" = "rofi -show window";

    # --- AUTOSTART ---
    "exec-once" = [
      "swww init"
      "waybar"
      "nm-applet --indicator"
      "fcitx5 -d --replace"
      polkitAgent
    ];

    # --- ENV ---
    env = [
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "GTK_IM_MODULE,fcitx"
      "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      "QT_IM_MODULE,fcitx"
      "QT_QPA_PLATFORM,wayland;xcb"
      "SDL_IM_MODULE,fcitx"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "XMODIFIERS,@im=fcitx"
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    xwayland = {
      force_zero_scaling = true;
    };

    # --- LOOK AND FEEL ---
    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 10;
      active_opacity = 1.0;
      inactive_opacity = 1.0;
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

    animations = {
      enabled = "yes";
      bezier = [
        "easeOutQuint, 0.23, 1, 0.32, 1"
        "easeInOutCubic, 0.65, 0.05, 0.36, 1"
        "linear, 0, 0, 1, 1"
        "almostLinear, 0.5, 0.5, 0.75, 1"
        "quick, 0.15, 0, 0.1, 1"
      ];
      animation = [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
        "windowsOut, 1, 1.49, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 1.5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };

    # --- LAYOUTS ---
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    misc = {
      force_default_wallpaper = -1;
      disable_hyprland_logo = false;
    };

    # --- INPUT ---
    input = {
      kb_layout = "us";
      follow_mouse = 1;
      sensitivity = 0;
      touchpad = {
        natural_scroll = false;
      };
    };

    # --- KEYBINDINGS ---
    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, T, exec, $terminal"
      "$mainMod, C, killactive,"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, togglefloating,"
      "$mainMod, R, exec, $menu"
      "$mainMod, W, exec, $winMenu"
      "$mainMod, P, pseudo,"
      "$mainMod, J, togglesplit,"
      ", Print, exec, ${hyprScripts}/screenshot.sh region"
      "SHIFT, Print, exec, ${hyprScripts}/screenshot.sh output"
      "$mainMod, Print, exec, spectacle"
      "$mainMod SHIFT, R, exec, ${hyprScripts}/screenrecord.sh"
      "$mainMod ALT, R, exec, ${hyprScripts}/screenrecord.sh region"

      # Move focus
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # tomat
      "$mainMod, I, exec, tomat toggle"
    ];

    # Move/resize windows with mouse
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    # Audio/Brightness (using wpctl and brightnessctl)
    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    # Media Keys
    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    # --- CURSOR ---
    # Modern Hyprland way to handle NVIDIA cursors
    cursor = {
      no_hardware_cursors = true;
    };
  };
}
