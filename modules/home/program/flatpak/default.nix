# FIXME: flatpak会导致每次rebuild都奇慢
{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.flatpak;
in
{
  options.vix.program.flatpak = {
    enable = lib.mkEnableOption "Declarative flatpak applications (QQ, Feishu, WeChat, etc.)";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      update = {
        onActivation = false;
        auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };

      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      overrides.settings.global = {
        Context = {
          sockets = ["wayland" "!x11" "!fallback-x11"];
          filesystems = [
            "/run/current-system/sw/share/icons:ro"
            "/run/current-system/sw/share/themes:ro"
            "${config.home.pointerCursor.package}/share/icons:ro"
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
          ];
        };
        Environment = {
          XCURSOR_PATH = "${config.home.pointerCursor.package}/share/icons";
          XCURSOR_THEME = config.home.pointerCursor.name;
          XCURSOR_SIZE = toString config.home.pointerCursor.size;
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
        };
      };

      uninstallUnmanaged = true;
    };
  };
}
