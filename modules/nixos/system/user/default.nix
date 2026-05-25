{ config, lib, pkgs, ... }:
let
  cfg = config.vix.system.user;
in
{
  options.vix.system.user = {
    enable = lib.mkEnableOption "Basic system user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "vix_hentx";
      description = "The primary username";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = "Trihydra";
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
      initialPassword = "vix";
    };
  };
}
