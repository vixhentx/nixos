{ config, lib, ... }:

let
  cfg = config.vix.suites.apps-light;
in
{
  options.vix.suites.apps-light = {
    enable = lib.mkEnableOption "Lightweight desktop applications suite (user level)";
  };

  config = lib.mkIf cfg.enable {
    vix.program = {
      apps-light.enable = true;
      bitwarden.enable = true;
      firefox.enable = true;
      thunderbird.enable = true;
      libreoffice.enable = true;
      vscode.enable = true;
    };
  };
}
