{ lib, config, ... }:
let
  cfg = config.vix.suites.apps-kde;
in {
  options.vix.suites.apps-kde = {
    enable = lib.mkEnableOption "KDE desktop applications suite (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}