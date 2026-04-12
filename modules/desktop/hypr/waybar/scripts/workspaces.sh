#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1; then
  echo '{"text": "无 Hyprland"}'
  exit 0
fi

output=$(hyprctl monitors -j 2>/dev/null | jq -r '[.[] | select(.enabled == true) | (.name + ":" + (.activeWorkspace.id // .activeWorkspace.name // "?" | tostring))] | join(" | ")' 2>/dev/null || echo "工作区: ?")
if [[ -z "$output" ]]; then
  echo '{"text": "工作区: ?"}'
else
  echo "{\"text\": \"$output\"}"
fi
