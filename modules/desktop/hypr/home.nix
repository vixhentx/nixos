{ config, pkgs, inputs, ... }:

{
  imports = [
    ./config.nix
    ./workspace.nix
    ./config.nix
    ./dunst.nix
    ./rofi.nix
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
