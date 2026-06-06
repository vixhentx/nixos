{ config, lib, ... }:

let
  cfg = config.vix.display;
in
{
  options.vix.display = {
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          output = lib.mkOption {
            type = lib.types.str;
            description = "Connector name (e.g. eDP-1, DP-4).";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            description = "Resolution (e.g. 2560x1440).";
          };
          position = lib.mkOption {
            type = lib.types.str;
            description = "Position offset (e.g. 1600x180).";
          };
          scale = lib.mkOption {
            type = lib.types.float;
            description = "Fractional scale factor.";
          };
        };
      });
      default = [ ];
      description = ''
        Monitor configurations as the single source of truth.
        Consumed by: Hyprland compositor, SDDM greeter scaling.
      '';
    };
  };
}
