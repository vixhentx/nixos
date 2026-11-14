{ config, lib, ... }:
let
  cfg = config.vix.suites.connection;
in
{
  options.vix.suites.connection = {
    enable = lib.mkEnableOption "Enable the connection utilities";
    kdeconnect.enable = lib.mkEnableOption "Enable KDE Connect" // { default = true; };
  };
  config = lib.mkIf cfg.enable {
    services.kdeconnect = lib.mkIf cfg.kdeconnect.enable {
      enable = true;
      indicator = true;
    };
  };
}
