{ modulesPath, ...}:{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    ./services.nix
  ];
  system.stateVersion = "26.11";
  vix.system.user = {
    enable = true;
    extraGroups = [ "wheel" "libvirtd" "mihomo" "docker" ];
  };
  vix.suites.cloud = {
    enable = true;
    efi = false;
  };
  users.users.vix_hentx.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKI8uHEvN0FJe1JzKVCp6kFJ8jHFdIuo4gjsyxEkCurf vix_hentx@vix-cpd5s"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEjjLIXU/K3yrxz8F+0s3fKifRvtuYGmpfy3cU6OWwW vix_hentx@vix-sp6"
  ];

  vix.secrets.enable = true;

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;
  boot.tmp.cleanOnBoot = true;

  # performance配置, 丐中丐服务器比较特殊, 就手动调了配置
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 100;
    memoryPercent = 50;
  };
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 8;
    freeSwapThreshold = 5;
    enableNotifications = true;
  };

  # boot and filesystem mount
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/vda3"; fsType = "ext4"; };
}
