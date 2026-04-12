#!/usr/bin/env bash
set -euo pipefail

record_dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
pid_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-wf-recorder.pid"
mkdir -p "$record_dir"

if [[ -f "$pid_file" ]]; then
  pid="$(cat "$pid_file")"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill -INT "$pid"
    rm -f "$pid_file"
    notify-send "Screen recording stopped" "$record_dir"
    exit 0
  fi
  rm -f "$pid_file"
fi

mode="${1:-output}"
file="$record_dir/recording-$(date +%Y%m%d-%H%M%S).mp4"

case "$mode" in
  output)
    wf-recorder -f "$file" &
    ;;
  region)
    geometry="$(slurp)"
    [[ -n "$geometry" ]] || exit 0
    wf-recorder -g "$geometry" -f "$file" &
    ;;
  *)
    notify-send "Screen recording failed" "Unknown mode: $mode"
    exit 1
    ;;
esac

echo "$!" > "$pid_file"
notify-send "Screen recording started" "$file"
