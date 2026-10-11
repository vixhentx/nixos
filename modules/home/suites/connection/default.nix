{ config, lib, ... }:
let
  cfg = config.vix.suites.connection;
in
{
  options.vix.suites.connection = {
    enable = lib.mkEnableOption "Enable the connection utilities";
  };
  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      indicator = true;
      # package 自行在 de 层定义
    };
  };
}