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
      hwRender = true;
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

    # display-manager.service only Conflicts=autovt@tty1.service.
    # VT2–VT6 kmscon sessions are NOT stopped, so their framebuffer
    # (and hardware cursor) persist on top of the compositor.
    # Add Conflicts + Before on the template so every kmsconvt@
    # instance quits before the graphical session starts.
    systemd.services."kmsconvt@" = {
      conflicts = [ "display-manager.service" ];
      before = [ "display-manager.service" ];
    };
  };
}
