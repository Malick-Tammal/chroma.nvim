# Theme credits

The files in this directory are vendored from
[NvChad/base46](https://github.com/NvChad/base46) at tag `v3.0`
(`lua/base46/themes/*.lua`), plus `monokai-fusion.lua` which is local.

## License

base46 is MIT licensed:

```
nvim-base16.lua is a library for modifying themes with Lua
Copyright (c) 2019 Ashkan Kiani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

The full text is in `../../LICENSE`.

## Local changes

Themes were adapted for this loader:

- removed `M = require("base46").override_theme(M, "<name>")` calls
- removed the NvChad `nvconfig`-dependent blocks in `eldritch.lua` and
  `poimandres.lua` (statusline/transparency/telescope variant logic)
- palette values may be adjusted per theme in this repository

Themes keep `polish_hl` inline, exactly as upstream ships it. Optional
per-theme polish files live in `lua/chroma/polish/<name>.lua` and are
merged after the inline table.

Themes only need `M.base_30`, `M.base_16` and `M.type`; `M.polish_hl` is
optional. Missing palette keys are derived at load time by
`lua/chroma/engine/palette.lua`.

## Individual themes

Many theme files carry their own upstream credits in the file header
(tokyonight, catppuccin, gruvbox, kanagawa, rosepine, nord, onedark, ...).
Those notices are preserved verbatim — keep them if you copy a theme onward.

`monokai-fusion.lua` is derived from Monokai Pro's palette as used by
`loctvl842/monokai-pro.nvim`.
