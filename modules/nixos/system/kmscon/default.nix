{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vix.system.kmscon;
  fontCfg = config.vix.system.font;
in
{
  options.vix.system.kmscon = {
    enable = lib.mkEnableOption "Kmscon as TTY replacement";
  };

  config = lib.mkIf cfg.enable {
    services.kmscon = {
      enable = true;
      hwRender = true;
      useXkbConfig = true;
      # 限制 kmscon 运行的虚拟终端，避开显示管理器通常使用的 VT7
      extraConfig = ''
        vt=1,2,3,4,5,6
      '';
      fonts = [
        {
          name = fontCfg.main.monoName;
          package = fontCfg.main.package;
        }
      ];
      extraOptions = "--term xterm-256color";
    };
  };
}
