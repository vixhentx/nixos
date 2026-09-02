{ config, lib, pkgs, ... }:
let
  cfg = config.vix.system.ssh;
in
{
  options.vix.system.ssh = {
    enable = lib.mkEnableOption "SSH service";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = true;
      };
    };
    # Mosh support
    programs.mosh = {
      enable = true;
      openFirewall = true;
    };
    # SSH Conf
    programs.ssh = {
      setXAuthLocation = true;
      startAgent = true;
    };
    #TSSH Support
    environment.systemPackages = with pkgs; [
      tsshd
      trzsz-ssh
    ];
  };
}
