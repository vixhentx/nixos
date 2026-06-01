{ lib, pkgs, ... }:
{
  home.stateVersion = "24.05";

  # 设备无关: 每个设备都有 shell + CLI + editor
  vix.suites.common.enable = true;

  # 其余套件由 system config 通过 home-manager.users.vix_hentx 注入,
  # 这样 homes/ 配置可在 vix-cpd5s 和 vix-sp6 之间共享.
}
