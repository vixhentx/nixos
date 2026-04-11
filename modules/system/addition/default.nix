{ pkgs, ... }:

{
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    dnsutils
    lm_sensors
    lsof
    nix-tree
    nh
    nvd
    pciutils
    strace
    usbutils
  ];

  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
}
