{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.gnome;
in
{
  imports = [ ./applications.nix ];

  options.vix.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";

    mobile = {
      enable = lib.mkEnableOption "Mobile support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.defaultSession = lib.mkDefault "gnome";
    services.gnome.gcr-ssh-agent.enable = false;
    powerManagement.enable = true;
    hardware.sensor.iio.enable = cfg.mobile.enable;
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus = {
        engines = [ pkgs.ibus-engines.rime ];
        waylandFrontend = true;
      };
    };

    # GNOME provides the Wayland portal and uses IIO sensors for rotation.
    xdg.portal.enable = true;
  };
}
