{ ... }:

{
  imports = [
    ./hardware.nix
    ./profile.nix
  ];

  networking.hostName = "vix-cpd5s";

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  services.btrfs.autoScrub.enable = true;

  hardware.enableAllFirmware = true;

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
}
