{ pkgs, ... }:

{
  # 系统级服务
  systemd.user.services.kanshi = {
    description = "Kanshi display manager daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kanshi}/bin/kanshi";
      Restart = "always";
    };
  };
}
