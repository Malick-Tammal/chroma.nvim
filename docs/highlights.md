# Highlight reference

Every chroma highlight is a small table resolved against the active palette.
This page documents the spec syntax, the ways to override groups, the
non-standard groups that ship with the repository, and the integration keys
available in `polish_hl`.

- [Highlight specs](#highlight-specs)
- [Overriding highlights](#overriding-highlights)
- [Custom groups](#custom-groups)
- [Integration keys](#integration-keys)
- [Troubleshooting](#troubleshooting)

## Highlight specs

A highlight spec is a plain Lua table. These forms are supported by
`lua/chroma/engine/resolve.lua`:

```lua
{ fg = "yellow" }                  -- palette.yellow
{ bg = "NONE" }                    -- transparent background
{ fg = { "contrast", "white" } }   -- contrast-aware text over palette.white
{ bg = { "black", 12 } }           -- lighten(palette.black, 12)
{ bg = { "black", "red", 20 } }    -- mix(palette.black, palette.red, 20%)
{ link = "NormalFloat" }           -- link to another group
```

### Palette references

String values are palette keys. The engine looks them up in the resolved
palette, so `"blue"` means `palette.blue`, not the color named blue.

```lua
{
  fg = "text",       -- resolved foreground
  bg = "black2",     -- raised surface
  sp = "red",        -- undercurl/special color
}
```

`"NONE"`, `"none"`, and `"NIL"` are accepted as transparency values.

### Lighten and mix

Two-element tables lighten a color:

```lua
{ bg = { "black", 12 } }   -- palette.black lightened by 12
```

Three-element tables mix two colors by a percentage:

```lua
{ bg = { "one_bg2", "red", 18 } }   -- 18% red over one_bg2
```

### Contrast helper

Use `{ "contrast", "<color>" }` to pick readable text or icon color against a
background:

```lua
{ fg = { "contrast", "cyan" }, bg = "cyan" }
```

### Links

```lua
{ link = "Visual" }
```

Links are resolved by Neovim and are the cheapest way to keep variants in sync.

### Attributes

Any other key is passed through to `nvim_set_hl`, so the usual attributes work:

```lua
{
  fg = "red",
  bg = "black2",
  bold = true,
  italic = true,
  underline = true,
  undercurl = true,
  strikethrough = true,
  nocombine = true,
  blend = 100,
}
```

`bg_alpha` and `bg_base` are chroma-specific: they blend a background over a
base color instead of using it opaque.

```lua
{
  fg = "white",
  bg = "blue",
  bg_alpha = 0.18,   -- 18% blue
  bg_base = "black2",
}
```

## Overriding highlights

There are three layers, applied in this order:

```text
shared highlights → theme.polish_hl → polish/<theme>.lua → setup overrides → transparency
```

### Global overrides

Use `setup.overrides` in your Neovim config. It applies to every theme and
accepts a table or a function:

```lua
require("chroma").setup {
  overrides = {
    CursorLine = { bg = "one_bg" },
    FloatBorder = { fg = "blue" },
  },
}
```

```lua
require("chroma").setup {
  overrides = function(palette, theme)
    return {
      CursorLine = { bg = palette.one_bg },
      Search = { bg = { "black", 12 } },
    }
  end,
}
```

### Per-theme overrides

Use `polish_hl` in a theme file, or a separate polish file. Both are keyed by
integration name, not by highlight group:

```lua
M.polish_hl = {
  defaults = {
    CursorLine = { bg = "one_bg2" },
  },
  telescope = {
    TelescopeBorder = { fg = "darker_black" },
  },
}
```

```text
lua/chroma/polish/my-theme.lua
```

```lua
return {
  defaults = { CursorLine = { bg = "one_bg2" } },
}
```

## Custom groups

These groups are not part of the upstream plugins. They exist because chroma or
a `winhighlight` mapping references them. Define them in `overrides` or in a
theme's `polish_hl`.

### `CmpMenuBorder`

chroma ships `CmpBorder` for nvim-cmp. Some configs map the completion menu's
`FloatBorder` to `CmpMenuBorder` instead:

```lua
winhighlight = "Normal:CmpPmenu,FloatBorder:CmpMenuBorder,CursorLine:PmenuSel,Search:None"
```

`CmpMenuBorder` is not defined by chroma or nvim-cmp, so the border falls back to
the default unless you define it. Either point the mapping at the shipped group:

```lua
winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None"
```

or define it:

```lua
require("chroma").setup {
  overrides = {
    CmpMenuBorder = { fg = "one_bg2", bg = "black2" },
  },
}
```

### `SnacksPickerPromptTransparent`

Used when the snacks explorer prompt should blend into the window:

```lua
winhighlight = "FloatBorder:SnacksExplorerBorder,"
  .. "NormalFloat:SnacksExplorerNormal,"
  .. "SnacksPickerPrompt:SnacksPickerPromptTransparent,"
  .. "Title:SnacksPickerInputTitle"
```

Define it with a transparent background:

```lua
require("chroma").setup {
  overrides = {
    SnacksPickerPromptTransparent = { fg = "grey_fg2", bg = "NONE" },
  },
}
```

### `NeoTreeCursorLineNr`

Neo-tree uses `NeoTreeCursorLine` for the current line's background but does not
ship a dedicated line-number group. Some configs map `CursorLineNr` to it:

```lua
vim.opt_local.winhighlight =
  "LineNr:NeoTreeNormal,CursorLineNr:NeoTreeCursorLineNr,SignColumn:NeoTreeSignColumn"
```

Define the accent yourself:

```lua
require("chroma").setup {
  overrides = {
    NeoTreeCursorLineNr = { fg = "yellow", bold = true },
  },
}
```

### `BufferLineNeoTree`

chroma defines `BufferLineNeoTree` for the Neo-tree offset label in
bufferline.nvim:

```lua
offsets = {
  {
    filetype = "neo-tree",
    text = "Explorer",
    highlight = "BufferLineNeoTree",
  },
}
```

The shipped default is:

```lua
BufferLineNeoTree = { fg = "grey_fg2", bg = "black" }
```

Override it like any other group:

```lua
require("chroma").setup {
  overrides = {
    BufferLineNeoTree = { fg = "cyan", bg = "black2", bold = true },
  },
}
```

### `SmearCursorColor`

smear-cursor.nvim regenerates its `SmearCursor<N>` groups at draw time, so a
colorscheme cannot style the gradient. chroma ships a carrier group instead, and
smear reads its `bg`:

```lua
require("smear_cursor").setup {
  cursor_color = "SmearCursorColor",
}
```

The shipped default is `{ bg = "yellow" }`. Recolor it per theme:

```lua
M.polish_hl = {
  ["smear-cursor"] = {
    SmearCursorColor = { bg = "orange" },
  },
}
```

chroma also declares `SmearCursorHide = { fg = "text", blend = 100 }` so the
real cursor stays hidden after `:hi clear`.

### `LualineRealIcon_*`

`LualineRealIcon_<group>` names are generated at runtime by a lualine config that
re-emits icon groups on the current section background:

```lua
local name = "LualineRealIcon_" .. group:gsub("[^%w]", "_")
vim.api.nvim_set_hl(0, name, { fg = source.fg, bg = bg })
```

Do not define these by hand; the suffix depends on the source group name and is
recreated on each redraw. To change how icons look, override the source groups
instead:

```lua
require("chroma").setup {
  overrides = {
    DevIconDefault = { fg = "grey_fg2" },
    MiniIconsAzure = { fg = "blue" },
    lualine_c_normal = { bg = "black2" },
  },
}
```

## Integration keys

`polish_hl` and polish files use these keys:

| Key | File |
| --- | --- |
| `defaults` | `highlights/defaults.lua` |
| `syntax` | `highlights/syntax.lua` |
| `treesitter` | `highlights/treesitter.lua` |
| `lsp` | `highlights/lsp.lua` |
| `semantic_tokens` | `highlights/semantic_tokens.lua` |
| `telescope` | `highlights/plugins/telescope.lua` |
| `bufferline` | `highlights/plugins/bufferline.lua` |
| `cmp` | `highlights/plugins/cmp.lua` |
| `snacks` | `highlights/plugins/snacks.lua` |
| `neo-tree` | `highlights/plugins/neo-tree.lua` |
| `mini` | `highlights/plugins/mini.lua` |
| `noice` | `highlights/plugins/noice.lua` |
| `notify` | `highlights/plugins/notify.lua` |
| `yanky` | `highlights/plugins/yanky.lua` |
| `whichkey` | `highlights/plugins/whichkey.lua` |
| `render-markdown` | `highlights/plugins/render-markdown.lua` |
| `lspsaga` | `highlights/plugins/lspsaga.lua` |
| `inc-rename` | `highlights/plugins/inc-rename.lua` |
| `gitsigns` | `highlights/plugins/gitsigns.lua` |
| `flash` | `highlights/plugins/flash.lua` |
| `todo` | `highlights/plugins/todo.lua` |
| `mason` | `highlights/plugins/mason.lua` |
| `scrollbar` | `highlights/plugins/scrollbar.lua` |
| `minuet-ai` | `highlights/plugins/minuet-ai.lua` |
| `smear-cursor` | `highlights/plugins/smear-cursor.lua` |
| `lualine` | `engine/lualine.lua` |

For `lualine`, polish tables specify mode and section definitions rather than raw highlight group names. Semantic palette keys (e.g. `"one_bg"`, `"yellow"`, `"NONE"`) and contrast tuples (`{ "contrast", "accent" }`) are automatically resolved:

```lua
-- lua/chroma/polish/<theme>.lua
return {
  lualine = {
    normal = {
      b = { fg = "yellow", bg = "one_bg" },
      c = { fg = "grey_fg", bg = "black2" },
    },
  },
}
```

The most useful groups to tune are usually `CursorLine`, `CursorLineNr`,
`Visual`, `Search`, `IncSearch`, `NormalFloat`, `FloatBorder`, `WinSeparator`,
the `@`-captures under `treesitter`, and the picker titles under `telescope` and
`snacks`.

## Troubleshooting

- **A `polish_hl` key does nothing**: it must be an integration key from the
  table above. Use `setup.overrides` for raw highlight group names.
- **A group has no effect**: confirm it is the group the plugin actually reads.
  Use `:hi <Group>` and `:Inspect` on the UI element.
- **The wrong layer wins**: remember the order — shared, theme polish, polish
  file, `overrides`, transparency. Transparency resets `bg` to `NONE` on the
  listed groups.
- **A hex color does not resolve**: highlight files cannot contain raw hex
  values except for intentional constants marked with `-- hex-ok`. Put colors in
  a theme palette and reference the palette key.
- **Plugin-generated groups are overwritten**: plugins that create highlight
  groups at draw time (smear-cursor is one) win over the colorscheme. Define a
  carrier group and point the plugin at it, as with `SmearCursorColor`.
