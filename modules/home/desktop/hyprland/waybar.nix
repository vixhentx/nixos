{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland.waybar;

  workspaces_sh = pkgs.writeShellScript "workspaces.sh" (builtins.readFile ./waybar/workspaces.sh);
in
{
  options.vix.desktop.hyprland.waybar = {
    enable = lib.mkEnableOption "Waybar status bar";
    extraStyle = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "CSS variables injected by the theme module. Colors from Stylix base16.";
    };
    pomodoro = {
      enable = lib.mkEnableOption "Pomodoro timer module (tomat)" // { default = true; };
    };
    clipboard = {
      enable = lib.mkEnableOption "Clipboard history module (cliphist)" // { default = true; };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;

          "tray-position" = "right";
          "tray-padding" = 10;

          "modules-left" = [ "custom/workspaces" ]
            ++ lib.optional cfg.pomodoro.enable "custom/pomodoro";
          "modules-center" = [ "clock" ];
          "modules-right" = [
            "pulseaudio" "network" "cpu" "memory" "battery" "tray"
          ] ++ lib.optional cfg.clipboard.enable "custom/clipboard"
            ++ [ "custom/logout" ];

          "custom/workspaces" = {
            exec = "${workspaces_sh}";
            "return-type" = "json";
            interval = 2;
            tooltip = false;
          };

          "custom/pomodoro" = lib.mkIf cfg.pomodoro.enable {
            exec = "${pkgs.tomat}/bin/tomat watch --interval 1";
            return-type = "json";
            restart-interval = 5;
            on-click = "${pkgs.tomat}/bin/tomat toggle";
            on-click-middle = "${pkgs.tomat}/bin/tomat start";
            on-click-right = "${pkgs.tomat}/bin/tomat stop";
            format = "{}";
          };

          "custom/clipboard" = lib.mkIf cfg.clipboard.enable {
            format = "󱘖";
            on-click = "cliphist list | rofi -dmenu -p 'Clipboard' | cliphist decode | wl-copy";
            on-click-right = "cliphist wipe";
            tooltip = false;
          };

          clock = {
            format = "󱑂 {:%H:%M}";
            tooltip = true;
            "tooltip-format" = "{:%A, %Y-%m-%d}";
            "format-alt" = "󰃭 {:%Y-%m-%d}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            "format-muted" = "󰝟 muted";
            "format-icons" = {
              default = ["" "" "󰕾" ""];
            };
            "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            tooltip = false;
          };

          network = {
            "format-connected" = " {essid}";
            "format-disconnected" = "󰖪 Disconnected";
            tooltip = true;
            "tooltip-format" = "{ipaddr} via {gwaddr}";
          };

          cpu = {
            format = " {usage}%";
            tooltip = false;
          };

          memory = {
            format = "󰍛 {percentage}%";
            tooltip = false;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            "format-charging" = "󰂄 {percentage}%";
            "format-discharging" = "{icon} {percentage}%";
            "format-full" = "󰁹 {percentage}%";
            "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            tooltip = false;
          };

          "custom/logout" = {
            format = "󰍃";
            "on-click" = "wlogout";
            tooltip = false;
          };
        };
      };

      style = ''
        ${cfg.extraStyle}
        ${builtins.readFile ./waybar/style.css}
      '';
    };
  };
}
