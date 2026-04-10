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
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
