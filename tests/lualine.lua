local chroma = require("chroma")
local resolve = require("chroma.engine.resolve")

local name = vim.env.THEME or "monokai-fusion"
chroma.setup { theme = name, persist = false }

local p = chroma.palette()
local lualine = require("chroma.engine.lualine").get(p)

local expected = {
  normal = "yellow",
  insert = "green",
  visual = "purple",
  replace = "red",
  command = "cyan",
  terminal = "orange",
}

for mode, key in pairs(expected) do
  assert(lualine[mode].a.bg == p[key], ("%s accent = %s, expected %s"):format(mode, lualine[mode].a.bg, p[key]))
  assert(lualine[mode].a.fg == resolve.contrast(p[key]), mode .. " accent has the wrong foreground")
end

print("ok: lualine mode accents")
