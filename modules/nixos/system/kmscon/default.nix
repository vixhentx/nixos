{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vix.system.kmscon;
  fontCfg = config.vix.system.font;
in
{
  options.vix.system.kmscon = {
    enable = lib.mkEnableOption "Kmscon as TTY replacement";
  };

  config = lib.mkIf cfg.enable {
    services.kmscon = {
      enable = true;
      hwRender = true;
      useXkbConfig = true;
      fonts = [
        {
          name = fontCfg.main.monoName;
          package = fontCfg.main.package;
        }
      ];
      extraOptions = "--term xterm-256color";
    };
  };
}
