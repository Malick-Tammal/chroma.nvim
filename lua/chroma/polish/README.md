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
}
```

The table key is the highlight module name (`plugins/telescope.lua` becomes
`telescope`).
