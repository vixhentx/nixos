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
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      description = "SHA-512 hashed password";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = "Trihydra";
      extraGroups = [ 
        "wheel" 
        "networkmanager" 
        "video" 
        "render"
        "audio" 
        "docker" 
        "wireshark"
        "libvirtd"
        "mihomo"
      ];
      
      # 改用 hashedPassword 确保声明式的一致性
      hashedPassword = cfg.hashedPassword;
      
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
  };
}
