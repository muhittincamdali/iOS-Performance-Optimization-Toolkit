#!/usr/bin/env bash
# Captures the README screenshots of the PerformanceLab example app on an iPhone simulator.
#
# The script builds and installs the app, opens each screen with `-screen <name>` (which also
# runs the screen's demo: a main-thread hang, a scroll with slow rows, 150 MB of allocations,
# a leaking view model, a timed decode, a budget check), waits until the demo has finished, and
# takes a simulator screenshot in light and dark appearance with a fixed status bar. The
# figures on the screenshots are measured live on the simulator, so they differ a little from
# run to run.
#
# Usage: scripts/capture-example-screens.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.PerformanceLab"
# screen:seconds to wait for its demo to finish
screens=(hangs:5 frames:5 memory:4 leaks:7 budget:4)
output_dir="$repo_root/docs/images"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$output_dir"

echo "Building PerformanceLab for '$device'"
destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi
xcodebuild build \
  -project "$repo_root/Examples/PerformanceLab/PerformanceLab.xcodeproj" \
  -scheme PerformanceLab \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'PerformanceLab.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl install "$device" "$app"

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  for entry in "${screens[@]}"; do
    screen="${entry%%:*}"
    wait_seconds="${entry##*:}"
    # English labels and number formats whatever the simulator's language is.
    xcrun simctl launch --terminate-running-process "$device" "$bundle_id" -screen "$screen" \
      -AppleLanguages "(en)" -AppleLocale en_US >/dev/null
    sleep "$wait_seconds"
    file="$output_dir/example-$screen-$appearance.png"
    xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
    # Half the width of an iPhone 17 Pro screenshot keeps the README light.
    sips --resampleWidth 603 "$file" >/dev/null
    echo "$file"
  done
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
