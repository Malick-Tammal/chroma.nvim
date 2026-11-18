# User guide

This guide covers installing chroma.nvim, every configuration option, the
commands and Lua API, and the parts of Neovim that the engine touches. Inside
Neovim, `:help chroma` opens the built-in help file. For authoring a palette,
see [themes.md](themes.md). For highlight specs and custom groups, see
[highlights.md](highlights.md).

- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Lua API](#lua-api)
- [Overrides](#overrides)
- [Transparency](#transparency)
- [Persistence](#persistence)
- [`colorscheme` shims](#colorscheme-shims)
- [Theme picker](#theme-picker)
- [Lualine](#lualine)
- [Supported plugins](#supported-plugins)
- [Troubleshooting](#troubleshooting)

## Requirements

- **Neovim 0.9+**. The engine uses `vim.api.nvim_set_hl` and the `:Chroma`
  user command; `:checkhealth chroma` reports an error on older versions.
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** is
  optional and only needed for `:Chroma pick`. `apply`, `current`, `list`, and
  `reset` work without it.
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** is optional
  and enables the built-in Lualine theme.

No Node.js, language server, or external binary is required.

## Installation

### lazy.nvim

```lua
return {
  "malick-tammal/chroma.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("chroma").setup {
      theme = "monokai-fusion",
    }
  end,
}
```

`lazy = false` and the high priority make the theme available before other
plugins read highlight groups. If you load chroma later, call
`require("chroma").apply(...)` yourself.

### Local checkout

```lua
return {
  dir = "~/Projects/chroma.nvim",
  name = "chroma.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("chroma").setup {}
  end,
}
```

### Without a plugin manager

Add the repository to `runtimepath` and call `setup()` from your `init.lua`:

```lua
vim.opt.runtimepath:append("~/Projects/chroma.nvim")
require("chroma").setup { theme = "monokai-fusion" }
```

## Configuration

All options are passed to `require("chroma").setup({})`:

```lua
require("chroma").setup {
  -- Theme applied on startup when no valid saved theme exists.
  theme = "monokai-fusion",

  -- Make common backgrounds transparent.
  transparency = false,

  -- Save the active theme under stdpath("state")/chroma/current.
  -- On the next startup, the saved theme overrides `theme`.
  persist = true,

  -- Optional highlight overrides. Accepts a table or function(palette, theme).
  overrides = nil,
}
```

`setup()` merges your options over the defaults in `lua/chroma/config.lua`, so
you only need to pass what you change.

## Commands

| Command | Description |
| --- | --- |
| `:Chroma pick` | Open the Telescope picker with palette swatches |
| `:Chroma list` | List every discovered theme |
| `:Chroma apply <name>` | Apply a theme by name |
| `:Chroma current` | Print the active theme |
| `:Chroma reset` | Clear the saved theme and apply the configured default |
| `:colorscheme ch-<name>` | Apply a theme through its `colors/` shim |
| `:checkhealth chroma` | Report requirements, themes, integrations, and config problems |

Tab completion is available for `:Chroma apply <name>` and for the subcommands.

## Lua API

```lua
local chroma = require("chroma")

-- Merge options and register :Chroma (usually called once from your config).
chroma.setup {
  theme = "monokai-fusion",
  transparency = false,
  persist = true,
}

-- Apply a theme.
chroma.apply("tokyonight", {
  quiet = false,      -- false by default; true disables the notification
  persist = true,     -- false leaves the saved theme untouched
  fire_event = true,  -- false suppresses the ColorScheme event
})

-- Inspect state.
print(chroma.current())          -- "tokyonight" or nil before the first apply
print(table.concat(chroma.list(), ", "))

-- Resolved palette (after a theme has been applied).
local palette = chroma.palette()
print(palette.black, palette.red, palette.yellow)

-- Refresh the cached theme list after adding files at runtime.
chroma.refresh()

-- Look up a theme table without applying it.
local theme = chroma.find("tokyonight")
```

`chroma.apply()` throws when the theme is unknown; `chroma.setup()` reports
errors through `vim.notify` with the `chroma` title.

## Overrides

`overrides` runs after every highlight module and after theme polish. It accepts
a static table:

```lua
require("chroma").setup {
  overrides = {
    CursorLine = { bg = "one_bg" },
    FloatBorder = { fg = "blue" },
  },
}
```

Or a function that receives the resolved palette and the theme table:

```lua
require("chroma").setup {
  overrides = function(palette, theme)
    return {
      CursorLine = { bg = palette.one_bg },
      FloatBorder = { fg = palette.blue },
      -- Lighten a palette color at runtime.
      Search = { bg = { "black", 12 } },
    }
  end,
}
```

Values use the same highlight spec syntax as the built-in modules; see the
[highlight reference](highlights.md#highlight-specs).

If a function throws, chroma notifies you and skips the overrides instead of
aborting the theme switch.

## Transparency

`transparency = true` sets `bg = "NONE"` on these groups when they exist:

```text
Normal  NormalNC  NormalFloat  FloatBorder  SignColumn  StatusLine
StatusLineNC  WinBar  WinBarNC  TabLine  TabLineFill
NeoTreeNormal  NeoTreeNormalNC  SnacksExplorerNormal
NoiceCmdlinePopup  NotifyINFOBody  NotifyWARNBody  NotifyERRORBody
```

Transparency runs last, after your overrides, so an override cannot re-enable a
background for a group in this list. If you need an opaque window while keeping
transparency enabled, style a plugin-specific container group that is not listed
(for example `Pmenu` or `SnacksPickerNormal`) or keep transparency off.

Some plugins have their own transparency behavior. For smear-cursor, see the
[smear-cursor note](#smear-cursor).

## Persistence

By default, applying a theme writes its name to
`stdpath("state")/chroma/current`. On the next startup the saved theme overrides
`setup { theme = ... }`. This applies to `:Chroma apply`, `:Chroma pick`,
`:colorscheme`, and `chroma.apply()`.

```vim
:Chroma reset
```

`reset` clears the saved file and reapplies the configured default. To disable
persistence entirely:

```lua
require("chroma").setup { persist = false }
```

`chroma.apply(name, { persist = false })` skips persistence for one call.

## `colorscheme` shims

Every shipped theme has a shim in `colors/ch-<name>.lua`:

```lua
require("chroma").apply("monokai-fusion", { fire_event = false, quiet = true })
```

That allows:

```vim
:colorscheme ch-monokai-fusion
```

`fire_event = false` prevents a duplicate `ColorScheme` event, and `quiet = true`
avoids a notification. chroma fires exactly one `ColorScheme` event per theme
switch.

For a personal theme, create the shim yourself:

```text
~/.config/nvim/colors/ch-my-theme.lua
```

```lua
require("chroma").apply("my-theme", { fire_event = false, quiet = true })
```

## Theme picker

`:Chroma pick` opens a Telescope picker that shows every theme with inline
palette swatches and a live preview of the palette. It requires Telescope:

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
}
```

Without Telescope, `:Chroma list`, `:Chroma apply <name>`, `:Chroma current`,
and `:Chroma reset` still work. `:checkhealth chroma` warns when Telescope is
missing.

## Lualine

The repository includes a Lualine theme builder at `lua/chroma/engine/lualine.lua`.
Pass it as a function so it is rebuilt after each theme switch:

```lua
require("lualine").setup {
  options = {
    theme = function()
      return require("chroma.engine.lualine").get()
    end,
  },
}
```

`chroma.apply()` calls `require("lualine").refresh()` after switching, so the
statusline follows the active theme. `:checkhealth chroma` reports whether the
builder loads and returns a valid theme.

## Supported plugins

| Plugin | Integration key |
| --- | --- |
| telescope.nvim | `telescope` |
| bufferline.nvim | `bufferline` |
| nvim-cmp | `cmp` |
| snacks.nvim | `snacks` |
| neo-tree.nvim | `neo-tree` |
| mini.nvim | `mini` |
| noice.nvim | `noice` |
| nvim-notify | `notify` |
| yanky.nvim | `yanky` |
| which-key.nvim | `whichkey` |
| render-markdown.nvim | `render-markdown` |
| lspsaga.nvim | `lspsaga` |
| inc-rename.nvim | `inc-rename` |
| gitsigns.nvim | `gitsigns` |
| flash.nvim | `flash` |
| todo-comments.nvim | `todo` |
| mason.nvim | `mason` |
| nvim-scrollbar | `scrollbar` |
| minuet-ai.nvim | `minuet-ai` |
| smear-cursor.nvim | `smear-cursor` |
| lualine.nvim | `lualine` |

The integration key is also the key used in `polish_hl` and in
`lua/chroma/polish/<theme>.lua`. See the
[highlight reference](highlights.md#integration-keys) for examples.

### smear-cursor

smear-cursor.nvim computes its own colors and regenerates its
`SmearCursor<N>` groups at draw time, so a colorscheme cannot style the
gradient directly. chroma ships a carrier group instead:

```lua
require("smear_cursor").setup {
  cursor_color = "SmearCursorColor",
}
```

smear-cursor reads the `bg` of `SmearCursorColor`, so you can recolor it per
theme:

```lua
M.polish_hl = {
  ["smear-cursor"] = {
    SmearCursorColor = { bg = "orange" },
  },
}
```

chroma also declares `SmearCursorHide` so the real cursor stays hidden after
`:hi clear`.

## Troubleshooting

- **Unknown theme**: verify the file path, the theme name, and that
  `chroma.refresh()` was called after adding files at runtime. `:Chroma list`
  shows what the engine discovered.
- **`:colorscheme` says the theme does not exist**: add the matching
  `colors/ch-<theme>.lua` shim.
- **Highlight overrides do nothing**: `overrides` keys are highlight group
  names, while theme `polish_hl` keys are integration names (`defaults`,
  `telescope`, `noice`, `cmp`, `gitsigns`, ...). Check which one you are using.
- **Startup still uses a different theme**: the persisted theme takes precedence
  over `setup { theme = ... }`. Run `:Chroma reset`.
- **`overrides` function error**: chroma notifies and skips the result. Run
  `:messages` to see the error.
- **Transparency looks wrong in a float**: floats are transparent only for the
  groups listed under [Transparency](#transparency). Set an explicit `bg` in
  `overrides` for the group you want opaque.
- **Telescope picker missing**: install Telescope and run
  `:checkhealth chroma` to confirm it is found.
- **Plugin colors look unstyled**: confirm the integration key from the
  [table above](#supported-plugins) and check the plugin is loaded after the
  colorscheme.
