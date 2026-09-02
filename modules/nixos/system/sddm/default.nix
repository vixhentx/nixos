{ config, lib, pkgs, ... }:

let
  cfg = config.vix.system.sddm;
in
{
  options.vix.system.sddm = {
    enable = lib.mkEnableOption "SDDM display manager";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [ "quiet" "splash" ];
      plymouth.enable = true;
    };

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = lib.mkDefault true;
      };
    };
  };
}
