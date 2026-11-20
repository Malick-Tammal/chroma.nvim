# Per-theme polish

Optional. Add `<theme-name>.lua` here to override highlight groups for one
theme only. The file is merged after the theme's inline `polish_hl`.

```lua
return {
  defaults = {
    CursorLine = { bg = "one_bg" },
  },
  telescope = {
    TelescopeBorder = { fg = "darker_black" },
  },
  lualine = {
    normal = {
      c = { fg = "grey_fg", bg = "black2" },
    },
  },
}
```

The table key is the highlight module name (`plugins/telescope.lua` becomes
`telescope`), or `lualine` for statusline mode and section customization.
Semantic palette tokens (`"one_bg"`, `"yellow"`, `"NONE"`) are automatically
resolved.
