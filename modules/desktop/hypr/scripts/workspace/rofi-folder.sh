#!/usr/bin/env bash
# 此脚本实现"工作区文件夹"功能。
# 命名规范为： 文件夹名-任务名 (例如: Dev-Frontend)

ACTION=${1:-switch}

# 1. 预设你想要的文件夹分类 (格式：显示文本  真实前缀)
# 你可以根据自己的需求随意增删
FOLDERS=" Dev\n Web\n󰙯 Chat\n Media\n Games\n Misc"

# 呼出第一级菜单：选择文件夹
SELECTED_FOLDER=$(echo -e "$FOLDERS" | rofi -dmenu -p "选择分类 (Folder)" | awk '{print $2}')

# 如果未选择则退出
if [ -z "$SELECTED_FOLDER" ]; then
    exit 0
fi

# 2. 找到当前该文件夹下已经存在的具体任务工作区
# 查找以 "Dev-" 开头的工作区，并剥离 "Dev-" 前缀，只显示子任务
EXISTING=$(hyprctl workspaces -j | jq -r '.[].name' | grep "^${SELECTED_FOLDER}-" | sed "s/^${SELECTED_FOLDER}-//")

# 呼出第二级菜单：选择或输入具体任务
CHOSEN_TASK=$(echo "$EXISTING" | rofi -dmenu -p "${SELECTED_FOLDER} ❯")

if [ -z "$CHOSEN_TASK" ]; then
    exit 0
fi

# 拼接为 Hyprland 识别的最终名称
TARGET_WORKSPACE="${SELECTED_FOLDER}-${CHOSEN_TASK}"

# 3. 执行动作
if [ "$ACTION" == "move" ]; then
    hyprctl dispatch movetoworkspace name:"$TARGET_WORKSPACE"
else
    hyprctl dispatch workspace name:"$TARGET_WORKSPACE"
fi