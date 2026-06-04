{ ... }:
{
  # 状态版本
  system.stateVersion = "26.05";

  # ── NixOS 层套件 ───────────────────────────────────
  vix.suites.common.enable = true;
  vix.suites.hyprland.enable = true;
  vix.suites.apps-kde.enable = true;
  vix.suites.apps-light.enable = true;
  vix.suites.apps-heavy.enable = true;
  vix.suites.theme-catppuccin.enable = true;

  # 设备 Profile
  vix.profiles.virtualization.enable = true;
  vix.profiles.nvidia.enable = true;

  # ── Home Manager ────────────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # 设备相关的用户级套件 (vix-cpd5s 专属)
  home-manager.users.vix_hentx = {
    vix.suites.hyprland.enable = true;
    vix.suites.apps-light.enable = true;
    vix.suites.apps-heavy.enable = true;
    vix.suites.theme-catppuccin.enable = true;
    vix.program.ai.enable = true;

    wayland.windowManager.hyprland.settings.monitor = [
      { output = "DP-1";  mode = "1920x1080"; position = "-1280x180"; scale = 1.5; }
      { output = "eDP-1"; mode = "2560x1440"; position = "0x0";       scale = 1.6; }
      { output = "DP-4";  mode = "1920x1080"; position = "1600x180";  scale = 1.5; }
    ];
  };

  # ── 硬件 ────────────────────────────────────────────
  hardware.facter.reportPath = ./facter.json;

  services.displayManager.sddm.settings.General.GreeterEnvironment = "QT_SCALE_FACTOR=1.5,QT_FONT_DPI=144";

  # kmscon 帧缓冲分辨率 (否则主屏幕不拉伸)
  boot.kernelParams = [ "video=eDP-1:2560x1440" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/42f56359-3293-41b2-9815-c4f7e9d34ba9";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd" "noatime" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/18AC-8C80";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/37ba61c1-9d96-4bc3-b204-c2b6b2d4bff4";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ ];
}
