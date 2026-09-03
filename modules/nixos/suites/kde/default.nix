{ lib, config, ... }:
let
  cfg = config.vix.suites.kde;
in {
  options.vix.suites.kde = {
    enable = lib.mkEnableOption "KDE application suite (NixOS level)";
    mobile = {
      enable = lib.mkEnableOption "Mobile (touchscreen) optimization for KDE apps";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
