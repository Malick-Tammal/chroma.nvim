-- WCAG AA (4.5:1) for body text and accents; literal black/white on vivid accents is a regression.

local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local root = here .. "/.."
local lib = dofile(here .. "/lib.lua")

local palette_mod = require("chroma.engine.palette")
local resolve = require("chroma.engine.resolve")

local explicit_theme = (_G.arg and _G.arg[1] ~= "" and _G.arg[1])
  or (vim.env.THEME and vim.env.THEME ~= "" and vim.env.THEME)
  or nil

local ACCENTS = {
  white = true,
  yellow = true,
  green = true,
  red = true,
  cyan = true,
  purple = true,
  orange = true,
  blue = true,
}

-- WCAG AA minimum contrast ratio (4.5:1) — single source of truth.
local WCAG_AA = 4.5
local MIN_NORMAL = WCAG_AA
local MIN_ACCENT = WCAG_AA

local themes
if explicit_theme then
  local chroma = require("chroma")
  assert(chroma.find(explicit_theme), ("theme %q not found in chroma themes"):format(tostring(explicit_theme)))
  local theme = require("chroma.themes." .. explicit_theme)
  themes = { { name = explicit_theme, theme = theme } }
else
  themes = lib.load_themes(root .. "/lua/chroma/themes")
end

local modules = require("chroma.highlights")
local failures = {}
local checked = 0

for _, entry in ipairs(themes) do
  if not entry.error then
    local name = entry.name
    local p = palette_mod.build(entry.theme)
    local errors = {}

    local function check(label, fg, bg, min)
      checked = checked + 1
      local ratio = resolve.ratio(fg, bg)
      if not ratio then
        errors[#errors + 1] = ("%s: %s (invalid colors %s on %s)"):format(name, label, tostring(fg), tostring(bg))
      elseif ratio < min then
        errors[#errors + 1] = ("%s: %s = %.2f:1 (< %.1f, %s on %s)"):format(name, label, ratio, min, fg, bg)
      end
    end

    check("Normal", p.text, p.black, MIN_NORMAL)

    for _, module in ipairs(modules) do
      local tbl = require("chroma.highlights." .. module)
      for group, spec in pairs(tbl) do
        if type(spec.fg) == "table" and spec.fg[1] == "contrast" then
          local accent = spec.fg[2]
          check(module .. ":" .. group, resolve.contrast(p[accent]), p[accent], MIN_ACCENT)
        elseif (spec.fg == "black" or spec.fg == "white") and ACCENTS[spec.bg] then
          if spec.bg_alpha == nil or type(spec.bg_alpha) ~= "number" then
            errors[#errors + 1] = ('%s: %s:%s uses literal fg %q on %q (use { "contrast", %q }'):format(
              name,
              module,
              group,
              spec.fg,
              spec.bg,
              spec.bg
            )
          end
        end
      end
    end

    if #errors > 0 then
      failures[#failures + 1] = { name = name, errors = errors }
    end
  end
end

if explicit_theme then
  print(("contrast: %s, %d checks"):format(explicit_theme, checked))
else
  print(("contrast: %d themes, %d checks"):format(#themes, checked))
end

if #failures > 0 then
  print(("FAIL: %d theme(s) with unreadable colors"):format(#failures))
  for _, failure in ipairs(failures) do
    print("  " .. failure.name)
    for _, line in ipairs(failure.errors) do
      print("    " .. line)
    end
  end
  vim.cmd("cq")
end

if explicit_theme then
  print(("ok: body text and accent blocks readable (%s)"):format(explicit_theme))
else
  print("ok: body text and accent blocks readable in all themes")
end
