{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.apps-light;
in
{
  options.vix.program.apps-light = {
    enable = lib.mkEnableOption "DE-agnostic lightweight desktop applications";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Chat (universal)
      element-desktop
      telegram-desktop

      # Internet (universal)
      localsend
      motrix-next

      # Media (universal, not DE-specific)
      mpv
      netease-cloud-music-gtk

      # Audio infrastructure
      ffmpeg
      alsa-utils
      pamixer

      # System monitor
      mission-center
      wl-color-picker
    ];

    # Flatpak
    vix.program.flatpak.enable = true;
    services.flatpak.packages = [
      { appId = "com.qq.QQ";            origin = "flathub"; }
      { appId = "cn.feishu.Feishu";     origin = "flathub"; }
      { appId = "com.tencent.WeChat";   origin = "flathub"; }
    ];

    # MIME: text/code → nvim (DE-agnostic default)
    # application/* types with known specific handlers are excluded.
    xdg.mimeApps.defaultApplications = {
      "text/*"                           = [ "nvim.desktop" ];
      "application/json"                 = [ "nvim.desktop" ];
      "application/xml"                  = [ "nvim.desktop" ];
      "application/javascript"           = [ "nvim.desktop" ];
      "application/x-yaml"               = [ "nvim.desktop" ];
      "application/x-shellscript"        = [ "nvim.desktop" ];
      "application/x-nix"                = [ "nvim.desktop" ];
      "application/x-toml"               = [ "nvim.desktop" ];
      "application/x-wine-extension-ini" = [ "nvim.desktop" ];
      "application/x-wine-extension-txt" = [ "nvim.desktop" ];
    };
  };
}
