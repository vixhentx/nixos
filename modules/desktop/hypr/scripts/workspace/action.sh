#!/usr/bin/env bash
# 此脚本用于实现"基于当前组"的工作区跳转和移动
# 逻辑：如果当前工作区是 "godot-3"，按 1 跳转到 "godot-1"
#       如果当前工作区是 "2"，按 1 跳转到 "1"

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/common.sh"

ACTION=$1
TARGET_NUM=$2

# 获取当前工作区的名称
CUR=$(hyprctl activeworkspace -j | jq -r '.name')

# 嗅探前缀：仅当工作区名符合 "<组名>-<编号>" 时才视为命名组
if [[ "$CUR" =~ ^(.+)-([0-9]+)$ ]]; then
    PREFIX="${BASH_REMATCH[1]}"
    TARGET_NAME="${PREFIX}-${TARGET_NUM}"
    IS_NAMED=true
else
    # 如果没有 "-"，说明在 Default 组
    TARGET_NAME="$TARGET_NUM"
    IS_NAMED=false
fi

case $ACTION in
    switch)
        summon_workspace_to_focused_monitor \
            "$([ "$IS_NAMED" = true ] && printf 'named' || printf 'default')" \
            "$TARGET_NAME"

        # 组内跳转
        if [ "$IS_NAMED" = true ]; then
            hyprctl dispatch workspace name:"$TARGET_NAME"
        else
            hyprctl dispatch workspace "$TARGET_NAME"
        fi
        ;;
    move)
        # 将窗口移动到组内编号
        if [ "$IS_NAMED" = true ]; then
            hyprctl dispatch movetoworkspace name:"$TARGET_NAME"
        else
            hyprctl dispatch movetoworkspace "$TARGET_NAME"
        fi
        ;;
esac
