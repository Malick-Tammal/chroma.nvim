#!/usr/bin/env bash
set -euo pipefail

# NOTE: Helper to emit ANSI color codes.
color_seq() {
    local color=$1 txt=$2
    case $color in
    red)     code=31 ;;
    green)   code=32 ;;
    yellow)  code=33 ;;
    blue)    code=34 ;;
    magenta) code=35 ;;
    cyan)    code=36 ;;
    *)       code=0  ;;
    esac
    printf "\e[${code}m%s\e[0m" "$txt"
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# NOTE: Accept an optional theme name as first argument for a selective per-theme run.
SELECTED_THEME=""
if [ "$#" -gt 0 ]; then
    SELECTED_THEME="$1"
    shift
fi

if [ -n "$SELECTED_THEME" ]; then
    export THEME="$SELECTED_THEME"
else
    unset THEME || true
fi

# NOTE: Validate the theme exists before running any tests.
if [ -n "$SELECTED_THEME" ] && [ ! -f "$ROOT/lua/chroma/themes/$SELECTED_THEME.lua" ]; then
    echo "$(color_seq red "error:") theme $(color_seq yellow "\"$SELECTED_THEME\"") not found"
    echo "       run $(color_seq cyan "./tests/run.sh") without arguments to test all themes"
    exit 1
fi

# Print static banner if it exists; otherwise fallback.
if [ -f "$(dirname "${BASH_SOURCE[0]}")/banner.txt" ]; then
    cat "$(dirname "${BASH_SOURCE[0]}")/banner.txt"
else
    echo "=== chroma tests ==="
fi

# If a specific theme was provided, show it as a subtitle under the banner.
if [ -n "$SELECTED_THEME" ]; then
    printf "                  %s\n\n" "$(color_seq green "✦  ( $SELECTED_THEME )")"
fi

# NOTE: Isolate test state from user sessions via a temporary XDG_STATE_HOME.
STATE_HOME="$(mktemp -d)"
trap 'rm -rf "$STATE_HOME"' EXIT
export XDG_STATE_HOME="$STATE_HOME"

# NOTE: Run a Lua test script under headless nvim; colorize ok:/FAIL: in output.
# WARN: Checks PIPESTATUS[0] explicitly so a failing nvim exit code is not swallowed by sed.
run() {
    local script="$1"
    shift || true
    timeout 120 nvim --headless --clean -i NONE \
        --cmd "set rtp+=$ROOT" \
        -l "$script" "$@" 2>&1 | sed \
            -e 's/ok:/\x1b[32mok:\x1b[0m/g' \
            -e 's/FAIL:/\x1b[31mFAIL:\x1b[0m/g'
    local nv_exit="${PIPESTATUS[0]}"
    if [ "$nv_exit" -ne 0 ]; then
        return "$nv_exit"
    fi
}

# NOTE: Run a named test section and print elapsed time.
PASS_COUNT=0
run_section() {
    local label="$1" script="$2"
    shift 2 || true
    echo "$(color_seq cyan "$label")"
    local start=$SECONDS
    run "$script" "$@"
    local elapsed=$(( SECONDS - start ))
    echo "   $(color_seq yellow "  ↳ ${elapsed}s")"
    PASS_COUNT=$(( PASS_COUNT + 1 ))
}

# NOTE: Shared hex-purity lint check; run in both selective and full suites.
check_hex_purity() {
    echo "$(color_seq cyan "== hex purity")"
    if grep -rn '#[0-9a-fA-F]\{6\}' \
            "$ROOT/lua/chroma/engine" \
            "$ROOT/lua/chroma/highlights" \
            "$ROOT/lua/chroma/pickers" 2>/dev/null \
        | grep -v 'hex-ok'; then
        echo "$(color_seq red "FAIL:") hex color found outside themes/ (mark intentional constants with -- hex-ok)"
        exit 1
    fi
    echo "$(color_seq green "ok")"
    PASS_COUNT=$(( PASS_COUNT + 1 ))
}

SUITE_START=$SECONDS

if [ -n "$SELECTED_THEME" ]; then
    # TEST: Selective run — palette, contrast, smoke, and lualine for the specified theme only.
    run_section "== palette check ($THEME)" "$ROOT/tests/palette_check.lua" "$SELECTED_THEME"
    run_section "== contrast ($THEME)"      "$ROOT/tests/contrast.lua" "$SELECTED_THEME"
    run_section "== smoke test ($THEME)"    "$ROOT/tests/smoke.lua" "$SELECTED_THEME"
    run_section "== lualine ($THEME)"       "$ROOT/tests/lualine.lua" "$SELECTED_THEME"
    check_hex_purity
else
    # TEST: Full suite — covers all 99 themes across all test categories.
    run_section "== all themes"        "$ROOT/tests/all_themes.lua"
    run_section "== partial palettes"  "$ROOT/tests/partial_palette.lua"
    run_section "== contrast"          "$ROOT/tests/contrast.lua"
    run_section "== persist"           "$ROOT/tests/persist.lua"
    run_section "== picker data"       "$ROOT/tests/picker_data.lua"
    run_section "== lualine"           "$ROOT/tests/lualine.lua"
    run_section "== ColorScheme events" "$ROOT/tests/events.lua"
    run_section "== commands"          "$ROOT/tests/commands.lua"
    run_section "== health"            "$ROOT/tests/health.lua"
    run_section "== transparency"      "$ROOT/tests/transparency.lua"
    run_section "== overrides"         "$ROOT/tests/overrides.lua"
    check_hex_purity
fi

TOTAL=$(( SECONDS - SUITE_START ))
echo
echo "$(color_seq green "✔  $PASS_COUNT sections passed")  $(color_seq yellow "(${TOTAL}s total)")"
