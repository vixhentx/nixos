{ pkgs, config, lib, inputs, ... }:
let
  monitors = config.vix.display.monitors;
in
{
  system.stateVersion = "26.05";

  # ── 显示器 (单点配置) ────────────────────────────────
  vix.display.monitors = [
    { output = "eDP-1"; mode = "2880x1800"; position = "0x0"; scale = 2.0; }
  ];

  vix.display.xwaylandScale = 2.0;

  # ── NixOS 层套件 ───────────────────────────────────
  vix.suites.common.enable = true;
  vix.suites.plasma.enable = true;
  vix.desktop.plasma.mobile.enable = true;
  vix.suites.apps-light.enable = true;
  vix.suites.theme-catppuccin.enable = true;
  vix.suites.gaming.enable = true;
  vix.suites.connection.enable = true;

  vix.system.user = {
    hashedPassword = "$6$d9Gm9yC5JN1CNHBQ$EXJWlW33OT8c/64ywgFHoepsmZf9M4KejwlIFdxN.6taFOHLLYWY8Z6a0tSJQ6xAFLxlzgG9LPZqZPGKfUic71";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" "docker" "wireshark" "libvirtd" "mihomo" "plugdev"];
  };
  vix.system.network.proxy.enable = true;
  vix.program.waydroid.enable = true;
  users.users.vix_hentx.openssh.authorizedKeys.keys = config.vix.keys.desktopKeys;
  services.udev.packages = [ pkgs.openocd ];
  users.groups.plugdev = {};

  hardware.sensor.iio.enable = true; # 加速度计 → qtsensors, Plasma 屏幕自动旋转
  services.libinput.touchpad = {
    tapping = true;
    naturalScrolling = true;
    disableWhileTyping = true;
  };

  # ── Home Manager ────────────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.vix_hentx = {
    vix.suites.common.enable = true;
    vix.suites.plasma.enable = true;
    vix.desktop.plasma.mobile.enable = true;
    vix.suites.apps-light.enable = true;
    vix.suites.apps-light.mobile = true;
    vix.suites.apps-heavy.enable = true;
    vix.suites.theme-catppuccin.enable = true;
    vix.suites.desktop.enable = true; # 激活 vix.program.xdg: kdeglobals 终端/MIME/xdg-user-dirs
    vix.suites.connection.enable = true;
    vix.program.kicad.enable = true;
    vix.program.distrobox.enable = true;

    vix.desktop.plasma.outputs = lib.map (m: { output = m.output; scale = m.scale; }) monitors;
    vix.suites.gaming.enable = true;
  };

  # ── 硬件 ────────────────────────────────────────────
  hardware.facter.reportPath = ./facter.json;

  # kmscon 帧缓冲 — 仅影响早期控制台显示, 与合成器无关.
  boot.kernelParams = [ "video=eDP-1:2880x1800" ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = { type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" "discard=async" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" "discard=async" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" "discard=async" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" "discard=async" ];
                };
              };
            };
          };
        };
      };
    };
  };

  swapDevices = [ ];
}
