{ config, lib, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  config = lib.mkIf (cfg.enable && cfg.mobile.enable) {
    # 触屏优先的底部 dock 面板 (仅触屏设备)
    programs.plasma.panels = [
      {
        location = "bottom";
        height = 56;
        floating = false;
        widgets = [
          { name = "org.kde.plasma.kickoff"; }
          { name = "org.kde.plasma.icontasks"; }
          { name = "org.kde.plasma.systemtray"; }
          { name = "org.kde.plasma.digitalclock"; }
        ];
      }
    ];
  };
}
