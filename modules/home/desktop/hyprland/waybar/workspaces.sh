#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1; then
  echo '{"text":"无 Hyprland"}'
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo '{"text":"缺少 jq"}'
  exit 0
fi

monitors_json="$(hyprctl monitors -j 2>/dev/null || echo '[]')"
workspaces_json="$(hyprctl workspaces -j 2>/dev/null || echo '[]')"

output="$(
  jq -nr \
    --argjson monitors "$monitors_json" \
    --argjson workspaces "$workspaces_json" '
        ($workspaces
          | map(select(.name? and (.name | startswith("special:") | not)))
          | map({ key: (.id | tostring), value: .name })
          | from_entries
        ) as $workspace_names
        | $monitors
        | map(select(.disabled != true))
        | sort_by(.x // 0, .id // 0)
        | map(
            $workspace_names[(.activeWorkspace.id | tostring)]
            // .activeWorkspace.name
            // ((.activeWorkspace.id // "?") | tostring)
          )
        | join(" | ")
      ' 2>/dev/null || true
)"

if [[ -z "${output// }" ]]; then
  echo '{"text":"工作区: ?"}'
  exit 0
fi

jq -cn --arg text "$output" '{text: $text}'
