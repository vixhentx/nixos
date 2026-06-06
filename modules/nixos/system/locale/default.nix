{ config, lib, ... }:
let
  cfg = config.vix.system.locale;
in
{
  options.vix.system.locale = {
    enable = lib.mkEnableOption "System locale and time configuration";
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = "Asia/Hong_Kong";

    i18n.defaultLocale = "zh_CN.UTF-8";

    # 显式声明需要生成的 locale, NixOS 默认只生成 en_US.UTF-8
    i18n.supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
      LC_ALL = "zh_CN.UTF-8";
    };

    # 某些应用需要的环境变量
    environment.sessionVariables = {
      LANG = "zh_CN.UTF-8";
      LANGUAGE = "zh_CN:zh:en_US:en";
      LC_MESSAGES = "zh_CN.UTF-8";
      LC_ALL = "zh_CN.UTF-8";
    };
  };
}
