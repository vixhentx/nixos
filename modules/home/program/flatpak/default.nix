{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.flatpak;
in
{
  options.vix.program.flatpak = {
    enable = lib.mkEnableOption "Declarative flatpak applications (QQ, Feishu, WeChat, etc.)";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];

      uninstallUnmanaged = true;
    };
  };
}
