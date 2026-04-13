#!/usr/bin/env bash
# 全局工作区选择器：
# - 输入现有工作区名，直接跳转/移动
# - 输入组名如 godot，自动进入 godot-1
# - 输入 godot-3，直接命中该组内编号

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/common.sh"

ACTION=${1:-switch}
CREATE_WORKSPACE_OPTION="新建工作区…"

normalize_group_name() {
    printf '%s' "$1" | sed -E \
        -e 's/^[[:space:]]+//' \
        -e 's/[[:space:]]+$//' \
        -e 's/[[:space:]]+/-/g' \
        -e 's/-+/-/g' \
        -e 's/^-+//' \
        -e 's/-+$//'
}

get_workspaces() {
    hyprctl workspaces -j 2>/dev/null \
        | jq -r '.[].name | select(startswith("special:") | not)' 2>/dev/null \
        | sort -u
}

dispatch_target() {
    local action="$1"
    local target_kind="$2"
    local target_workspace="$3"

    if [ "$action" = "move" ]; then
        if [ "$target_kind" = "default" ]; then
            hyprctl dispatch movetoworkspace "$target_workspace"
        else
            hyprctl dispatch movetoworkspace name:"$target_workspace"
        fi
    else
        summon_workspace_to_focused_monitor "$target_kind" "$target_workspace"

        if [ "$target_kind" = "default" ]; then
            hyprctl dispatch workspace "$target_workspace"
        else
            hyprctl dispatch workspace name:"$target_workspace"
        fi
    fi
}

resolve_target() {
    local raw_input="$1"
    local workspaces="$2"
    local input
    local group_name
    local target_num

    if printf '%s\n' "$workspaces" | grep -Fxq "$raw_input"; then
        if [[ "$raw_input" =~ ^[0-9]+$ ]]; then
            printf 'default\t%s\n' "$raw_input"
        else
            printf 'named\t%s\n' "$raw_input"
        fi
        return
    fi

    if [[ "$raw_input" =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]]; then
        printf 'default\t%s\n' "$(printf '%s' "$raw_input" | tr -d '[:space:]')"
        return
    fi

    input=$(normalize_group_name "$raw_input")
    if [ -z "$input" ]; then
        return
    fi

    if [[ "$input" =~ ^(.+)-([0-9]+)$ ]]; then
        group_name=$(normalize_group_name "${BASH_REMATCH[1]}")
        target_num="${BASH_REMATCH[2]}"

        if [ -n "$group_name" ]; then
            printf 'named\t%s-%s\n' "$group_name" "$target_num"
        fi
        return
    fi

    printf 'named\t%s-1\n' "$input"
}

prompt_workspace_picker() {
    local workspaces="$1"

    {
        printf '%s\n' "$CREATE_WORKSPACE_OPTION"
        if [ -n "$workspaces" ]; then
            printf '%s\n' "$workspaces"
        fi
    } | rofi -dmenu -i -matching fuzzy -sort \
        -p "工作区 (Workspace)" \
        -mesg "选择已有工作区；或选“新建工作区…”后输入组名 / <组名>-<编号>"
}

prompt_new_workspace() {
    rofi -dmenu -i -matching fuzzy -sort \
        -p "新建工作区" \
        -mesg "输入组名回车将进入 <组名>-1；也可直接输入 <组名>-<编号> 或数字工作区"
}

if [ "$ACTION" != "switch" ] && [ "$ACTION" != "move" ]; then
    exit 1
fi

WORKSPACES=$(get_workspaces)

RAW_INPUT=$(prompt_workspace_picker "$WORKSPACES")

if [ -z "${RAW_INPUT//[[:space:]]/}" ]; then
    exit 0
fi

if [ "$RAW_INPUT" = "$CREATE_WORKSPACE_OPTION" ]; then
    RAW_INPUT=$(prompt_new_workspace)
fi

if [ -z "${RAW_INPUT//[[:space:]]/}" ]; then
    exit 0
fi

TARGET=$(resolve_target "$RAW_INPUT" "$WORKSPACES")
if [ -z "$TARGET" ]; then
    exit 0
fi

TARGET_KIND=${TARGET%%$'\t'*}
TARGET_WORKSPACE=${TARGET#*$'\t'}

dispatch_target "$ACTION" "$TARGET_KIND" "$TARGET_WORKSPACE"
