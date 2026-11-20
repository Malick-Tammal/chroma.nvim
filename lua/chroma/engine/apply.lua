local resolve = require("chroma.engine.resolve")
local palette = require("chroma.engine.palette")

local M = {}

M.current = nil
M.palette = nil

local function integration_key(module)
  return module:match("^plugins%.(.+)$") or module
end

local function require_optional(path)
  local ok, mod = pcall(require, path)
  if ok then
    return mod
  end

  local msg = tostring(mod)
  if not msg:find("module '" .. path .. "' not found", 1, true) then
    vim.notify(("[chroma] %s failed: %s"):format(path, msg), vim.log.levels.ERROR)
  end

  return nil
end

function M.load_polish(name)
  if type(name) ~= "string" then
    return {}
  end

  for _, prefix in ipairs({ "chroma.polish.", "polish." }) do
    local mod = require_optional(prefix .. name)
    if type(mod) == "table" then
      return mod
    end
  end

  return {}
end

local load_polish = M.load_polish

local TRANSPARENT_GROUPS = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "StatusLine",
  "StatusLineNC",
  "WinBar",
  "WinBarNC",
  "TabLine",
  "TabLineFill",
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "SnacksExplorerNormal",
  "NoiceCmdlinePopup",
  "NotifyINFOBody",
  "NotifyWARNBody",
  "NotifyERRORBody",
}

function M.apply(name, theme, config, opts)
  config = config or {}
  opts = opts or {}

  local p = palette.build(theme)
  local polish = theme.polish_hl or {}
  local external_polish = load_polish(name)

  if next(external_polish) then
    polish = vim.tbl_deep_extend("force", polish, external_polish)
  end

  local groups = {}
  for _, module in ipairs(require("chroma.highlights")) do
    local key = integration_key(module)
    local tbl = require("chroma.highlights." .. module)

    if polish[key] then
      tbl = vim.tbl_deep_extend("force", tbl, polish[key])
    end

    groups = vim.tbl_deep_extend("force", groups, tbl)
  end

  if config.overrides then
    local overrides = config.overrides

    if type(overrides) == "function" then
      local ok, result = pcall(overrides, p, name)
      if ok then
        overrides = result
      else
        vim.notify("[chroma] overrides failed: " .. tostring(result), vim.log.levels.ERROR)
        overrides = nil
      end
    end

    if type(overrides) == "table" then
      groups = vim.tbl_deep_extend("force", groups, overrides)
    end
  end

  if config.transparency then
    for _, group in ipairs(TRANSPARENT_GROUPS) do
      if groups[group] then
        groups[group] = vim.tbl_extend("force", groups[group], { bg = "NONE" })
      end
    end
  end

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.o.background = theme.type or p.type or "dark"

  for group, spec in pairs(groups) do
    if spec.link then
      vim.api.nvim_set_hl(0, group, { link = spec.link })
    else
      vim.api.nvim_set_hl(0, group, resolve.spec(spec, p))
    end
  end

  require("chroma.engine.terminal").set(p)

  M.current = name
  M.palette = p
  vim.g.colors_name = "ch-" .. name

  -- NOTE: :colorscheme fires ColorScheme itself after sourcing the colors/ shim.
  if opts.fire_event ~= false then
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = vim.g.colors_name })
  end

  return p
end

return M
