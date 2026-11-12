{ config, lib, ... }:

let
  cfg = config.vix.desktop.hyprland.swaync;
in
{
  options.vix.desktop.hyprland.swaync = {
    enable = lib.mkEnableOption "SwayNotificationCenter notification daemon";
  };

  config = lib.mkIf cfg.enable {
    services.swaync = {
      enable = true;
      settings = {
        positionX = "center";
        positionY = "top";
        layer = "overlay";
        layer-shell-cover-screen = false;
        notification-window-width = 420;
        notification-window-height = 260;
        control-center-positionX = "right";
        control-center-positionY = "top";
        control-center-margin-top = 46;
        control-center-margin-right = 16;
        control-center-margin-bottom = 16;
        control-center-margin-left = 16;
        control-center-width = 420;
        control-center-height = -1;
        control-center-exclusive-zone = false;
        fit-to-screen = false;
        notification-grouping = true;
        relative-timestamps = true;
        timeout = 5;
        timeout-low = 3;
        timeout-critical = 0;
        hide-on-clear = true;
        hide-on-action = true;
        widgets = [ "title" "dnd" "notifications" ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
          };
          dnd = {
            text = "Do Not Disturb";
          };
          notifications = {
            vexpand = true;
          };
        };
      };
      style = ''
        .notification-row {
          outline: none;
        }

        .notification {
          background: @theme_bg_color;
          border: 3px solid @theme_selected_bg_color;
          border-radius: 14px;
          box-shadow: 0 4px 18px alpha(@theme_fg_color, 0.28);
          padding: 10px;
        }

        .notification.low {
          border-color: @theme_unfocused_fg_color;
          opacity: 0.86;
        }

        .notification.normal {
          border-color: @theme_selected_bg_color;
        }

        .notification.critical {
          background: alpha(@error_color, 0.16);
          border-color: @error_color;
          box-shadow: 0 4px 22px alpha(@error_color, 0.42);
        }

        .notification-content {
          padding: 4px;
        }

        .summary,
        .body {
          -gtk-font-weight: normal;
          white-space: normal;
        }

        .summary {
          -gtk-font-weight: bold;
        }

        .critical .summary {
          color: @error_color;
          -gtk-font-weight: 800;
        }

        .control-center {
          border: 2px solid @theme_selected_bg_color;
          border-radius: 14px;
          padding: 12px;
        }

        .control-center-list {
          padding: 0;
        }
      '';
    };
  };
}
