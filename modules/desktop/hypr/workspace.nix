{ config, ... }:
let
  workspScripts = "${config.xdg.configHome}/hypr/scripts/workspace";
in
{
  wayland.windowManager.hyprland.settings = {
    # --- PLUGINS (Hyprspace) ---
    # plugin = {
    #   overview = {
    #     centerAligned = true;
    #     hideTopLayers = true;
    #     hideOverlayLayers = true;
    #     showNewWorkspace = true;
    #     drawActiveWorkspace = true;
    #   };
    # };

    # --- WORKSPACE KEYBINDINGS ---
    bind = [
      # --- Rofi Dynamic Folders & Workspaces ---
      "$mainMod, Q, exec, ${workspScripts}/rofi.sh switch"
      "$mainMod SHIFT, Q, exec, ${workspScripts}/rofi.sh move"
      "$mainMod, G, exec, ${workspScripts}/rofi-folder.sh switch"
      "$mainMod SHIFT, G, exec, ${workspScripts}/rofi-folder.sh move"

      # --- HYPRSPACE PREVIEW ---
      # "$mainMod, Tab, overview:toggle"

      # --- 原路返回 (Return to previous workspace) ---
      "$mainMod, Backspace, workspace, previous"

      # --- SMART WORKSPACE GROUPS (组内漫游) ---
      # Super + 1~0: 在当前命名空间(组)内跳转
      "$mainMod, 1, exec, ${workspScripts}/action.sh switch 1"
      "$mainMod, 2, exec, ${workspScripts}/action.sh switch 2"
      "$mainMod, 3, exec, ${workspScripts}/action.sh switch 3"
      "$mainMod, 4, exec, ${workspScripts}/action.sh switch 4"
      "$mainMod, 5, exec, ${workspScripts}/action.sh switch 5"
      "$mainMod, 6, exec, ${workspScripts}/action.sh switch 6"
      "$mainMod, 7, exec, ${workspScripts}/action.sh switch 7"
      "$mainMod, 8, exec, ${workspScripts}/action.sh switch 8"
      "$mainMod, 9, exec, ${workspScripts}/action.sh switch 9"
      "$mainMod, 0, exec, ${workspScripts}/action.sh switch 10"

      # Super + Alt + 1~0: 把当前窗口移动到当前组内的1~0
      "$mainMod SHIFT, 1, exec, ${workspScripts}/action.sh move 1"
      "$mainMod SHIFT, 2, exec, ${workspScripts}/action.sh move 2"
      "$mainMod SHIFT, 3, exec, ${workspScripts}/action.sh move 3"
      "$mainMod SHIFT, 4, exec, ${workspScripts}/action.sh move 4"
      "$mainMod SHIFT, 5, exec, ${workspScripts}/action.sh move 5"
      "$mainMod SHIFT, 6, exec, ${workspScripts}/action.sh move 6"
      "$mainMod SHIFT, 7, exec, ${workspScripts}/action.sh move 7"
      "$mainMod SHIFT, 8, exec, ${workspScripts}/action.sh move 8"
      "$mainMod SHIFT, 9, exec, ${workspScripts}/action.sh move 9"
      "$mainMod SHIFT, 0, exec, ${workspScripts}/action.sh move 10"

      # --- GLOBAL OVERRIDES (强制回默认组) ---
      # Super + Shift + 1~0: 无视当前组，强制跳转回 Default (1~10)
      "$mainMod ALT, 1, exec, ${workspScripts}/action.sh switch-default 1"
      "$mainMod ALT, 2, exec, ${workspScripts}/action.sh switch-default 2"
      "$mainMod ALT, 3, exec, ${workspScripts}/action.sh switch-default 3"
      "$mainMod ALT, 4, exec, ${workspScripts}/action.sh switch-default 4"
      "$mainMod ALT, 5, exec, ${workspScripts}/action.sh switch-default 5"
      "$mainMod ALT, 6, exec, ${workspScripts}/action.sh switch-default 6"
      "$mainMod ALT, 7, exec, ${workspScripts}/action.sh switch-default 7"
      "$mainMod ALT, 8, exec, ${workspScripts}/action.sh switch-default 8"
      "$mainMod ALT, 9, exec, ${workspScripts}/action.sh switch-default 9"
      "$mainMod ALT, 0, exec, ${workspScripts}/action.sh switch-default 10"

      # Super + Ctrl + 1~0: 无视当前组，强制把窗口移动到 Default (1~10)
      "$mainMod ALT SHIFT, 1, exec, ${workspScripts}/action.sh move-default 1"
      "$mainMod ALT SHIFT, 2, exec, ${workspScripts}/action.sh move-default 2"
      "$mainMod ALT SHIFT, 3, exec, ${workspScripts}/action.sh move-default 3"
      "$mainMod ALT SHIFT, 4, exec, ${workspScripts}/action.sh move-default 4"
      "$mainMod ALT SHIFT, 5, exec, ${workspScripts}/action.sh move-default 5"
      "$mainMod ALT SHIFT, 6, exec, ${workspScripts}/action.sh move-default 6"
      "$mainMod ALT SHIFT, 7, exec, ${workspScripts}/action.sh move-default 7"
      "$mainMod ALT SHIFT, 8, exec, ${workspScripts}/action.sh move-default 8"
      "$mainMod ALT SHIFT, 9, exec, ${workspScripts}/action.sh move-default 9"
      "$mainMod ALT SHIFT, 0, exec, ${workspScripts}/action.sh move-default 10"

      # --- Scratchpad ---
      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # --- Mouse Scroll Workspaces ---
      # "$mainMod, mouse_down, workspace, e+1"
      # "$mainMod, mouse_up, workspace, e-1"
    ];
  };
}