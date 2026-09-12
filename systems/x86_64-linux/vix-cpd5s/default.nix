{ config, lib, ... }:
let
  # 显示器配置: 合成器、greeter 缩放等共享此来源.
  monitors = config.vix.display.monitors;

  # 为 SDDM greeter 推导缩放 — 取内置屏幕 (eDP) 的缩放值.
  primary = builtins.head (builtins.filter (m: lib.hasPrefix "eDP" m.output) monitors);
  sddmScale =
    if primary != null then primary.scale
    else if monitors != [] then (builtins.head monitors).scale
    else 1.0;
in
{
  system.stateVersion = "26.05";

  # ── 显示器 (单点配置) ────────────────────────────────
  vix.display.monitors = [
    { output = "DP-1";  mode = "1920x1080"; position = "-1280x180"; scale = 1.5; }
    { output = "eDP-1"; mode = "2560x1440"; position = "0x0";       scale = 1.6; }
    { output = "DP-4";  mode = "1920x1080"; position = "1600x180";  scale = 1.5; }
  ];

  # ── NixOS 层套件 ───────────────────────────────────
  vix.system.network.proxy.enable = true;
  vix.suites.common.enable = true;
  vix.suites.hyprland.enable = true;
  vix.suites.kde.enable = true;
  vix.suites.apps-light.enable = true;
  vix.suites.apps-heavy.enable = true;
  vix.suites.theme-catppuccin.enable = true;
  vix.suites.gaming.enable = true;

  # 设备 Profile
  vix.profiles.virtualization.enable = true;
  vix.profiles.nvidia.enable = true;

  # ── Home Manager ────────────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.vix_hentx = {
    vix.suites.hyprland.enable = true;
    vix.suites.apps-light.enable = true;
    vix.suites.apps-light.forceElectronX11 = true; # NVIDIA/Hyprland: WeChat/Feishu 强制 X11
    vix.suites.apps-heavy.enable = true;
    vix.suites.theme-catppuccin.enable = true;
    vix.suites.gaming.enable = true;
    vix.program.ai.enable = true;
    vix.profiles.nvidia.enable = true;

    wayland.windowManager.hyprland.settings.monitor = monitors;
  };

  # ── SDDM ────────────────────────────────────────────
  services.displayManager.sddm.settings.General.GreeterEnvironment =
    "QT_SCALE_FACTOR=${builtins.toString sddmScale},QT_FONT_DPI=${builtins.toString (builtins.floor (sddmScale * 96))}";

  #keyboard
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # ── 硬件 ────────────────────────────────────────────
  hardware.facter.reportPath = ./facter.json;

  # kmscon 帧缓冲 — 仅影响早期控制台显示, 与合成器无关.
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
