{ lib, pkgs, ... }:
{
  # TODO: 迁移 Home Manager 配置
  home.stateVersion = "24.05";

  vix.suites.common.enable = true;
  vix.suites.hyprland.enable = true;

  # 桌面应用
  vix.suites.apps-light.enable = true;
  vix.suites.apps-heavy.enable = true;

  vix.suites.theme-catppuccin.enable = true;
}
