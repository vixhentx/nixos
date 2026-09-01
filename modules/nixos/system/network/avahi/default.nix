{ config, lib, ... }:
let
  cfg = config.vix.system.network.avahi;
in
{
  options.vix.system.network.avahi = {
    enable = lib.mkEnableOption "Enable if to use avahi module to discover and be discovered.";
  };
  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
      browseDomains = ["local"];
      nssmdns = true;
    };
    services.resolved = {
      enable = true;
      settings = {
        Resolve = {
          MulticastDNS = true;
          LLMNR = true;
          DNSSEC = false;
          DNSOverTLS = false;
        };
      };
    };
  };
}
