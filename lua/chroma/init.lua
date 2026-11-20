local M = {}

M.config = require("chroma.config")

local engine = require("chroma.engine.apply")
local persist = require("chroma.persist")

-- PERF: Cache discovered runtime themes to avoid repeated filesystem traversals.
local theme_cache

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "chroma" })
end

local function require_theme(path)
  local ok, mod = pcall(require, path)
  if ok then
    return type(mod) == "table" and mod or nil
  end

  local msg = tostring(mod)
  if not msg:find("module '" .. path .. "' not found", 1, true) then
    notify(("[chroma] %s failed: %s"):format(path, msg), vim.log.levels.ERROR)
  end

  return nil
end

local function find_theme(name)
  if type(name) ~= "string" or name == "" then
    return nil
  end

  for _, prefix in ipairs({ "chroma.themes.", "themes." }) do
    local theme = require_theme(prefix .. name)
    if theme then
      return theme
    end
  end

  return nil
end

function M.find(name)
  return find_theme(name)
end

function M.list()
  if theme_cache then
    return theme_cache
  end

  local seen, out = {}, {}
  for _, pattern in ipairs({ "lua/chroma/themes/*.lua", "lua/themes/*.lua" }) do
    for _, file in ipairs(vim.api.nvim_get_runtime_file(pattern, true)) do
      local name = vim.fn.fnamemodify(file, ":t:r")
      if not seen[name] then
        seen[name] = true
        out[#out + 1] = name
      end
    end
  end

  table.sort(out)
  theme_cache = out
  return out
end

function M.refresh()
  theme_cache = nil
  return M
end

local function apply_theme(name, opts)
  opts = opts or {}
  name = name or M.config.theme

  local theme = M.find(name)
  if not theme then
    return nil, ("unknown theme %q (known: %s)"):format(tostring(name), table.concat(M.list(), ", "))
  end

  local ok, err = pcall(engine.apply, name, theme, M.config, { fire_event = opts.fire_event })
  if not ok then
    return nil, ("failed to apply %s: %s"):format(name, tostring(err))
  end

  if opts.persist ~= false and M.config.persist ~= false then
    persist.save(name)
  end

  return name
end

function M.apply(name, opts)
  opts = opts or {}
  local applied, err = apply_theme(name, opts)
  if not applied then
    error("[chroma] " .. err, 2)
  end

  if not opts.quiet then
    notify("Theme set to: " .. applied)
  end

  vim.cmd("redrawstatus!")
  vim.cmd("silent! lua require('lualine').refresh()")

  return M
end

function M.current()
  return engine.current
end

function M.palette()
  return engine.palette
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", require("chroma.config"), opts or {})

  local startup_theme = M.config.theme
  if M.config.persist ~= false then
    local saved = persist.load()
    if saved and M.find(saved) then
      startup_theme = saved
    elseif saved then
      persist.clear()
    end
  end

  if vim.fn.exists(":Chroma") == 0 then
    local subcommands = { "pick", "apply", "current", "list", "reset" }

    local function cmd_words(line)
      local words = {}
      for word in line:gmatch("%S+") do
        words[#words + 1] = word
      end
      return words
    end

    local function complete_prefix(items, lead)
      local out = {}
      lead = (lead or ""):lower()
      for _, item in ipairs(items) do
        if vim.startswith(item:lower(), lead) then
          out[#out + 1] = item
        end
      end
      return out
    end

    vim.api.nvim_create_user_command("Chroma", function(args)
      local sub = args.fargs[1]

      if sub == nil then
        notify("usage: :Chroma pick | apply <name> | current | list | reset", vim.log.levels.WARN)
      elseif sub == "pick" then
        -- TODO: Add support for alternative pickers (e.g. snacks.picker or fzf-lua).
        require("chroma.pickers.telescope").pick()
      elseif sub == "current" then
        notify("current: " .. tostring(M.current()))
      elseif sub == "list" then
        notify("themes: " .. table.concat(M.list(), ", "))
      elseif sub == "apply" then
        if not args.fargs[2] then
          notify("usage: :Chroma apply <name>", vim.log.levels.ERROR)
          return
        end
        M.apply(args.fargs[2])
      elseif sub == "reset" then
        persist.clear()
        local applied, err = apply_theme(M.config.theme, { persist = false })
        if applied then
          notify("cleared saved theme; using default: " .. applied)
        else
          notify(err, vim.log.levels.ERROR)
        end
      else
        notify(
          ("unknown subcommand %q; use :Chroma pick | apply <name> | current | list | reset"):format(sub),
          vim.log.levels.ERROR
        )
      end
    end, {
      nargs = "*",
      complete = function(ArgLead, CmdLine, _)
        local words = cmd_words(CmdLine)
        local after_cmd = math.max(#words - 1, 0)
        local trailing_space = CmdLine:match("%s$") ~= nil

        if after_cmd == 0 or (after_cmd == 1 and not trailing_space) then
          return complete_prefix(subcommands, ArgLead)
        end

        local sub = words[2]
        if sub == "apply" and (after_cmd == 1 or (after_cmd == 2 and not trailing_space)) then
          return complete_prefix(M.list(), ArgLead)
        end

        return {}
      end,
    })
  end

  if startup_theme then
    local applied, err = apply_theme(startup_theme, { persist = false })
    if not applied then
      notify(err, vim.log.levels.ERROR)
    end
  end

  return M
end

return M
