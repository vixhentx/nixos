{ modulesPath, ...}:{
  imports = [
    ./disko.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];
  system.stateVersion = "26.11";
  vix.system.user = {
    enable = true;
    extraGroups = [ "wheel" "libvirtd" "mihomo" "docker" ];
  };
  users.users.vix_hentx.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKI8uHEvN0FJe1JzKVCp6kFJ8jHFdIuo4gjsyxEkCurf vix_hentx@vix-cpd5s"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEjjLIXU/K3yrxz8F+0s3fKifRvtuYGmpfy3cU6OWwW vix_hentx@vix-sp6"
  ];
  home-manager.users.vix_hentx = {
    config.vix.suites.common.enable = true;
  };
}