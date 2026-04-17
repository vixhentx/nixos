{ config, lib, pkgs, ... }:

let
  # 定义脚本路径，这样 Nix 会自动处理脚本并在重建时放入 nix-store
  workspaces_sh = pkgs.writeShellScript "workspaces.sh" (builtins.readFile ./waybar/workspaces.sh);
  gpu_status_sh = pkgs.writeShellScript "gpu-status.sh" (builtins.readFile ./waybar/gpu-status.sh);
  gpu_prime_toggle_sh = pkgs.writeShellScript "gpu-prime-toggle.sh" (builtins.readFile ./waybar/gpu-prime-toggle.sh);
in
{
  # 2. 完全使用 Nix 管理 Waybar
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        
        "tray-position" = "right";
        "tray-padding" = 10;

        "modules-left" = [ "custom/workspaces" "custom/pomodoro" ];
        "modules-center" = [ "clock" ];
        "modules-right" = [ 
          "pulseaudio" 
          "network" 
          "cpu" 
          "memory" 
          "battery" 
          "tray" 
          "custom/logout" 
        ];

        "custom/workspaces" = {
          exec = "${workspaces_sh}";
          "return-type" = "json";
          interval = 2;
          tooltip = false;
        };

        "custom/pomodoro" = {
          exec = "${pkgs.tomat}/bin/tomat watch --interval 1";
          return-type = "json";
          "restart-interval" = 5;
          on-click = "${pkgs.tomat}/bin/tomat toggle";
          on-click-middle = "${pkgs.tomat}/bin/tomat start";
          on-click-right = "${pkgs.tomat}/bin/tomat stop";
          format = "{}";
        };

        clock = {
          format = "󱑂 {:%H:%M}";
          tooltip = true;
          "tooltip-format" = "{:%A, %Y-%m-%d}";
          "on-doubleclick" = "gsimplecal";
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

    # 样式表：直接读取你原本的 CSS
    style = builtins.readFile ./waybar/style.css;
  };
}
