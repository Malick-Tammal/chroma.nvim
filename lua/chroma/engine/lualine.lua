local resolve = require("chroma.engine.resolve")

local M = {}

local function section(fg, bg, gui)
  return { fg = fg, bg = bg, gui = gui }
end

local function pick(p, ...)
  for i = 1, select("#", ...) do
    local value = p[select(i, ...)]
    if type(value) == "string" and value:sub(1, 1) == "#" then
      return value
    end
  end
end

function M.get(p)
  p = p or require("chroma.engine.apply").palette
  if type(p) ~= "table" then
    return "auto"
  end

  local text = p.text or p.base05 or p.white or p.fg
  if not text then
    return "auto"
  end

  local muted = resolve.mix(text, p.black, 30)
  local bg = p.black2 or p.one_bg or p.black or p.base00
  local bg_dark = p.darker_black or p.black or p.base00

  local function mode(...)
    local accent = pick(p, ...)
    if not accent then
      return section(text, bg)
    end
    return section(resolve.contrast(accent), accent, "bold")
  end

  return {
    normal = {
      a = mode("yellow", "base0A"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    insert = {
      a = mode("green", "base0B"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    visual = {
      a = mode("purple", "base0E"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    replace = {
      a = mode("red", "base08"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    command = {
      a = mode("cyan", "base0C"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    terminal = {
      a = mode("orange", "base09"),
      b = section(text, bg),
      c = section(muted, bg_dark),
    },
    inactive = {
      a = section(muted, p.one_bg or bg),
      b = section(muted, bg_dark),
      c = section(muted, bg_dark),
    },
  }
end

return M
