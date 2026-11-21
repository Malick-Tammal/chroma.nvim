# Contributing to chroma.nvim

Thanks for taking the time to contribute. chroma.nvim is a lightweight Neovim
theming engine with 99+ built-in base46-compatible colorschemes, so changes need
to stay small, focused, and consistent with the data-driven design. Issues and
pull requests are welcome.

## Project layout

```
lua/chroma/
  init.lua              # Public API: setup, apply, list, current, palette, refresh
  config.lua            # Defaults for require("chroma").setup()
  health.lua            # :checkhealth chroma
  persist.lua           # Saved theme in stdpath("state")/chroma/current
  engine/
    apply.lua           # Merges modules, sets highlights, fires one ColorScheme
    palette.lua         # Normalizes and fills base46-compatible palettes
    resolve.lua         # Color resolution, blending, contrast helpers
    lualine.lua         # Built-in Lualine theme
    terminal.lua        # Terminal colors
  highlights/
    init.lua            # Ordered list of highlight modules
    defaults.lua        # Neovim defaults (Normal, Cursor, ...)
    syntax.lua          # Legacy syntax groups
    treesitter.lua      # Treesitter captures
    lsp.lua             # LSP groups
    semantic_tokens.lua # Semantic tokens
    plugins/            # One file per plugin integration
  pickers/              # Telescope theme picker
  polish/               # Optional per-theme highlight overrides
  themes/               # Palette data only (one file per theme)
colors/                 # :colorscheme ch-<name> shims
doc/                    # Vim help (:help chroma)
docs/                   # User guide, theme guide, highlight reference
tests/                  # Headless test scripts + run.sh
assets/                 # Banner and preview images
```

## Requirements

- Neovim 0.9+ (the engine and tests target 0.9; `:checkhealth` reports older
  versions)
- Git
- Optional: [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim)
  for `:Chroma pick`
- Optional: [`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim) for
  the built-in Lualine theme

No Node.js, LSP, or external tooling is required.

## Local setup

Fork the repo, then clone it somewhere outside your Neovim config:

```bash
git clone https://github.com/<your-user>/chroma.nvim.git
cd chroma.nvim
```

Run the test suite from the repo root:

```bash
bash tests/run.sh
THEME=tokyonight bash tests/run.sh
```

Test against the checkout without installing it, using a clean Neovim:

```bash
nvim --headless --clean -i NONE \
  --cmd "set rtp+=$PWD" \
  -c "lua require('chroma').apply('monokai-fusion')" \
  -c "qa"
```

To dogfood it in your daily config, point Lazy at the local directory:

```lua
{
  dir = "~/Projects/chroma.nvim",
  name = "chroma.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("chroma").setup {}
  end,
}
```

Before opening a PR, check that:

- `bash tests/run.sh` passes, including the hex-purity lint
- `:checkhealth chroma` reports no new failures
- `:Chroma list`, `:Chroma pick`, and `:Chroma apply <theme>` still work
- `:colorscheme ch-<theme>` still loads and fires exactly one `ColorScheme` event
- `transparency = true` still looks correct for the themes you touched
- Persistence still round-trips: apply a theme, restart, then `:Chroma current`;
  clear it with `:Chroma reset`
- Formatting was applied with `stylua` (the repo ships a `stylua.toml`)

## Coding conventions

- **Themes are data, not code.** Palette files in `lua/chroma/themes/` contain
  only `base_30`, `base_16`, optional `type`, and optional `polish_hl`. Never
  call `nvim_set_hl` from a theme.
- **No hardcoded colors outside themes.** Engine, highlight, and picker files
  must use palette keys or derived colors. The `hex purity` test fails on
  `#rrggbb` literals; if a constant is genuinely intentional, suffix the line
  with `-- hex-ok` and explain why.
- **Highlight specs are palette references.** Use `{ fg = "yellow" }`,
  `{ bg = { "black", 12 } }` (lighten), or
  `{ bg = { "black", "red", 20 } }` (mix). Use `{ link = "Group" }` for
  aliases instead of duplicating a spec.
- **One integration per file** in `lua/chroma/highlights/plugins/`. The file name
  is the integration key used by `polish_hl` and by `:checkhealth chroma`.
- **Register every module.** A new highlight file must be added to the ordered
  list in `lua/chroma/highlights/init.lua`, or it will never be applied.
- **Respect the merge order.** Shared highlights → `theme.polish_hl` →
  `polish/<theme>.lua` → user `overrides` → transparency. Do not add
  special-case merging inside a highlight module.
- **Fire exactly one `ColorScheme` event.** `engine/apply.lua` owns this;
  integrations and modules must not fire their own.
- **Only define groups a plugin actually reads.** Plugins that generate their
  own highlight groups at draw time (e.g. smear-cursor's gradient levels) will
  overwrite colorscheme definitions. Expose a carrier group and document the
  plugin-side option instead of faking those groups.
- **Format with `stylua`** — 2-space indentation, 120-column width, double
  quotes, Unix line endings (see `stylua.toml`).
- **Do not reformat unrelated code.** A PR should diff only what it claims to
  change.
- **Keep comment style.** Use the existing header blocks and keep upstream
  credit lines in vendored theme files.

### Adding a plugin integration

```lua
-- lua/chroma/highlights/plugins/example.lua
local M = {
  ExampleNormal = { fg = "text", bg = "black" },
  ExampleMuted = { fg = "grey_fg" },
  ExampleBorder = { fg = { "blue", 12 } },
  ExampleSelection = { bg = "one_bg2", bold = true },
  ExampleAlias = { link = "ExampleNormal" },
}

return M
```

1. Add the file under `lua/chroma/highlights/plugins/`.
2. Add `"plugins.example"` to `lua/chroma/highlights/init.lua` in a sensible
   position (group it with related integrations).
3. Verify group names against the plugin's source or docs, not memory. Use the
   plugin's own defaults as the starting point.
4. Recolor it per theme with
   `polish_hl = { example = { ExampleBorder = { fg = "orange" } } }` if the
   integration needs tuning.
5. Add a row to the **Supported plugins** table in `docs/guide.md`.
6. Apply a theme with the plugin installed and check the result with `:Inspect`
   (or `:hi <Group>`), plus `:checkhealth chroma`.
7. If the plugin computes its own colors, document the required plugin-side
   option in `docs/guide.md` instead of relying on highlight groups alone.

### Adding a theme

See [docs/themes.md](docs/themes.md) for the palette schema, polish files,
testing, and the full submission checklist. In short, a theme contribution is:

1. `lua/chroma/themes/<name>.lua` — palette only, using the base46-compatible
   schema and a credit header when vendored.
2. `colors/ch-<name>.lua` — `:colorscheme` shim.
3. Optional `lua/chroma/polish/<name>.lua` — integration-keyed tweaks.
4. Optional `assets/preview/<name>/*.webp` — screenshots for the README.
5. Attribution in `lua/chroma/themes/CREDITS.md` when the palette is adapted.
6. `THEME=<name> bash tests/run.sh`, plus `:Chroma list`, `:Chroma pick`,
   `:colorscheme ch-<name>`, and `:checkhealth chroma`.

The full step-by-step, including the review checklist, is in
[docs/themes.md#submitting-a-theme](docs/themes.md#submitting-a-theme).

## Commit messages

Short, imperative, and technical. Keep messages scannable — a reader should
understand the change without opening a diff.

### Format

```
<Subject line>

- <change>
- <change>
```

### Rules

- **Subject line** — one line, under 72 characters, imperative mood ("Add", not
  "Added" or "Adds"). No trailing period. Summarize the overall goal, not a list
  of files.
- **Body** — bullet list, one bullet per logical change. Each bullet starts with
  an imperative verb (Add, Fix, Remove, Tighten, Show, Update). Group related
  changes into a single bullet when they belong together.
- **Be technical, not vague** — include concrete values, group names, and theme
  names where they matter. Avoid filler like "improve colors" or "update stuff".
- **No trailers** (`Co-authored-by`, etc.) unless it is a merge or release
  commit.

### Examples

```
Add smear-cursor integration

- Add SmearCursorHide so the real cursor stays hidden after :hi clear
- Add SmearCursorColor as a themeable carrier group for cursor_color
- Document cursor_color = "SmearCursorColor" in the README
```

```
Fix transparency for float highlights

- Reset NormalFloat bg to NONE in the transparency pass
- Add NotifyINFOBody to TRANSPARENT_GROUPS
- Cover the new group in tests/contrast.lua
```

```
Add bearded-arc theme

- Vendor base_30 and base_16 palettes with upstream credit
- Add colors/ch-bearded-arc.lua shim for :colorscheme
```

### Anti-patterns

```
improved the colors
update files
fix bugs
```

Vague, non-imperative, no technical detail — don't do this.

## Pull requests

- Branch from `main`; keep one logical change per PR.
- Use a descriptive branch name: `feat/plugin-integration`,
  `fix/transparency`, `theme/bearded-arc`, `chore/palette-cleanup`.
- Write the PR title in the same style as a commit subject, and put the bullet
  list in the description.
- State what you tested: Neovim version, OS, theme(s), and whether you checked
  transparency, persistence, and the Lualine theme.
- Add or update a test in `tests/` when fixing engine behavior; palette-only
  changes are covered by `all_themes.lua` and `palette_check.lua`.
- Keep screenshots for visual changes; store them under `assets/preview/` and
  reference them from `README.md`.

## Reporting issues

Include:

- Neovim version (`nvim --version`) and OS
- The active theme (`:Chroma current`) and whether a saved theme is involved
  (`:Chroma reset` to rule it out)
- Exact steps to reproduce, starting from a clean checkout:

  ```bash
  nvim --headless --clean -i NONE --cmd "set rtp+=$PWD" \
    -c "lua require('chroma').apply('monokai-fusion')"
  ```

- Relevant output from `:checkhealth chroma`, `:messages`, and `:hi <Group>`
- A minimal `setup {}` and any `overrides` / `polish_hl` in play
- A screenshot for color or contrast problems

## Scope and license

chroma.nvim is MIT licensed (see [LICENSE](LICENSE)). By contributing, you agree
that your changes are released under the same license. Vendored themes keep their
upstream attribution and license in the theme header and in `CREDITS.md`.
