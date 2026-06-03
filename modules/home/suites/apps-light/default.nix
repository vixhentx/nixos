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
      # TODO: bitwarden的electron包有问题, 等待上游更新
      bitwarden.enable = false;
      firefox.enable = true;
      thunderbird.enable = true;
      libreoffice.enable = true;
      vscode.enable = true;
    };
  };
}
