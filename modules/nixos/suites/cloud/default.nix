{ config, lib, ... }:
let 
  cfg = config.vix.suites.cloud;
in 
{
  options.vix.suites.cloud = {
    enable = lib.mkEnableOption "Enable the cloud essentials";
  };

  config = lib.mkIf cfg.enable {
    services.cloud-init = {
      enable = true;
    };

    vix.system.network = {
      enable = true;
      backend = "networkd";
    };
    networking.firewall.allowedTCPPorts = [ 22 ];

    vix.system.ssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

  };
}