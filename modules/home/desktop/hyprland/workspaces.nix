{ config, lib, ... }:

let
  cfg = config.vix.desktop.hyprland;
  names = builtins.attrValues cfg.initialWorkspaces;
in
{
  options.vix.desktop.hyprland.initialWorkspaces = lib.mkOption {
    type = lib.types.attrsOf (lib.types.strMatching ".+");
    default = { };
    example = {
      "DP-1" = "left-1";
      "HDMI-A-3" = "main-1";
      "DP-4" = "right-1";
      "eDP-1" = "laptop-1";
    };
    description = ''
      Initial named workspace for each monitor output. Names must be unique
      and are specified without the name: prefix. Only connected, enabled
      monitors are initialized, once at Hyprland startup after applying the
      display layout. Reloads and later hotplug events do not initialize
      workspaces. Workspaces remain free to move between monitors.
    '';
  };

  config = lib.mkIf (cfg.enable && cfg.initialWorkspaces != { }) {
    assertions = [
      {
        assertion = builtins.length names == builtins.length (lib.unique names);
        message = "vix.desktop.hyprland.initialWorkspaces must use unique workspace names.";
      }
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      do
        local initial_workspaces = ${lib.generators.toLua { } cfg.initialWorkspaces}

        hl.on("hyprland.start", function()
          -- Run after all startup callbacks, including the host's display layout.
          hl.timer(function()
            hl.exec_scheduled_prop_refresh_immediately()

            local focused = hl.get_active_monitor()
            local focused_name = focused and focused.name

            for _, monitor in ipairs(hl.get_monitors()) do
              local name = initial_workspaces[monitor.name]
              if name then
                local workspace = "name:" .. name
                if hl.get_workspace(workspace) then
                  hl.dispatch(hl.dsp.workspace.move({ workspace = workspace, monitor = monitor.name }))
                end
                hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
                hl.dispatch(hl.dsp.focus({ workspace = workspace }))
              end
            end

            if focused_name then
              hl.dispatch(hl.dsp.focus({ monitor = focused_name }))
            end
          end, { timeout = 1, type = "oneshot" })
        end)
      end
    '';
  };
}
