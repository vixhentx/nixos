{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.thunderbird;
in
{
  options.vix.program.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird email client";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.thunderbird ];
  };
}
