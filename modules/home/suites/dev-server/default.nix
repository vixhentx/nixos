{ config, lib, pkgs, ... }:
let
  cfg = config.vix.suites.dev-server;
in
{
  options.vix.suites.dev-server = {
    enable = lib.mkEnableOption "Enable development server hosting";
    code = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    services.vscode-server = lib.mkIf cfg.code {
      enable = true;
      enableFHS = true;
      nodejsPackage = pkgs.nodejs;
    };
  };
}
