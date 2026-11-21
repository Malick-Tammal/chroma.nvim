# Theme guide

Themes in chroma.nvim are pure data. One palette file describes the background,
surfaces, foregrounds, and accents, and the engine derives every highlight group
from it. Themes never call `nvim_set_hl` and never need to know about plugin
integrations.

This guide covers writing a theme, tuning highlights per theme, testing it, and
submitting it to the repository. For installation and configuration, see the
[user guide](guide.md).

- [How themes work](#how-themes-work)
- [Palette schema](#palette-schema)
- [A minimal theme](#a-minimal-theme)
- [Writing a complete palette](#writing-a-complete-palette)
- [Per-theme polish](#per-theme-polish)
- [Polish files](#polish-files)
- [Personal themes](#personal-themes)
- [Testing a theme](#testing-a-theme)
- [Submitting a theme](#submitting-a-theme)
- [Common mistakes](#common-mistakes)

## How themes work

When a theme is applied, the engine:

1. Merges `base_30` and `base_16` into a flat palette.
2. Fills missing keys with sensible fallbacks (for example, `one_bg` falls back
   to `base01` or `black2`).
3. Resolves every highlight spec against the palette.
4. Merges the theme's `polish_hl`, an optional `polish/<theme>.lua` file, user
   `overrides`, and the transparency pass, in that order.
5. Calls `nvim_set_hl` for each group and fires one `ColorScheme` event.

That means a theme only has to provide colors. If a key is missing, the engine
tries to derive it; shipping a complete palette is still recommended because
derived colors can shift unexpectedly.

## Palette schema

A theme is a Lua module returning a table:

```lua
local M = {}

M.base_30 = { --[[ ... ]] }
M.base_16 = { --[[ ... ]] }
M.type = "dark" -- or "light"

-- Optional per-theme highlight tweaks.
M.polish_hl = {
  defaults = { CursorLine = { bg = "one_bg2" } },
}

return M
```

### `base_30`

The highlight-facing palette. It carries backgrounds, surfaces, foregrounds, and
accents.

```lua
M.base_30 = {
  -- Backgrounds and surfaces
  black = "#1d1e19",          -- Primary background (Normal and editor surfaces)
  darker_black = "#171814",   -- Darkest background: sidebars, gutters, floats
  black2 = "#282922",         -- Raised background: panels, secondary surfaces
  one_bg = "#2e2e29",         -- Subtle inactive background
  one_bg2 = "#3d4035",        -- Hover/selection: CursorLine, Visual, references
  one_bg3 = "#4a4e41",        -- Stronger selection: folds, search, signature help
  lightbg = "#3d4035",        -- Lighter panel/popover surface
  statusline_bg = "#33342b",  -- Statusline background
  line = "#3d4035",           -- Borders and separators
  pmenu_bg = "#ffd866",       -- Completion menu and popup selection
  folder_bg = "#78dce8",      -- Explorer folder accent

  -- Foregrounds
  white = "#FDFFF1",          -- Primary bright foreground
  light_grey = "#a7a9a2",     -- Inactive text and disabled items
  grey = "#3d4035",           -- Mid gray; also a background fallback
  grey_fg = "#606359",        -- Comments and low-emphasis punctuation
  grey_fg2 = "#84867e",       -- Separators, inactive widgets, subtle details

  -- Reds and warnings
  red = "#ff6188",            -- Errors, deletions, critical diagnostics
  baby_pink = "#ffa0b8",      -- Soft red/pink for secondary error emphasis
  pink = "#ff81a0",           -- Red-pink accent

  -- Greens and diffs
  green = "#a9dc76",          -- Success and additions
  vibrant_green = "#bae391",  -- Brighter success accent

  -- Yellows and orange
  yellow = "#ffe085",         -- Warnings
  sun = "#ffe085",            -- Warm yellow highlight
  orange = "#fc9867",         -- Tertiary accent, keywords, special operators

  -- Blues, cyan and teal
  blue = "#fc9867",           -- Primary blue accent
  nord_blue = "#48848b",      -- Desaturated blue for links and cool UI
  cyan = "#78dce8",           -- Matches, debug, address-like highlights
  teal = "#78dce8",           -- Teal accent, often an alias for cyan

  -- Purples
  purple = "#ab9df2",         -- Magenta/purple accent
  dark_purple = "#8b7fc9",    -- Deeper purple for selected variants
}
```

`base_30` keys that are missing are derived in `lua/chroma/engine/palette.lua`,
for example:

```text
darker_black → black → base00
black2       → base01 → one_bg → black
one_bg2      → base02 → one_bg3 → line → grey
grey         → base03 → grey_fg → one_bg2
light_grey   → grey_fg2 → base05 → white
red/orange/yellow/green/cyan/blue/purple → matching base16 colors
```

### `base_16`

The classic base16 semantic palette. Keys are normalized internally, so
`base0e` and `base0E` are equivalent.

```lua
M.base_16 = {
  base00 = "#1d1e19", -- Background
  base01 = "#33342b", -- Panels, statusline, separators
  base02 = "#3d4035", -- Selection and cursor background
  base03 = "#606453", -- Comments and low-emphasis foreground
  base04 = "#84867e", -- Ignored/disabled/inactive items
  base05 = "#FDFFF1", -- Ordinary text
  base06 = "#FDFFF1", -- Light foreground
  base07 = "#ffffff", -- Bright foreground
  base08 = "#ff6188", -- Red: errors, deletions
  base09 = "#fc9867", -- Orange
  base0A = "#ffd866", -- Yellow: warnings, types
  base0B = "#a9dc76", -- Green: strings, additions
  base0C = "#78dce8", -- Cyan: escapes, regex
  base0D = "#60b0ba", -- Blue: functions, methods, links
  base0E = "#ab9df2", -- Purple: keywords, constants, hints
  base0F = "#ca7a52", -- Brown/rust: base16 escape color
}
```

### `type`

`M.type` is `"dark"` or `"light"` and sets `vim.o.background` when the theme is
applied.

## A minimal theme

A palette does not need every key. The engine fills the gaps, and
`:checkhealth chroma` shows essential keys it expects.

```lua
local M = {}

M.base_30 = {
  black = "#101418",
  darker_black = "#0b0f12",
  black2 = "#151a1f",
  one_bg = "#1a2026",
  one_bg2 = "#222a32",
  white = "#e6edf3",
  light_grey = "#a8b3bd",
  grey_fg = "#6b7680",
  grey_fg2 = "#8b96a0",
  red = "#ff6b81",
  green = "#7bd88f",
  yellow = "#f2cc60",
  blue = "#6cb6ff",
  cyan = "#5ad4e6",
  purple = "#c792ea",
}

M.base_16 = {
  base00 = "#101418",
  base05 = "#e6edf3",
  base08 = "#ff6b81",
  base0A = "#f2cc60",
  base0B = "#7bd88f",
  base0C = "#5ad4e6",
  base0D = "#6cb6ff",
  base0E = "#c792ea",
}

M.type = "dark"

return M
```

Save it as `lua/chroma/themes/my-theme.lua` (or `lua/themes/my-theme.lua` for a
personal theme), then apply it:

```lua
require("chroma").apply("my-theme")
```

## Writing a complete palette

A production theme should fill all `base_30` and `base_16` keys. Use the shipped
themes as references:

```text
lua/chroma/themes/monokai-fusion.lua
lua/chroma/themes/bearded-arc.lua
lua/chroma/themes/tokyonight.lua
```

When vendoring a theme from NvChad/base46:

1. Copy the palette values, but remove
   `M = require("base46").override_theme(M, "<name>")`.
2. Remove NvChad `nvconfig`-dependent blocks (statusline, transparency, and
   Telescope variants are handled by chroma).
3. Keep the upstream credit header and add the theme to
   [`lua/chroma/themes/CREDITS.md`](../lua/chroma/themes/CREDITS.md).
4. Adjust palette values only when needed; note intentional changes.

## Per-theme polish

`M.polish_hl` overrides individual highlight groups for one theme. Keys are
integration names, matching the files in `lua/chroma/highlights/` and
`lua/chroma/highlights/plugins/`.

```lua
M.polish_hl = {
  defaults = {
    Comment = { fg = "grey_fg", italic = true },
    CursorLineNr = { fg = "orange", bold = true },
    Visual = { bg = { "one_bg2", "orange", 16 } },
    Search = { fg = "darker_black", bg = "yellow", bold = true },
    NormalFloat = { fg = "text", bg = "darker_black" },
    FloatBorder = { fg = "darker_black", bg = "darker_black" },
    WinSeparator = { fg = "line" },
  },
  treesitter = {
    ["@keyword"] = { fg = "orange", bold = true },
    ["@function"] = { fg = "blue", bold = true },
    ["@variable.parameter"] = { fg = "baby_pink", italic = true },
  },
  telescope = {
    TelescopePromptTitle = { fg = "darker_black", bg = "orange", bold = true },
    TelescopeResultsTitle = { fg = "darker_black", bg = "blue", bold = true },
    TelescopeSelection = { bg = { "one_bg2", "orange", 16 }, bold = true },
  },
  cmp = {
    CmpItemAbbrMatch = { fg = "orange", bold = true },
  },
  gitsigns = {
    GitSignsAdd = { fg = "green" },
    GitSignsChange = { fg = "blue" },
    GitSignsDelete = { fg = "red" },
  },
}
```

The snippet above is adapted from a personal theme and shows the most common
tweaks: quieter comments, an accent line number, tinted selections, opaque
floats, colored picker titles, and matching completion highlights.

Available keys:

| Key | Module |
| --- | --- |
| `defaults` | `highlights/defaults.lua` |
| `syntax` | `highlights/syntax.lua` |
| `treesitter` | `highlights/treesitter.lua` |
| `lsp` | `highlights/lsp.lua` |
| `semantic_tokens` | `highlights/semantic_tokens.lua` |
| `telescope`, `bufferline`, `cmp`, `snacks`, `neo-tree`, `mini`, `noice`, `notify`, `yanky`, `whichkey`, `render-markdown`, `lspsaga`, `inc-rename`, `gitsigns`, `flash`, `todo`, `mason`, `scrollbar`, `minuet-ai`, `smear-cursor` | `highlights/plugins/<name>.lua` |

Values use the same spec syntax as the engine. See the
[highlight reference](highlights.md#highlight-specs) for palette references,
lighten/mix tables, links, and attributes.

## Polish files

For larger tweaks, put the overrides in a separate file instead of the theme:

```text
lua/chroma/polish/my-theme.lua
```

```lua
return {
  defaults = {
    CursorLine = { bg = "one_bg" },
  },
  telescope = {
    TelescopeBorder = { fg = "darker_black" },
  },
}
```

The file name must match the theme file name, and the table is keyed by
integration name. `lua/chroma/polish/README.md` describes the same format.

The full merge order is:

```text
shared highlights → theme.polish_hl → polish/<theme>.lua → user overrides → transparency
```

## Personal themes

Themes can live outside this repository. Put them in a `themes/` folder on your
`runtimepath`:

```text
~/.config/nvim/lua/themes/my-theme.lua       -- palette
~/.config/nvim/lua/polish/my-theme.lua       -- optional polish (if supported by your setup)
~/.config/nvim/colors/ch-my-theme.lua        -- optional colorscheme shim
```

chroma searches `chroma.themes.*` and `themes.*`, so `lua/themes/my-theme.lua`
and `lua/chroma/themes/my-theme.lua` both work. After adding a file while
Neovim is running, call `require("chroma").refresh()` before `:Chroma list`.

## Testing a theme

```bash
THEME=my-theme bash tests/run.sh
```

The suite runs palette checks, smoke tests, all-theme and partial-palette
checks, contrast, persistence, picker data, Lualine, events, commands, health,
and the hex-purity lint.

Manual checks:

```vim
:Chroma apply my-theme
:Chroma current
:colorscheme ch-my-theme
:checkhealth chroma
```

Then inspect the result in a real buffer:

```vim
:Inspect
:hi CursorLine
```

Check both a code buffer and the UI: floats, Telescope, the completion menu, the
file tree, the statusline, and `:messages`. If the theme claims `type = "light"`,
verify it with `:set background=light` and confirm contrasts stay readable.

## Submitting a theme

Community themes are welcome. To add one to chroma.nvim:

1. **Fork and branch.**

   ```bash
   git clone https://github.com/<you>/chroma.nvim.git
   cd chroma.nvim
   git switch -c theme/my-theme
   ```

2. **Add the palette** at `lua/chroma/themes/my-theme.lua`. Use kebab-case for
   the name. Include `base_30`, `base_16`, `M.type`, and a credit header when the
   palette is derived from another project.

3. **Add the shim** at `colors/ch-my-theme.lua`:

   ```lua
   require("chroma").apply("my-theme", { fire_event = false, quiet = true })
   ```

4. **Add polish if needed** at `lua/chroma/polish/my-theme.lua`.

5. **Add previews** under `assets/preview/my-theme/` in WebP, for example
   `multi.webp`, `dashboard.webp`, and `picker.webp`. Use full-screen
   screenshots that show code, the statusline, and at least one float or the
   file tree. Avoid desktop backgrounds and terminal chrome.

6. **Add credits** to [`lua/chroma/themes/CREDITS.md`](../lua/chroma/themes/CREDITS.md)
   if the palette is vendored or adapted.

7. **Run the checks.**

   ```bash
   THEME=my-theme bash tests/run.sh
   ```

   Also run `:checkhealth chroma` and verify `:Chroma list`,
   `:Chroma pick`, and `:colorscheme ch-my-theme`.

8. **Open a pull request** from `theme/my-theme`. Use a subject like
   `Add my-theme` and include a bullet list of what changed, the preview
   screenshot, and what you tested (Neovim version, OS, light/dark). Follow the
   commit and PR conventions in [CONTRIBUTING.md](../CONTRIBUTING.md).

### Theme quality checklist

- Every `base_30` and `base_16` key is present, or missing keys are intentionally
  derived.
- Text stays readable on `Normal`, `CursorLine`, `Visual`, `Pmenu`, and floats.
- Diagnostics (error, warning, info, hint) are distinguishable.
- Strings, keywords, functions, types, and comments are distinguishable.
- Diffs and Git signs are clear: add, change, delete.
- The theme looks correct with `transparency = false` and with opaque floats.
- No hardcoded hex values outside the palette file.
- `:checkhealth chroma` reports no errors for the theme.
- The preview image is included and referenced from the README preview table if
  the theme is a showcase theme.

## Common mistakes

- **Polish does nothing**: the key must be an integration name (`defaults`,
  `telescope`, ...), not a highlight group name. For highlight-group keys, use
  `setup.overrides`.
- **Colors differ from the source theme**: check for derived keys. A missing
  `one_bg2` or `grey` changes many groups at once.
- **`:colorscheme` cannot find the theme**: add the `colors/ch-<name>.lua` shim.
- **Hex purity test fails**: move the literal into the theme palette. If a
  constant is deliberate, add a `-- hex-ok` comment with an explanation.
- **Light theme looks wrong**: set `M.type = "light"` and verify contrast with
  `:set background=light`.
- **Theme is not listed**: call `require("chroma").refresh()` after adding the
  file, then `:Chroma list`.
- **Transparency breaks a float**: transparency overwrites `bg` on the groups
  listed in [Transparency](guide.md#transparency). Style a group outside that
  list or turn transparency off; a polish override cannot win for a listed
  group.
