{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.tomat;
in
{
  options.vix.program.tomat = {
    enable = lib.mkEnableOption "Tomat pomodoro timer";
  };

  config = lib.mkIf cfg.enable {
    services.tomat = {
      enable = true;
      settings = {
        timer = {
          work = 25;
          break = 5;
        };
        display = {
          text_format = "{icon} {time}";
          icons = {
            work = "󱎫";
            break = "󰅶";
            long_break = "󰘀";
            pause = "󰏤";
          };
        };
      };
    };
  };
}