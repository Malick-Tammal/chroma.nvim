# AGENTS.md

Neovim 0.9+ Lua theming engine (`chroma.nvim`) with base46-compatible palettes, highlight modules, Telescope picker, and Lualine integration.

## Verification & Linting

- **Full test suite**: `bash tests/run.sh` (runs 11 headless `nvim` scripts with isolated `XDG_STATE_HOME` + hex-purity lint; CI tests Neovim `v0.9.5`, `stable`, and `nightly`).
- **Single-theme suite**: `bash tests/run.sh <theme>` (runs `palette_check`, `contrast`, `smoke`, `lualine`, and hex-purity).
  - **Gotcha**: `CONTRIBUTING.md` and `docs/themes.md` mention `THEME=<name> bash tests/run.sh`, but `tests/run.sh` explicitly `unset`s `THEME` unless passed as the positional `$1` argument.
- **Single test script**:
  ```bash
  nvim --headless --clean -i NONE --cmd "set rtp+=$PWD" -l tests/<script>.lua [theme]
  ```
- **Formatting check** (enforced in CI): `stylua --check lua/ tests/` (format with `stylua lua/ tests/`; config in `stylua.toml`: 2 spaces, 120 cols, double quotes, Unix LF).
- **Hex-purity lint** (`tests/run.sh`): `#rrggbb` literals are forbidden in `lua/chroma/engine/`, `lua/chroma/highlights/`, and `lua/chroma/pickers/`. Intentional non-theme constants (e.g., `#000000`/`#ffffff` contrast extremes) require a `-- hex-ok` comment on the same line.

## Architecture & Invariants

- **Themes are pure data**: `lua/chroma/themes/<name>.lua` returns `{ base_30, base_16, type = "dark"|"light", polish_hl? }` and must never call `nvim_set_hl`. Every shipped theme requires a matching `:colorscheme` shim at `colors/ch-<name>.lua` (`require("chroma").apply("<name>", { fire_event = false, quiet = true })`), verified by `:checkhealth chroma` and `tests/health.lua`.
- **Register every highlight module**: Adding a file under `lua/chroma/highlights/` or `lua/chroma/highlights/plugins/` has no effect until its module name is added to the ordered list in `lua/chroma/highlights/init.lua`.
- **Merge order** (`lua/chroma/engine/apply.lua`):
  `highlights/*` (in `highlights/init.lua` order) -> `theme.polish_hl` -> `lua/chroma/polish/<theme>.lua` (or `polish/<theme>.lua`) -> `config.overrides` -> `transparency`.
  - When `transparency = true`, `TRANSPARENT_GROUPS` in `apply.lua` overwrites `bg = "NONE"` last, so `polish_hl` or `overrides` cannot preserve a background on those groups.
- **Polish keying**: Both `theme.polish_hl` and `lua/chroma/polish/<theme>.lua` are keyed by integration name (`defaults`, `syntax`, `treesitter`, `lsp`, `semantic_tokens`, `lualine`, or the plugin filename without `plugins.`, e.g. `telescope`), not by raw highlight group name.
- **Highlight specs & WCAG contrast** (`lua/chroma/engine/resolve.lua`, `tests/contrast.lua`):
  - Supported values: palette key strings, `"NONE"`/`"NIL"`, `{ "<color>", <lighten_pct> }`, `{ "<c1>", "<c2>", <mix_pct> }`, `{ "contrast", "<color>" }`, `{ link = "<Group>" }`, and `bg_alpha` / `bg_base`.
  - `tests/contrast.lua` fails if `p.text` on `p.black` or any `{ "contrast", ... }` pair is below 4.5:1 (WCAG AA), or if a highlight sets literal `fg = "black"|"white"` on an accent `bg` (`white`, `yellow`, `green`, `red`, `cyan`, `purple`, `orange`, `blue`) without numeric `bg_alpha` — use `{ "contrast", "<accent>" }` instead.
- **Single `ColorScheme` event**: `lua/chroma/engine/apply.lua` owns `hi clear` and firing `ColorScheme` (once per apply; `colors/ch-*.lua` passes `fire_event = false` because `:colorscheme` fires it). Code applying themes in-place while displaying custom runtime groups (e.g., Telescope swatches in `lua/chroma/pickers/telescope.lua`) must re-define those groups after `engine.apply`.
- **Lualine**: `lua/lualine/themes/chroma.lua` delegates to `lua/chroma/engine/lualine.lua`, which merges `polish/<theme>.lua`'s `lualine` table, `theme.polish_hl.lualine`, and `config.lualine.overrides`, resolving palette tokens automatically.

## Docs & Conventions

- Keep `docs/guide.md` (Supported plugins table) updated when adding a plugin integration, and `lua/chroma/themes/CREDITS.md` updated when adding vendored themes.
- If `doc/chroma.txt` changes, regenerate `doc/tags` (`nvim --headless -c "helptags doc" -c "qa"`).
- See `CONTRIBUTING.md` for commit/PR formatting (imperative subject <72 chars, no trailing period, bulleted body, no `Co-authored-by` trailers except merge/release commits).
