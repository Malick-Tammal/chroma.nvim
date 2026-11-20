local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local root = here .. "/.."
local chroma = require("chroma")
local resolve = require("chroma.engine.resolve")

local explicit_theme = (_G.arg and _G.arg[1] ~= "" and _G.arg[1])
  or (vim.env.THEME and vim.env.THEME ~= "" and vim.env.THEME)
  or nil

local expected_modes = {
  normal = "yellow",
  insert = "green",
  visual = "purple",
  replace = "red",
  command = "cyan",
  terminal = "orange",
}

local function check_lualine_for_theme(theme_name)
  chroma.setup({ theme = theme_name, persist = false })
  local p = chroma.palette()
  local lualine = require("chroma.engine.lualine").get(p, theme_name)
  assert(type(lualine) == "table", ("lualine.get failed for theme %s"):format(theme_name))

  for mode, key in pairs(expected_modes) do
    assert(lualine[mode], ("missing mode %s in %s"):format(mode, theme_name))
    assert(
      lualine[mode].a.bg == p[key],
      ("%s accent = %s, expected %s for %s"):format(mode, tostring(lualine[mode].a.bg), tostring(p[key]), theme_name)
    )
    assert(lualine[mode].a.fg == resolve.contrast(p[key]), mode .. " accent has the wrong foreground in " .. theme_name)
    assert(lualine[mode].b, ("missing section b in mode %s for %s"):format(mode, theme_name))
    assert(lualine[mode].c, ("missing section c in mode %s for %s"):format(mode, theme_name))
  end
  assert(
    lualine.inactive and lualine.inactive.a and lualine.inactive.b and lualine.inactive.c,
    "missing inactive sections in " .. theme_name
  )
  return p
end

local function check_features_for_theme(theme_name, p)
  -- Test standard lualine theme loader (lua/lualine/themes/chroma.lua)
  local chroma_theme = require("lualine.themes.chroma")
  assert(type(chroma_theme.normal) == "table", "chroma theme failed to resolve normal mode via index")
  assert(chroma_theme.normal.a.bg == p.yellow, "chroma theme normal.a.bg mismatch")
  local called_theme = chroma_theme()
  assert(type(called_theme.normal) == "table", "chroma theme failed to resolve when called as function")
  print("ok: lualine theme loader")

  -- Test transparency
  chroma.setup({ theme = theme_name, persist = false, transparency = true })
  local trans_theme = require("chroma.engine.lualine").get(p, theme_name)
  assert(trans_theme.normal.c.bg == "NONE", "transparency did not set normal.c.bg to NONE")
  assert(trans_theme.inactive.c.bg == "NONE", "transparency did not set inactive.c.bg to NONE")
  assert(trans_theme.inactive.a.bg == "NONE", "transparency did not set inactive.a.bg to NONE")

  -- Test lualine specific transparency override (transparency = false overrides global transparency = true)
  chroma.setup({
    theme = theme_name,
    persist = false,
    transparency = true,
    lualine = { transparency = false },
  })
  local opaque_lualine = require("chroma.engine.lualine").get(p, theme_name)
  assert(opaque_lualine.normal.c.bg ~= "NONE", "lualine transparency override failed")
  print("ok: lualine transparency")

  -- Test user overrides with semantic palette keys
  chroma.setup({
    theme = theme_name,
    persist = false,
    lualine = {
      overrides = {
        normal = {
          c = { fg = "blue", bg = "one_bg" },
        },
      },
    },
  })
  local overridden = require("chroma.engine.lualine").get(p, theme_name)
  assert(overridden.normal.c.fg == p.blue, "lualine override fg failed")
  assert(overridden.normal.c.bg == p.one_bg, "lualine override bg failed")

  -- Test user overrides as a function
  chroma.setup({
    theme = theme_name,
    persist = false,
    lualine = {
      overrides = function(pal, _)
        return {
          insert = {
            b = { fg = pal.red, bg = pal.black },
          },
        }
      end,
    },
  })
  local fn_overridden = require("chroma.engine.lualine").get(p, theme_name)
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
end

if explicit_theme then
  -- Single-theme test mode: test only the specified colorscheme
  assert(chroma.find(explicit_theme), ("theme %q not found in chroma themes"):format(tostring(explicit_theme)))
  local p = check_lualine_for_theme(explicit_theme)
  print(("ok: lualine mode accents (%s)"):format(explicit_theme))
  check_features_for_theme(explicit_theme, p)
else
  -- Full matrix mode: test ALL 99 themes for lualine mode accents, structure, and contrast
  local lib = dofile(here .. "/lib.lua")
  local themes = lib.load_themes(root .. "/lua/chroma/themes")
  for _, entry in ipairs(themes) do
    check_lualine_for_theme(entry.name)
  end
  print(("ok: lualine mode accents and structure (%d themes)"):format(#themes))

  -- Core engine feature checks using default theme "monokai-fusion"
  local default_theme = "monokai-fusion"
  chroma.setup({ theme = default_theme, persist = false })
  local p = chroma.palette()
  check_features_for_theme(default_theme, p)
end
