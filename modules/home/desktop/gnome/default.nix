{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.gnome;
in
{
  options.vix.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop (home level)";

    mobile = {
      enable = lib.mkEnableOption "Mobile (touchscreen) GNOME support";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix.targets.gtk.enable = true;

    programs.gnome-shell.extensions = [
      {
        package = pkgs.gnomeExtensions.gsconnect;
        id = "gsconnect@andyholmes.github.io";
      }
    ];

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [ "gsconnect@andyholmes.github.io" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        dynamic-workspaces = false;
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

      "org/gnome/desktop/input-sources" = {
        sources = [ "('xkb', 'us')" "('ibus', 'rime')" ];
        xkb-options = [ ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
        name = "Open terminal";
        command = "kgx";
        binding = "<Super>t";
      };
    } // lib.optionalAttrs cfg.mobile.enable {
      "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
    };

    vix.suites.connection.kdeconnect.enable = false;
    vix.program.xdg.kde.enable = false;
    vix.program.xdg.terminal = {
      application = "kgx";
      desktopFile = "org.gnome.Console.desktop";
    };

    home.sessionVariables = {
      GTK_IM_MODULE = "ibus";
      QT_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      SDL_IM_MODULE = "ibus";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    home.packages = [ pkgs.gnome-console pkgs.wl-clipboard ];
  };
}
