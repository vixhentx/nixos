{ config, lib, ... }:
let
  cfg = config.vix.system.nix;
in
{
  options.vix.system.nix = {
    enable = lib.mkEnableOption "Nix core settings";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # 优化下载与存储
      builders-use-substitutes = true;
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      connect-timeout = 20;
      stalled-download-timeout = 300;
      max-jobs = "auto";
      netrc-file = "/etc/nix/netrc";
    };

    # 自动化垃圾回收
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # 定期优化存储层
    nix.optimise.automatic = true;

    nixpkgs.config.allowUnfree = true;
  };
}
