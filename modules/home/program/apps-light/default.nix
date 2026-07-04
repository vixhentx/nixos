{ config, lib, pkgs, ... }:

let
  cfg = config.vix.program.apps-light;

  # WeChat/Feishu: Wayland broken on NVIDIA — force X11 via wrapper.
  # XWayland scaling is handled by Hyprland force_zero_scaling.
  wechat-wrapped = pkgs.symlinkJoin {
    name = "wechat-wrapped";
    paths = [ pkgs.wechat ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wechat \
        --set ELECTRON_OZONE_PLATFORM_HINT x11
    '';
  };

  feishu-wrapped = pkgs.symlinkJoin {
    name = "feishu-wrapped";
    paths = [ pkgs.feishu ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/bytedance-feishu \
        --set ELECTRON_OZONE_PLATFORM_HINT x11
    '';
  };
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
      qq
      wechat-wrapped
      feishu-wrapped

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
