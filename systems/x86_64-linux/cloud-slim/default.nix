{ config, modulesPath, ...}:{
  imports = [
    ./disko.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];
  system.stateVersion = "26.11";
  vix.system.user = {
    enable = true;
    extraGroups = [ "wheel" "libvirtd" "mihomo" "docker" ];
  };
  vix.suites.cloud.enable = true;
  users.users.vix_hentx.openssh.authorizedKeys.keys = config.vix.keys.desktopKeys;
}
