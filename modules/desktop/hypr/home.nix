{ config, pkgs, inputs, ... }:

let
  mkLiteral = config.lib.formats.rasi.mkLiteral;
in

{
  imports = [
    ./config.nix
    ./workspace.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    gsimplecal
    grim
    jq
    kitty
    libnotify
    networkmanagerapplet
    pavucontrol
    playerctl
    slurp
    kdePackages.spectacle
    awww
    waybar
    wl-clipboard
    wf-recorder
    wlogout
    kdePackages.dolphin
    copyq
  ];

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    GBM_BACKEND = "nvidia-drm";
    GTK_IM_MODULE = "fcitx";
    LIBVA_DRIVER_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_IM_MODULE = "fcitx";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_IM_MODULE = "fcitx";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XMODIFIERS = "@im=fcitx";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "Sarasa Mono SC 12";
    terminal = "kitty";
    location = "center";
    yoffset = -24;
    modes = [
      "drun"
      "window"
      "run"
    ];
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = " Apps ";
      display-window = " Windows ";
      display-run = " Run ";
      hover-select = true;
      me-select-entry = "";
      cycle = true;
    };
    theme = {
      "*" = {
        bg = mkLiteral "#1e1e2ef2";
        bg-alt = mkLiteral "#313244";
        fg = mkLiteral "#cdd6f4";
        fg-muted = mkLiteral "#7f849c";
        border = mkLiteral "#b4befe";
        accent = mkLiteral "#89b4fa";
        urgent = mkLiteral "#f38ba8";
        selected = mkLiteral "#f5e0dc";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      window = {
        width = mkLiteral "760px";
        border = mkLiteral "2px";
        border-radius = mkLiteral "24px";
        border-color = mkLiteral "@border";
        background-color = mkLiteral "@bg";
        children = map mkLiteral [ "mainbox" ];
      };

      mainbox = {
        background-color = mkLiteral "transparent";
        children = map mkLiteral [ "inputbar" "message" "listview" ];
        spacing = mkLiteral "18px";
        padding = mkLiteral "24px";
      };

      inputbar = {
        background-color = mkLiteral "@bg-alt";
        border-radius = mkLiteral "18px";
        children = map mkLiteral [ "prompt" "entry" ];
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "14px";
      };

      prompt = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@accent";
      };

      entry = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        placeholder = "Launch, search, switch";
        placeholder-color = mkLiteral "@fg-muted";
      };

      "textbox-prompt-colon" = {
        expand = false;
        str = "";
      };

      message = {
        enabled = false;
      };

      listview = {
        background-color = mkLiteral "transparent";
        border = 0;
        columns = 1;
        lines = 8;
        scrollbar = false;
        spacing = mkLiteral "10px";
      };

      element = {
        background-color = mkLiteral "transparent";
        border = 0;
        border-radius = mkLiteral "16px";
        orientation = mkLiteral "vertical";
        padding = mkLiteral "14px 18px";
        spacing = mkLiteral "6px";
        text-color = mkLiteral "@fg";
      };

      "element normal.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      "element selected.normal" = {
        background-color = mkLiteral "@bg-alt";
        border = mkLiteral "1px";
        border-color = mkLiteral "@accent";
        text-color = mkLiteral "@selected";
      };

      "element-icon" = {
        background-color = mkLiteral "transparent";
        size = mkLiteral "1.15em";
      };

      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        browser = "xdg-open";
        follow = "keyboard";
        width = 920;
        height = 0;
        origin = "top-center";
        offset = "0x24";
        corner_radius = 18;
        frame_width = 2;
        separator_height = 0;
        gap_size = 10;
        padding = 20;
        horizontal_padding = 24;
        text_icon_padding = 0;
        icon_position = "off";
        min_icon_size = 0;
        max_icon_size = 0;
        notification_limit = 1;
        progress_bar = false;
        font = "Sarasa Mono SC 12";
        line_height = 4;
        format = "<span size='x-large'><b>%s</b></span>\\n%b";
        markup = "full";
        alignment = "left";
        vertical_alignment = "center";
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        show_age_threshold = 60;
        sort = true;
        stack_duplicates = true;
        hide_duplicate_count = false;
        indicate_hidden = false;
        shrink = false;
        sticky_history = true;
        idle_threshold = 120;
        layer = "overlay";
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        timeout = 3;
        background = "#1e1e2ee6";
        foreground = "#bac2de";
        frame_color = "#6c7086";
      };

      urgency_normal = {
        timeout = 5;
        background = "#1e1e2ef2";
        foreground = "#cdd6f4";
        frame_color = "#89b4fa";
      };

      urgency_critical = {
        timeout = 0;
        background = "#11111bf7";
        foreground = "#f9e2af";
        frame_color = "#f38ba8";
      };
    };
  };

  home.file = {
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };

    ".config/hypr/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    plugins = [
      # inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
    ];
  };
}
