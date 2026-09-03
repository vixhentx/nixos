{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  config = lib.mkIf cfg.enable {
    # 会话启动后按 monitors 单一来源应用每屏缩放 (kscreen-doctor).
    systemd.user.services.kscreen-scale = {
      Unit = {
        Description = "Apply Plasma Wayland output scale";
        After = [ "plasma-kwin_wayland.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = let
          args = lib.concatMapStringsSep " "
            (o: "output.${o.output}.scale.${builtins.toString o.scale}") cfg.outputs;
        in "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor ${args}";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
