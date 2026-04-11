{ pkgs, ... }:

{
  imports = [ ./config.nix ];

  home.packages = with pkgs; [
    brightnessctl
    dunst
    grim
    kanshi
    kitty
    libnotify
    networkmanagerapplet
    playerctl
    rofi
    slurp
    awww
    waybar
    wl-clipboard
    kdePackages.dolphin
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
    XDG_SESSION_TYPE = "wayland";
    XMODIFIERS = "@im=fcitx";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
