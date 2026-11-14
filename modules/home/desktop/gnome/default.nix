{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.gnome;
in
{
  imports = [
    ./appearance.nix
    ./input.nix
    ./terminal.nix
  ];

  options.vix.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop (home level)";

    mobile = {
      enable = lib.mkEnableOption "Mobile (touchscreen) GNOME support";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix.targets.gtk.enable = true;

    programs.gnome-shell = {
      enable = true;
      extensions = [
        { package = pkgs.gnomeExtensions.gsconnect; }
        { package = pkgs.gnomeExtensions.hide-top-bar; }
      ];
    };

    dconf.settings = {
      "org/gnome/mutter".dynamic-workspaces = false;
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Super>c" ];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-input-source = [ "<Super>space" ];
        switch-input-source-backward = [ "<Shift><Super>space" ];
      };

      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
        name = "Open terminal";
        command = config.vix.program.xdg.terminal.application;
        binding = "<Super>t";
      };

      # GNOME's OSK preference is global, not tablet-mode-aware. Keep it off
      # so a convertible does not show it whenever a text field gets focus.
      "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = false;
    };

    vix.suites.connection.kdeconnect.enable = false;
    vix.program.xdg.kde.enable = false;
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    home.packages = [ pkgs.wl-clipboard ];
  };
}
