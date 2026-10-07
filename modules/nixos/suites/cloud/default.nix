{ config, lib, ... }:
let 
  cfg = config.vix.suites.cloud;
in 
{
  options.vix.suites.cloud = {
    enable = lib.mkEnableOption "Enable the cloud essentials";
    efi = lib.mkEnableOption "Enable UEFI boot config";
  };

  config = lib.mkIf cfg.enable {
    vix.system.boot.enable = cfg.efi;
    services.cloud-init = {
      enable = true;
    };
    vix.suites.common.enable = true;
    vix.system.core.enable = false;
    vix.system.network = {
      enable = true;
      backend = "networkd";
    };
    networking.firewall.allowedTCPPorts = [ 22 ];

    vix.system.ssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

  };
}
