{ config, lib, ... }:

let
  cfg = config.vix.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 5;
          no_fade_in = true;
        };

        background = {
          monitor = "";
        };

        "input-field" = {
          monitor = "";
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "<i>Enter password...</i>";
          fail_text = "<i>$FAIL</i>";
        };

        label = {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          position = "0, 100";
          halign = "center";
          valign = "center";
        };
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 240;
            "on-timeout" = "loginctl lock-session";
          }
          {
            timeout = 300;
            "on-timeout" = "systemctl suspend";
          }
        ];
      };
    };
  };
}
