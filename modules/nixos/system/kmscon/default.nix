{
  config,
  lib,
  ...
}:
let
  cfg = config.vix.system.kmscon;
in
{
  options.vix.system.kmscon = {
    enable = lib.mkEnableOption "Kmscon as TTY replacement";
  };

  config = lib.mkIf cfg.enable {
    services.kmscon = {
      enable = true;
      hwRender = false;
      useXkbConfig = true;
      extraConfig = ''
        vt=1,2,3,4,5,6
      '';
      fonts = [
        {
          name = config.stylix.fonts.monospace.name;
          package = config.stylix.fonts.monospace.package;
        }
      ];
      extraOptions = "--term xterm-256color";
    };
  };
}
