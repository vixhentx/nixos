#!/usr/bin/env bash
set -euo pipefail

intel="N/A"
if [[ -r /sys/class/drm/card0/device/gpu_busy_percent ]]; then
  intel=$(< /sys/class/drm/card0/device/gpu_busy_percent)
elif [[ -r /sys/class/drm/card0/device/load ]]; then
  intel=$(awk '{print $1}' /sys/class/drm/card0/device/load 2>/dev/null || echo "N/A")
fi

nvidia="N/A"
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr '\n' '|' | sed 's/|$//' || echo "N/A")
fi

intel=${intel:-N/A}
nvidia=${nvidia:-N/A}

echo "{\"text\": \"i:$intel% n:$nvidia%\"}"
