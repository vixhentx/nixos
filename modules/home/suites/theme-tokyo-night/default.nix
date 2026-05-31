{ config, lib, ... }:

let
  cfg = config.vix.suites.theme-tokyo-night;
in
{
  options.vix.suites.theme-tokyo-night = {
    enable = lib.mkEnableOption "Tokyo Night home theme suite";
  };

  config = lib.mkIf cfg.enable {
    # Tokyo Night 无 catppuccin/nix 模块 — Stylix 自动处理所有应用主题
    # Hyprland 边框颜色由 stylix.targets.hyprland 自动处理
    # 光标由 stylix.cursor (NixOS suite) 处理
    home.sessionVariables = {
      HYPRCURSOR_THEME = config.stylix.cursor.name;
      HYPRCURSOR_SIZE = toString config.stylix.cursor.size;
    };
  };
}
