{ config, lib, pkgs, ... }:
let
  cfg = config.vix.system.ssh;
in
{
  options.vix.system.ssh = {
    enable = lib.mkEnableOption "SSH service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto open firewall ports";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      # tssh ports
      allowedUDPPortRanges = [
        { from = 61001; to = 61999; }
      ];
    };
    services.openssh = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = {
        PermitRootLogin = "prohibit-password";
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
