{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.wireshark;
in
{
  options.vix.program.wireshark = {
    enable = lib.mkEnableOption "Wireshark network protocol analyzer";
  };

  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
