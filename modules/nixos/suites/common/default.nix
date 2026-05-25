{ config, lib, ... }:
let
  cfg = config.vix.suites.common;
in
{
  options.vix.suites.common = {
    enable = lib.mkEnableOption "Common system-level configuration suite";
  };

  config = lib.mkIf cfg.enable {
    # 暂时为空
  };
}
