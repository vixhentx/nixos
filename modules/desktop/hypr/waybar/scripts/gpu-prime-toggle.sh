#!/usr/bin/env bash
set -euo pipefail

commands=("prime-offload" "prime-switch" "optimus-manager" "nvidia-prime")
for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    if [[ "$cmd" == "optimus-manager" ]]; then
      exec pkexec optimus-manager --switch nvidia
    else
      exec pkexec "$cmd"
    fi
  fi
done

notify-send "GPU Prime" "未找到可用 prime 切换命令，请安装 nvidia-prime/optimus-manager 或自定义脚本。"
