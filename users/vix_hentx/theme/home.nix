{ config, lib, ... }:

lib.mkMerge [
  {
    catppuccin.enable = true;
    catppuccin.flavor = "mocha";
    catppuccin.accent = "lavender";

    catppuccin.cursors.enable = true;
    catppuccin.chromium.enable = true;
    catppuccin.fcitx5.enable = true;
    catppuccin.fzf.enable = true;
    catppuccin.gemini-cli.enable = true;
    catppuccin.hyprland.enable = true;
    catppuccin.kitty.enable = true;
    # catppuccin.nvim.enable = true;
    catppuccin.element-desktop.enable = true;
    catppuccin.qt5ct.enable = true;
    catppuccin.skim.enable = true;
    catppuccin.tmux.enable = true;
    catppuccin.rofi.enable = true;
    catppuccin.tofi.enable = true;
    catppuccin.vscode.profiles.default.enable = true;
    catppuccin.waybar.enable = true;
    catppuccin.wlogout.enable = true;
    catppuccin.zsh-syntax-highlighting.enable = true;
  }

  (lib.mkIf config.catppuccin.hyprland.enable {
    wayland.windowManager.hyprland.settings.general = {
      "col.active_border" = lib.mkDefault "rgba($accentAlphaff)";
      "col.inactive_border" = lib.mkDefault "rgba($surface0Alphacc)";
    };
  })
]
