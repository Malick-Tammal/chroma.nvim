#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export THEME="${THEME:-monokai-fusion}"

STATE_HOME="$(mktemp -d)"
trap 'rm -rf "$STATE_HOME"' EXIT
export XDG_STATE_HOME="$STATE_HOME"

run() {
  timeout 120 nvim --headless --clean -i NONE \
    --cmd "set rtp+=$ROOT" \
    -l "$1"
}

echo "== palette check ($THEME)"
run "$ROOT/tests/palette_check.lua"

echo "== smoke test ($THEME)"
run "$ROOT/tests/smoke.lua"

echo "== all themes"
run "$ROOT/tests/all_themes.lua"

echo "== partial palettes"
run "$ROOT/tests/partial_palette.lua"

echo "== contrast"
run "$ROOT/tests/contrast.lua"

echo "== persist"
run "$ROOT/tests/persist.lua"

echo "== picker data"
run "$ROOT/tests/picker_data.lua"

echo "== lualine"
run "$ROOT/tests/lualine.lua"

echo "== ColorScheme events"
run "$ROOT/tests/events.lua"

echo "== commands"
run "$ROOT/tests/commands.lua"

echo "== health"
run "$ROOT/tests/health.lua"

echo "== hex purity"
if grep -rn '#[0-9a-fA-F]\{6\}' "$ROOT/lua/chroma/engine" "$ROOT/lua/chroma/highlights" "$ROOT/lua/chroma/pickers" 2>/dev/null \
  | grep -v 'hex-ok'; then
  echo "FAIL: hex color found outside themes/ (mark intentional constants with -- hex-ok)"
  exit 1
fi
echo "ok"
