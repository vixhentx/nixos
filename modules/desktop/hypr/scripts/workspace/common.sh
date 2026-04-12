#!/usr/bin/env bash

get_focused_monitor() {
    hyprctl monitors -j 2>/dev/null \
        | jq -r '.[] | select(.focused == true) | .name' 2>/dev/null \
        | head -n1
}

get_workspace_monitor() {
    local workspace_name="$1"

    hyprctl workspaces -j 2>/dev/null \
        | jq -r --arg workspace_name "$workspace_name" '.[] | select(.name == $workspace_name) | .monitor' 2>/dev/null \
        | head -n1
}

get_workspace_selector() {
    local target_kind="$1"
    local target_workspace="$2"

    if [ "$target_kind" = "default" ]; then
        printf '%s\n' "$target_workspace"
    else
        printf 'name:%s\n' "$target_workspace"
    fi
}

summon_workspace_to_focused_monitor() {
    local target_kind="$1"
    local target_workspace="$2"
    local focused_monitor
    local current_monitor
    local workspace_selector

    focused_monitor=$(get_focused_monitor)
    if [ -z "$focused_monitor" ]; then
        return 0
    fi

    current_monitor=$(get_workspace_monitor "$target_workspace")
    if [ -z "$current_monitor" ] || [ "$current_monitor" = "$focused_monitor" ]; then
        return 0
    fi

    workspace_selector=$(get_workspace_selector "$target_kind" "$target_workspace")
    hyprctl dispatch moveworkspacetomonitor "$workspace_selector" "$focused_monitor" >/dev/null
}
