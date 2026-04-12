#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$screenshot_dir"

mode="${1:-region}"
file="$screenshot_dir/screenshot-$(date +%Y%m%d-%H%M%S).png"

case "$mode" in
  output)
    grim "$file"
    ;;
  region)
    geometry="$(slurp)"
    [[ -n "$geometry" ]] || exit 0
    grim -g "$geometry" "$file"
    ;;
  *)
    notify-send "Screenshot failed" "Unknown mode: $mode"
    exit 1
    ;;
esac

wl-copy --type image/png < "$file"
notify-send "Screenshot saved" "$file"
