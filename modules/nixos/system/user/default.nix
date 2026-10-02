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
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" ];
      description = "Additional groups for the primary user";
    };
    hashedPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "SHA-512 hashed password";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = "Trihydra";
      extraGroups = cfg.extraGroups;
      
      shell = pkgs.zsh;
    } // lib.optionalAttrs (cfg.hashedPassword != null) {
      hashedPassword = cfg.hashedPassword;
    };

    programs.zsh.enable = true;
  };
}
