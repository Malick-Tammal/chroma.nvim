local M = {}

local ESSENTIAL_KEYS = {
  "bg",
  "fg",
  "text",
  "black",
  "black2",
  "one_bg",
  "one_bg2",
  "grey",
  "grey_fg",
  "light_grey",
  "white",
  "red",
  "orange",
  "yellow",
  "green",
  "cyan",
  "blue",
  "purple",
  "pink",
  "teal",
  "base00",
  "base01",
  "base02",
  "base03",
  "base04",
  "base05",
  "base06",
  "base07",
  "base08",
  "base09",
  "base0A",
  "base0B",
  "base0C",
  "base0D",
  "base0E",
  "base0F",
}

local function reporter()
  local h = vim.health or require("health")
  return {
    start = h.start or h.report_start,
    ok = h.ok or h.report_ok,
    info = h.info or h.report_info,
    warn = h.warn or h.report_warn,
    error = h.error or h.report_error,
  }
end

local function version()
  local v = vim.version()
  return ("%d.%d.%d"):format(v.major, v.minor, v.patch)
end

local function is_hex(value)
  return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

local function state_file()
  return vim.fn.stdpath("state") .. "/chroma/current"
end

function M.check()
  local h = reporter()
  local chroma = require("chroma")
  local persist = require("chroma.persist")

  h.start("chroma")

  h.start("Requirements")
  if vim.fn.has("nvim-0.9") == 1 then
    h.ok("Neovim " .. version())
  else
    h.error("Neovim 0.9+ is required, found " .. version())
  end
  if pcall(require, "telescope") then
    h.ok("telescope.nvim found for `:Chroma pick`")
  else
    h.warn("telescope.nvim not found; `:Chroma pick` is unavailable (apply, current, list and reset still work)")
  end

  h.start("Setup")
  if vim.fn.exists(":Chroma") == 0 then
    h.error('`require("chroma").setup()` has not run; add it to your Neovim config')
  else
    h.ok("`setup()` ran and `:Chroma` is registered")
  end

  if chroma.find(chroma.config.theme) then
    h.ok(("configured theme `%s` found"):format(chroma.config.theme))
  else
    h.error(("configured theme `%s` does not exist; fix `theme` in setup()"):format(tostring(chroma.config.theme)))
  end

  local overrides = chroma.config.overrides
  if overrides ~= nil and type(overrides) ~= "table" and type(overrides) ~= "function" then
    h.warn(("`overrides` must be a table or a function, got %s"):format(type(overrides)))
  elseif overrides ~= nil then
    h.ok("`overrides` is a " .. type(overrides))
  end

  h.start("Commands")
  h.info("`:Chroma pick` opens the picker; `apply <name>`, `current`, `list` and `reset` are also available")

  h.start("Themes")
  local names = chroma.list()
  if #names == 0 then
    h.error("no themes found on runtimepath (expected `lua/chroma/themes/*.lua`)")
  else
    h.ok(("%d themes found"):format(#names))

    local broken = {}
    for _, name in ipairs(names) do
      if not chroma.find(name) then
        broken[#broken + 1] = name
      end
    end
    if #broken > 0 then
      h.error("these themes failed to load: " .. table.concat(broken, ", "))
    else
      h.ok("every theme file loads")
    end

    local missing = {}
    for _, name in ipairs(names) do
      if #vim.api.nvim_get_runtime_file("colors/ch-" .. name .. ".lua", false) == 0 then
        missing[#missing + 1] = "ch-" .. name
      end
    end
    if #missing > 0 then
      h.warn("no `:colorscheme` shim for: " .. table.concat(missing, ", "))
    else
      h.ok("every theme has a `colors/ch-<name>.lua` shim")
    end
  end

  h.start("Palette")
  local active = chroma.current() or chroma.config.theme
  local theme = chroma.find(active)
  local palette = chroma.palette()
  if not palette and theme then
    local ok, built = pcall(require("chroma.engine.palette").build, theme)
    if ok then
      palette = built
    end
  end

  if not palette then
    h.warn(("no palette available for `%s`"):format(tostring(active)))
  else
    local missing, bad = {}, {}
    for _, key in ipairs(ESSENTIAL_KEYS) do
      local value = palette[key]
      if value == nil then
        missing[#missing + 1] = key
      elseif not is_hex(value) then
        bad[#bad + 1] = ("%s=%s"):format(key, tostring(value))
      end
    end

    if #missing > 0 then
      h.error("missing palette keys: " .. table.concat(missing, ", "))
    else
      h.ok("essential palette keys resolved")
    end

    if #bad > 0 then
      h.warn("non-hex palette values: " .. table.concat(bad, ", "))
    end

    h.info(("background: %s (editor: %s)"):format(tostring(palette.type or "unknown"), vim.o.background))
  end

  h.start("Persistence")
  if chroma.config.persist == false then
    h.info("persistence disabled (`setup { persist = false }`)")
  else
    local path = state_file()
    local saved = persist.load()
    if not saved then
      h.info(("no saved theme at `%s`; the configured default applies on startup"):format(path))
    elseif chroma.find(saved) then
      h.ok(("saved theme `%s` at `%s`"):format(saved, path))
    else
      h.warn(("saved theme `%s` no longer exists; run `:Chroma reset` to clear `%s`"):format(saved, path))
    end
  end

  h.start("Integrations")
  local ok, lualine = pcall(require, "chroma.engine.lualine")
  if not ok then
    h.error("cannot load the lualine theme builder: " .. tostring(lualine))
  else
    local built, result = pcall(lualine.get)
    if not built then
      h.error("lualine theme builder failed: " .. tostring(result))
    elseif result == "auto" or type(result) == "table" then
      h.ok("lualine theme builder works")
    else
      h.error("lualine theme builder returned " .. type(result))
    end
  end
  if package.loaded["lualine"] then
    h.info("lualine is loaded; use `options = { theme = 'chroma' }`")
  end
end

return M
