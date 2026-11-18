<div align="center">
  <img src="./assets/banner.svg" width="350" alt="chroma.nvim logo" />
</div>

<div align="center">
  ✨ Lightweight, fast, and customizable Lua theming engine for Neovim <br>
  with 99+ built-in base46-compatible colorschemes. 🎨
</div>

<br />

<p align="center">
  <a href="https://dotfyle.com/Malick-Tammal/chroma.nvim"><img src="https://img.shields.io/github/stars/malick-tammal/chroma.nvim?colorA=282922&colorB=FFD866&style=for-the-badge&cacheSeconds=4300" alt="Stars" /></a>
  <a href="https://dotfyle.com/Malick-Tammal/chroma.nvim"><img src="https://img.shields.io/github/issues/malick-tammal/chroma.nvim?colorA=282922&colorB=BCB1F5&style=for-the-badge&cacheSeconds=4300" alt="Issues" /></a>
  <a href="https://github.com/malick-tammal/chroma.nvim/contributors"><img src="https://img.shields.io/github/contributors/malick-tammal/chroma.nvim?colorA=282922&colorB=FDAD85&style=for-the-badge&cacheSeconds=4300" alt="Contributors" /></a>
  <a href="https://github.com/malick-tammal/chroma.nvim/network/members"><img src="https://img.shields.io/github/forks/malick-tammal/chroma.nvim?colorA=282922&colorB=A9DC76&style=for-the-badge&cacheSeconds=4300" alt="Forks" /></a>
</p>

---

🎨 **chroma.nvim** derives every highlight group from a small palette, so one theme
file styles syntax, Treesitter, LSP, semantic tokens, and 20+ plugin
integrations consistently. It ships with 98 themes vendored from
[NvChad/base46](https://github.com/NvChad/base46) plus `monokai-fusion`, and any
base46 theme also works.

## 📸 Preview

<details open>
<summary>⚡ <b>Monokai Fusion</b> (Default)</summary>
<br>

<img src="assets/preview/monokai-fusion/multi.png" alt="Monokai Fusion Code View" width="100%" />

<p align="center">
  <img src="assets/preview/monokai-fusion/dashboard.png" alt="Monokai Fusion Dashboard" width="49%" />
  <img src="assets/preview/monokai-fusion/picker.png" alt="Monokai Fusion Picker" width="49%" />
</p>
</details>

<details>
<summary>🌲 <b>Everforest</b></summary>
<br>

<img src="assets/preview/everforest/multi.png" alt="Everforest Code View" width="100%" />

<p align="center">
  <img src="assets/preview/everforest/dashboard.png" alt="Everforest Dashboard" width="49%" />
  <img src="assets/preview/everforest/picker.png" alt="Everforest Picker" width="49%" />
</p>
</details>

<details>
<summary>🪵 <b>Gruvbox Material</b></summary>
<br>

<img src="assets/preview/gruvbox-material/multi.png" alt="Gruvbox Material Code View" width="100%" />

<p align="center">
  <img src="assets/preview/gruvbox-material/dashboard.png" alt="Gruvbox Material Dashboard" width="49%" />
  <img src="assets/preview/gruvbox-material/picker.png" alt="Gruvbox Material Picker" width="49%" />
</p>
</details>

<details>
<summary>🌸 <b>Everblush</b></summary>
<br>

<img src="assets/preview/everblush/multi.png" alt="Everblush Code View" width="100%" />

<p align="center">
  <img src="assets/preview/everblush/dashboard.png" alt="Everblush Dashboard" width="49%" />
  <img src="assets/preview/everblush/picker.png" alt="Everblush Picker" width="49%" />
</p>
</details>

🔍 *Browse all 99+ themes with `:Chroma pick`.*

## ✨ Features

- 🎨 **99+ themes** with a base46-compatible palette schema; drop in a palette file to add your own.
- 🌈 **Data-driven highlights** for syntax, Treesitter, LSP, semantic tokens, and plugin integrations.
- 🪄 **Deep customization** with transparent backgrounds, per-theme polish, and user overrides.
- 💾 **Persistent theme selection** across restarts with `:Chroma reset` to go back to the configured default.
- 🔭 **Telescope picker** with inline palette swatches, plus a built-in Lualine theme.
- 🎯 **Clean events** with exactly one `ColorScheme` event per theme switch, so statuslines and bufferlines update naturally.

## 📋 Requirements

- Neovim 0.9+
- [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) for
  `:Chroma pick` (optional)
- [`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim) for the built-in
  Lualine theme (optional)

## 📦 Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

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

For local development, point Lazy at your checkout instead:

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

## 🚀 Quick start

```lua
require("chroma").setup {
  theme = "monokai-fusion", -- startup theme
  transparency = false,     -- set backgrounds to NONE
  persist = true,           -- remember the last applied theme
  overrides = nil,          -- table or function(palette, theme)
}
```

| Command | Description |
| --- | --- |
| 🔭 `:Chroma pick` | Open the Telescope theme picker |
| 📜 `:Chroma list` | List available themes |
| 🎨 `:Chroma apply <name>` | Apply a theme by name |
| 💡 `:Chroma current` | Print the active theme |
| 🔄 `:Chroma reset` | Clear the saved theme and use the configured default |
| 🩺 `:checkhealth chroma` | Report themes, integrations, and configuration problems |
| 🎭 `:colorscheme ch-<name>` | Load any shipped theme through its shim |

```lua
local chroma = require("chroma")

chroma.apply("tokyonight", {
  quiet = true,     -- suppress the notification
  persist = false,  -- do not save this selection
  fire_event = true -- fire ColorScheme (default)
})

print(chroma.current())
print(table.concat(chroma.list(), ", "))
print(chroma.palette().black)
```

## 📚 Documentation

| Guide | What it covers |
| --- | --- |
| 📖 [User guide](docs/guide.md) | Installation, every option, commands, Lua API, transparency, persistence, picker, Lualine, plugin integrations, troubleshooting |
| 🎨 [Theme guide](docs/themes.md) | Palette schema, writing a theme, polish files, testing, and submitting a theme to chroma.nvim |
| 🖌️ [Highlight reference](docs/highlights.md) | Highlight spec syntax, override methods, custom groups, and per-theme polish recipes |

Once installed, `:help chroma` opens the same reference inside Neovim.

## 🔌 Supported plugins

chroma.nvim ships highlights for telescope, bufferline, nvim-cmp, snacks,
neo-tree, mini.nvim, noice, nvim-notify, yanky, which-key, render-markdown,
lspsaga, inc-rename, gitsigns, flash, todo-comments, mason, nvim-scrollbar,
minuet-ai, smear-cursor, and lualine. See the
[full table](docs/guide.md#supported-plugins) for integration keys.

## 🤝 Contributing

Bug reports, plugin integrations, and new themes are welcome! Read
[CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow and
[docs/themes.md](docs/themes.md#submitting-a-theme) to contribute a theme.

## 💖 Credits

- 🎨 Palettes and theme schema: [NvChad/base46](https://github.com/NvChad/base46),
  MIT, © 2019 Ashkan Kiani — vendored at tag `v3.0`.
- ⚡ `monokai-fusion`: derived from Monokai Pro.
- 📐 HSL helpers in `lua/chroma/engine/resolve.lua` numerically match base46.

Individual theme credits live in
[`lua/chroma/themes/CREDITS.md`](lua/chroma/themes/CREDITS.md).

## 📄 License

[MIT](LICENSE).
