{ config, lib, inputs, ... }:
let
  monitors = config.vix.display.monitors;
in
{
  imports = [
    # Surface 特殊硬件兼容: linux-surface 补丁内核 + 固件/热管理 (linux-surface 项目推荐路径)
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
  ];

  system.stateVersion = "26.05";

  # ── 显示器 (单点配置) ────────────────────────────────
  vix.display.monitors = [
    { output = "eDP-1"; mode = "2736x1824"; position = "0x0"; scale = 2.0; }
  ];

  # ── NixOS 层套件 ───────────────────────────────────
  vix.suites.common.enable = true;
  vix.suites.plasma.enable = true;
  vix.desktop.plasma.mobile.enable = true;
  vix.suites.apps-light.enable = true;
  vix.suites.theme-catppuccin.enable = true;
  vix.suites.gaming.enable = true;

  vix.system.network.enable = true;
  vix.system.network.proxy.enable = true;

  # ── 触控优化 ────────────────────────────────────────
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
    vix.suites.plasma.enable = true;
    vix.desktop.plasma.mobile.enable = true;
    vix.suites.apps-light.enable = true;
    vix.suites.theme-catppuccin.enable = true;
    vix.suites.desktop.enable = true; # 激活 vix.program.xdg: kdeglobals 终端/MIME/xdg-user-dirs

    # Plasma Wayland 缩放: 复用 monitors 单一来源, 由 kscreen-doctor 应用.
    vix.desktop.plasma.outputs = lib.map (m: { output = m.output; scale = m.scale; }) monitors;
    vix.suites.gaming.enable = true;
  };

  # ── 硬件 ────────────────────────────────────────────
  hardware.facter.reportPath = ./facter.json;

  # kmscon 帧缓冲 — 仅影响早期控制台显示, 与合成器无关.
  boot.kernelParams = [ "video=eDP-1:2736x1824" ];

  # ── 磁盘 (disko 声明式分区, 装机时一条命令执行) ──────
  # 单 NVMe + 单 btrfs 分区: @/@nix/@log/@home subvol + vfat ESP.
  # zramSwap 已由 performance 套件提供交换.
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
