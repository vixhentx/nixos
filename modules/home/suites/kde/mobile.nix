{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.kde;
in
{
  # 触屏设备专属 KDE 应用 (angelfish/koko/tokodon), 非触屏设备不装.
  # 经 default.nix 的 imports 引入, home.packages (list 类型) 自动合并.
  config = lib.mkIf cfg.mobile.enable {
    home.packages = with pkgs.kdePackages; [
      angelfish # 触屏浏览器
      koko      # 触屏图库
      tokodon   # Mastodon
    ];
  };
}
