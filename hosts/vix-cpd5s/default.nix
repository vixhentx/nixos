{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/desktop/hypr/nixos.nix
    ../../modules/dev/nvidia.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "vix-cpd5s";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Hong_Kong";

  i18n.defaultLocale = "zh_CN.UTF-8";

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  environment.systemPackages = with pkgs; [
    aria2
    curl
    git
    git-lfs
    rsync
    wget
    zsh
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  system.stateVersion = "25.11";

  services.btrfs.autoScrub.enable = true;

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
}
