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
      # --- Rofi Dynamic Workspaces ---
      # Super + Q: 强制跳转到任意目标工作区，也支持输入新组名自动创建 <组名>-1
      # Super + Shift + Q: 强制将当前窗口移动到目标工作区，支持同样的动态创建规则
      "$mainMod, Q, exec, ${workspScripts}/rofi.sh switch"
      "$mainMod SHIFT, Q, exec, ${workspScripts}/rofi.sh move"

      # --- HYPRSPACE PREVIEW ---
      # "$mainMod, Tab, overview:toggle"

      # --- 原路返回 (Return to previous workspace) ---
      "$mainMod, Backspace, workspace, previous"

      # --- SMART WORKSPACE GROUPS (动态组内漫游) ---
      # 先用 Super + Q 输入目标组，例如 godot，会进入 godot-1
      # 然后用 Super + 1~0 在当前组内跳转到 <组名>-1 ~ <组名>-10
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

      # Super + Shift + 1~0: 把当前窗口移动到当前组内的1~0
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

      # --- Scratchpad ---
      "$mainMod, S, togglespecialworkspace, magic"
      "$mainMod SHIFT, S, movetoworkspace, special:magic"

      # --- Mouse Scroll Workspaces ---
      # "$mainMod, mouse_down, workspace, e+1"
      # "$mainMod, mouse_up, workspace, e-1"
    ];
  };
}
