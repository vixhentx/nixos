{ lib, pkgs, ... }:
{
  # TODO: 迁移 Home Manager 配置
  home.stateVersion = "24.05";

  vix.suites.common.enable = true;
}
