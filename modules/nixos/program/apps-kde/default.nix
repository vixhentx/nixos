{ lib, config, ... }:
let
  cfg = config.vix.suites.apps-kde;
in {
  options.vix.suites.apps-kde = {
    enable = lib.mkEnableOption "Generic user-level desktop tools";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}