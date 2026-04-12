#!/usr/bin/env bash
# 此脚本用于实现"基于当前组"的工作区跳转和移动
# 逻辑：如果当前工作区是 "Dev-xxx"，按 1 跳转到 "Dev-1"
#       如果当前工作区是 "2"，按 1 跳转到 "1"

ACTION=$1
TARGET_NUM=$2

# 获取当前工作区的名称
CUR=$(hyprctl activeworkspace -j | jq -r '.name')

# 嗅探前缀：检查当前工作区是否包含 "-"
if [[ "$CUR" == *-* ]]; then
    PREFIX="${CUR%%-*}" # 提取 "-" 前面的部分作为组名 (如 Dev)
    TARGET_NAME="${PREFIX}-${TARGET_NUM}"
    IS_NAMED=true
else
    # 如果没有 "-"，说明在 Default 组
    TARGET_NAME="$TARGET_NUM"
    IS_NAMED=false
fi

case $ACTION in
    switch)
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
    switch-default)
        # 无视组，强制跳转到 Default 组
        hyprctl dispatch workspace "$TARGET_NUM"
        ;;
    move-default)
        # 无视组，强制将窗口移动到 Default 组
        hyprctl dispatch movetoworkspace "$TARGET_NUM"
        ;;
esac