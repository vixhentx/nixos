{ config, lib, pkgs, ... }:

let
  flavor = "mocha";
  accent = "lavender";
  gtkThemeName = "catppuccin-${flavor}-${accent}-standard";
  gtkThemePackage = pkgs.catppuccin-gtk.override {
    variant = flavor;
    accents = [ accent ];
    size = "standard";
  };
in

lib.mkMerge [
  {
    catppuccin.enable = true;
    catppuccin.flavor = flavor;
    catppuccin.accent = accent;

    catppuccin.cursors.enable = true;
    catppuccin.chromium.enable = true;
    catppuccin.firefox.enable = true;
    catppuccin.fcitx5.enable = true;
    catppuccin.fzf.enable = true;
    catppuccin.gemini-cli.enable = true;
    catppuccin.gtk.icon.enable = true;
    catppuccin.hyprland.enable = true;
    catppuccin.kitty.enable = true;
    catppuccin.kvantum.enable = false;
    catppuccin.element-desktop.enable = true;
    catppuccin.dunst.enable = true;
    catppuccin.qt5ct.enable = true;
    catppuccin.skim.enable = true;
    catppuccin.tmux.enable = true;
    catppuccin.rofi.enable = true;
    catppuccin.tofi.enable = true;
    catppuccin.vscode.profiles.default.enable = true;
    catppuccin.waybar.enable = true;
    catppuccin.wlogout.enable = true;
    catppuccin.zsh-syntax-highlighting.enable = true;

    gtk = {
      enable = true;
      colorScheme = "dark";
      theme = {
        name = gtkThemeName;
        package = gtkThemePackage;
      };
      gtk4.theme = {
        name = gtkThemeName;
        package = gtkThemePackage;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "Fusion";
    };
  }

  (lib.mkIf config.catppuccin.hyprland.enable {
    wayland.windowManager.hyprland.settings.general = {
      "col.active_border" = lib.mkDefault "rgba($accentAlphaff)";
      "col.inactive_border" = lib.mkDefault "rgba($surface0Alphacc)";
    };
  })
]
