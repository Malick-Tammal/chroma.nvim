local resolve = require("chroma.engine.resolve")

local M = {}

local function normalize_key(key)
  return (key:gsub("^base0(%x)$", function(digit)
    return "base0" .. digit:upper()
  end))
end

local function fill(p)
  p.darker_black = p.darker_black or p.black or p.base00
  p.black = p.black or p.base00
  p.black2 = p.black2 or p.base01 or p.one_bg or p.black
  p.one_bg = p.one_bg or p.base01 or p.black2 or p.black
  p.one_bg2 = p.one_bg2 or p.base02 or p.one_bg3 or p.line or p.grey
  p.one_bg3 = p.one_bg3 or p.base03 or p.one_bg2
  p.grey = p.grey or p.base03 or p.grey_fg or p.one_bg2
  p.grey_fg = p.grey_fg or p.base04 or p.grey
  p.grey_fg2 = p.grey_fg2 or p.light_grey or p.grey_fg
  p.light_grey = p.light_grey or p.grey_fg2 or p.base05 or p.white
  p.white = p.white or p.base07 or p.base06 or p.base05
  p.line = p.line or p.base02 or p.one_bg2

  p.red = p.red or p.base08
  p.orange = p.orange or p.base09 or p.red
  p.yellow = p.yellow or p.base0A
  p.green = p.green or p.base0B
  p.cyan = p.cyan or p.base0C
  p.blue = p.blue or p.base0D
  p.purple = p.purple or p.base0E

  p.pink = p.pink or p.red
  p.baby_pink = p.baby_pink or p.pink
  p.vibrant_green = p.vibrant_green or p.green
  p.dark_purple = p.dark_purple or p.purple
  p.sun = p.sun or p.yellow
  p.teal = p.teal or p.cyan
  p.nord_blue = p.nord_blue or p.blue

  p.statusline_bg = p.statusline_bg or p.base01 or p.black2
  p.lightbg = p.lightbg or p.one_bg2
  p.pmenu_bg = p.pmenu_bg or p.blue
  p.folder_bg = p.folder_bg or p.blue

  p.base00 = p.base00 or p.black
  p.base01 = p.base01 or p.black2 or p.one_bg
  p.base02 = p.base02 or p.one_bg2
  p.base03 = p.base03 or p.one_bg3 or p.grey
  p.base04 = p.base04 or p.grey_fg
  p.base05 = p.base05 or p.white
  p.base06 = p.base06 or p.light_grey or p.white
  p.base07 = p.base07 or p.white
  p.base08 = p.base08 or p.red
  p.base09 = p.base09 or p.orange
  p.base0A = p.base0A or p.yellow
  p.base0B = p.base0B or p.green
  p.base0C = p.base0C or p.cyan
  p.base0D = p.base0D or p.blue
  p.base0E = p.base0E or p.purple
  p.base0F = p.base0F or p.orange or p.red
end

function M.build(theme)
  local p = {}

  for key, value in pairs(theme.base_30 or {}) do
    p[key] = value
  end
  for key, value in pairs(theme.base_16 or {}) do
    p[normalize_key(key)] = value
  end

  fill(p)

  p.bg = p.bg or p.black
  p.fg = p.fg or p.white
  p.type = theme.type

  -- NOTE: base_30.white can be an accent; pick whichever foreground yields higher contrast on black.
  local text = p.base05 or p.white
  if p.white and text and p.black then
    local white_ratio = resolve.ratio(p.white, p.black)
    local text_ratio = resolve.ratio(text, p.black)
    if white_ratio and text_ratio and white_ratio > text_ratio then
      text = p.white
    end
  end
  p.text = text

  return p
end

return M
