{ config, pkgs, lib, ... }:
let
  cfg = config.vix.program.waydroid;
in
{
  options.vix.program.waydroid = {
    enable = lib.mkEnableOption "Waydroid support";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;

    environment.systemPackages =  with pkgs; [
      waydroid-helper 
      android-tools
    ];

    systemd = {
      packages = [ pkgs.waydroid-helper ];
      services.waydroid-mount.wantedBy = [ "multi-user.target" ];
    };
    # TODO: 添加Prop的声明配置
  };
}