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
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          "modules-left" = [ "custom/workspaces" "custom/pomodoro" ];
          "modules-center" = [ "clock" ];
          "modules-right" = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" "custom/clipboard" "custom/logout" ];
          "custom/workspaces" = { exec = "${workspaces_sh}"; "return-type" = "json"; interval = 2; };
        };
      };

      style = ''
        ${cfg.extraStyle}
        ${builtins.readFile ./waybar/style.css}
      '';
    };
  };
}
