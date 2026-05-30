{ config, lib, pkgs, osConfig, ... }:

let
  cfg = config.vix.desktop.hyprland.waybar;
  fontCfg = osConfig.vix.system.font;
  
  workspaces_sh = pkgs.writeShellScript "workspaces.sh" (builtins.readFile ./waybar/workspaces.sh);
in
{
  options.vix.desktop.hyprland.waybar = {
    enable = lib.mkEnableOption "Waybar status bar logic and structure";
    extraStyle = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "CSS variables or extra styling injected by themes or suites.";
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
        /* Injected Theme Variables */
        ${cfg.extraStyle}

        /* Global Font Settings from System */
        * {
            font-family: "${fontCfg.main.monoName}", "Symbols Nerd Font";
            font-size: ${toString fontCfg.main.size}px;
        }

        /* Atomic Structure CSS */
        ${builtins.readFile ./waybar/style.css}
      '';
    };
  };
}