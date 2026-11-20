local chroma = require("chroma")
local resolve = require("chroma.engine.resolve")

-- Fixed reference theme; this integration test does not depend on THEME.
local name = "monokai-fusion"
chroma.setup({ theme = name, persist = false })

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

-- Test standard lualine theme loader (lua/lualine/themes/chroma.lua)
local chroma_theme = require("lualine.themes.chroma")
assert(type(chroma_theme.normal) == "table", "chroma theme failed to resolve normal mode via index")
assert(chroma_theme.normal.a.bg == p.yellow, "chroma theme normal.a.bg mismatch")
local called_theme = chroma_theme()
assert(type(called_theme.normal) == "table", "chroma theme failed to resolve when called as function")
print("ok: lualine theme loader")

-- Test transparency
chroma.setup({ theme = name, persist = false, transparency = true })
local trans_theme = require("chroma.engine.lualine").get(p)
assert(trans_theme.normal.c.bg == "NONE", "transparency did not set normal.c.bg to NONE")
assert(trans_theme.inactive.c.bg == "NONE", "transparency did not set inactive.c.bg to NONE")
assert(trans_theme.inactive.a.bg == "NONE", "transparency did not set inactive.a.bg to NONE")

-- Test lualine specific transparency override (transparency = false overrides global transparency = true)
chroma.setup({
  theme = name,
  persist = false,
  transparency = true,
  lualine = { transparency = false },
})
local opaque_lualine = require("chroma.engine.lualine").get(p)
assert(opaque_lualine.normal.c.bg ~= "NONE", "lualine transparency override failed")
print("ok: lualine transparency")

-- Test user overrides with semantic palette keys
chroma.setup({
  theme = name,
  persist = false,
  lualine = {
    overrides = {
      normal = {
        c = { fg = "blue", bg = "one_bg" },
      },
    },
  },
})
local overridden = require("chroma.engine.lualine").get(p)
assert(overridden.normal.c.fg == p.blue, "lualine override fg failed")
assert(overridden.normal.c.bg == p.one_bg, "lualine override bg failed")

-- Test user overrides as a function
chroma.setup({
  theme = name,
  persist = false,
  lualine = {
    overrides = function(pal, th)
      return {
        insert = {
          b = { fg = pal.red, bg = pal.black },
        },
      }
    end,
  },
})
local fn_overridden = require("chroma.engine.lualine").get(p)
assert(fn_overridden.insert.b.fg == p.red, "lualine function override fg failed")
assert(fn_overridden.insert.b.bg == p.black, "lualine function override bg failed")
print("ok: lualine user overrides")

-- Test per-theme polish
package.loaded["chroma.polish.mock_theme"] = {
  lualine = {
    normal = {
      b = { fg = "purple", bg = "one_bg" },
    },
  },
}
local polish_theme = require("chroma.engine.lualine").get(p, "mock_theme")
assert(polish_theme.normal.b.fg == p.purple, "lualine polish fg failed")
assert(polish_theme.normal.b.bg == p.one_bg, "lualine polish bg failed")
package.loaded["chroma.polish.mock_theme"] = nil
print("ok: lualine per-theme polish")
