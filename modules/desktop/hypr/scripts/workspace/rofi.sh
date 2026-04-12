#!/usr/bin/env bash
# 此脚本用于使用 Rofi 动态搜索、创建、跳转或移动窗口到特定的工作区

ACTION=${1:-switch} # 支持 "switch" (跳转) 或 "move" (将当前窗口移动到目标)

# 获取当前已经存在的命名工作区 (过滤掉 special 抽屉)
WORKSPACES=$(hyprctl workspaces -j | jq -r '.[].name' | grep -v 'special' | sort -u)

# 呼出 Rofi，如果输入的名称不在列表中，可以作为新工作区名返回
CHOSEN=$(echo "$WORKSPACES" | rofi -dmenu -p "工作区 (Workspace)")

# 如果用户按了 ESC 或者没有输入，则退出
if [ -z "$CHOSEN" ]; then
    exit 0
fi

# 根据参数执行操作
if [ "$ACTION" == "move" ]; then
    # 将当前焦点窗口移动到该工作区
    hyprctl dispatch movetoworkspace name:"$CHOSEN"
else
    # 跳转到该工作区
    hyprctl dispatch workspace name:"$CHOSEN"
fi