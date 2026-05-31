{ config, lib, ... }:

let
  cfg = config.vix.suites.apps-light;
in
{
  options.vix.suites.apps-light = {
    enable = lib.mkEnableOption "Lightweight desktop applications suite (user level)";
  };

  config = lib.mkIf cfg.enable {
    vix.program.apps-light.enable = true;
    vix.program.firefox.enable = true;
    vix.program.vscode.enable = true;
    vix.program.thunderbird.enable = true;
    vix.program.bitwarden.enable = true;

    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
