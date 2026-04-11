{ pkgs, ... }:

{
  imports = [ ./config.nix ];

  home.packages = with pkgs; [
    brightnessctl
    dunst
    gsimplecal
    grim
    jq
    kitty
    libnotify
    networkmanagerapplet
    pavucontrol
    playerctl
    rofi
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

  home.file = {
    ".config/waybar/config" = {
      source = ./waybar/config;
    };
    ".config/waybar/style.css" = {
      source = ./waybar/style.css;
    };
    ".config/waybar/scripts/workspaces.sh" = {
      source = ./waybar/scripts/workspaces.sh;
      executable = true;
    };
    ".config/waybar/scripts/gpu-status.sh" = {
      source = ./waybar/scripts/gpu-status.sh;
      executable = true;
    };
    ".config/waybar/scripts/gpu-prime-toggle.sh" = {
      source = ./waybar/scripts/gpu-prime-toggle.sh;
      executable = true;
    };
    ".config/hypr/scripts/screenshot.sh" = {
      text = builtins.readFile ./scripts/screenshot.sh;
      executable = true;
    };
    ".config/hypr/scripts/screenrecord.sh" = {
      text = builtins.readFile ./scripts/screenrecord.sh;
      executable = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
