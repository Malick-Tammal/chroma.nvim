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

local function resolve_section(sec, p)
  if type(sec) ~= "table" then
    return sec
  end
  return {
    fg = sec.fg and resolve.color(sec.fg, p) or nil,
    bg = sec.bg and resolve.color(sec.bg, p) or nil,
    gui = sec.gui,
  }
end

local function resolve_mode_table(mode_tbl, p)
  local out = {}
  for sec_name, sec_val in pairs(mode_tbl) do
    out[sec_name] = resolve_section(sec_val, p)
  end
  return out
end

function M.get(p, theme_name)
  local apply_mod = require("chroma.engine.apply")
  local chroma = require("chroma")
  local config = chroma.config or require("chroma.config")

  p = p or apply_mod.palette
  if type(p) ~= "table" then
    -- INFO: Fall back to lualine's auto theme if palette is unavailable.
    return "auto"
  end

  theme_name = theme_name or apply_mod.current or config.theme

  local text = p.text or p.base05 or p.white or p.fg
  if not text then
    return "auto"
  end

  local is_transparent = config.transparency
  local lualine_cfg = config.lualine
  if type(lualine_cfg) == "table" and lualine_cfg.transparency ~= nil then
    is_transparent = lualine_cfg.transparency
  end

  local bg = p.one_bg or p.black2 or p.black or p.base00
  local bg_dark = is_transparent and "NONE" or (p.black2 or p.darker_black or p.black or p.base00)
  local fg_text = p.grey_fg2 or p.light_grey or text
  local muted = p.grey or resolve.mix(text, p.black, 35)

  local function build_mode(accent_name, fallback_name)
    local accent = pick(p, accent_name, fallback_name)
    local a_sec = accent and section(resolve.contrast(accent), accent, "bold") or section(text, bg)
    local b_sec = accent and section(accent, bg) or section(text, bg)

    return {
      a = a_sec,
      b = b_sec,
      c = section(fg_text, bg_dark),
      x = section(fg_text, bg_dark),
      y = b_sec,
      z = a_sec,
    }
  end

  local base = {
    normal = build_mode("yellow", "base0A"),
    insert = build_mode("green", "base0B"),
    visual = build_mode("purple", "base0E"),
    replace = build_mode("red", "base08"),
    command = build_mode("cyan", "base0C"),
    terminal = build_mode("orange", "base09"),
    inactive = {
      a = section(p.yellow or text, is_transparent and "NONE" or bg_dark),
      b = section(muted, is_transparent and "NONE" or bg_dark),
      c = section(muted, bg_dark),
      x = section(muted, bg_dark),
      y = section(muted, is_transparent and "NONE" or bg_dark),
      z = section(muted, is_transparent and "NONE" or (p.one_bg or bg)),
    },
  }

  -- NOTE: 1. Apply per-theme polish (from polish/<theme>.lua and theme.polish_hl.lualine).
  local polish = {}
  if type(theme_name) == "string" then
    local ext_polish = apply_mod.load_polish(theme_name)
    if type(ext_polish) == "table" and ext_polish.lualine then
      polish = vim.tbl_deep_extend("force", polish, ext_polish.lualine)
    end

    local chroma = require("chroma")
    local theme_mod = chroma.find(theme_name)
    if type(theme_mod) == "table" and type(theme_mod.polish_hl) == "table" and theme_mod.polish_hl.lualine then
      polish = vim.tbl_deep_extend("force", polish, theme_mod.polish_hl.lualine)
    end
  end

  for mode_name, mode_tbl in pairs(polish) do
    if type(mode_tbl) == "table" then
      local resolved_mode = resolve_mode_table(mode_tbl, p)
      base[mode_name] = vim.tbl_deep_extend("force", base[mode_name] or {}, resolved_mode)
    end
  end

  -- NOTE: 2. Apply user overrides (from chroma.config.lualine.overrides).
  local overrides = type(lualine_cfg) == "table" and lualine_cfg.overrides or nil
  if overrides then
    if type(overrides) == "function" then
      local ok, res = pcall(overrides, p, theme_name)
      if ok and type(res) == "table" then
        overrides = res
      else
        if not ok then
          vim.notify("[chroma] lualine overrides failed: " .. tostring(res), vim.log.levels.ERROR)
        end
        overrides = nil
      end
    end

    if type(overrides) == "table" then
      for mode_name, mode_tbl in pairs(overrides) do
        if type(mode_tbl) == "table" then
          local resolved_mode = resolve_mode_table(mode_tbl, p)
          base[mode_name] = vim.tbl_deep_extend("force", base[mode_name] or {}, resolved_mode)
        end
      end
    end
  end

  return base
end

return M
