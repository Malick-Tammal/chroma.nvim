local chroma = require("chroma")
local name = vim.env.THEME or "monokai-fusion"

local entries = {}
local orig_health = vim.health

local function record(kind)
  return function(msg)
    entries[#entries + 1] = { kind = kind, msg = msg }
  end
end

vim.health = {
  start = record("start"),
  ok = record("ok"),
  info = record("info"),
  warn = record("warn"),
  error = record("error"),
}

local function reset()
  entries = {}
end

local function count(kind)
  local n = 0
  for _, entry in ipairs(entries) do
    if entry.kind == kind then
      n = n + 1
    end
  end
  return n
end

local function find(kind, needle)
  for _, entry in ipairs(entries) do
    if entry.kind == kind and entry.msg:find(needle, 1, true) then
      return entry.msg
    end
  end
  return nil
end

local health = require("chroma.health")
local persist = require("chroma.persist")

health.check()
assert(count("error") > 0, "health check passed before setup() ran")
assert(find("error", "setup()"), "missing setup error")

reset()
chroma.setup({ theme = name, persist = false })
health.check()
assert(count("error") == 0, "healthy install reported errors: " .. tostring(find("error", "")))
assert(count("ok") >= 5, ("only %d ok checks"):format(count("ok")))
assert(find("ok", "themes found"), "theme count not reported")
assert(find("ok", "shim"), "shim check not reported")
assert(find("start", "Palette"), "palette section missing")
assert(find("start", "Persistence"), "persistence section missing")

chroma.config.persist = true
persist.save("does-not-exist")
reset()
health.check()
assert(find("warn", "does-not-exist"), "stale saved theme not reported")
assert(find("warn", "reset"), "stale saved theme did not suggest :Chroma reset")
persist.clear()
chroma.config.persist = false

vim.health = orig_health
vim.cmd("silent checkhealth chroma")

local output = ""
local ok = vim.wait(5000, function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bname = vim.api.nvim_buf_get_name(buf)
    if bname:match("health") or vim.bo[buf].filetype == "checkhealth" then
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local text = table.concat(lines, "\n")
      if text:find("themes found", 1, true) then
        output = text
        return true
      end
    end
  end
  return false
end, 50)

assert(ok, ":checkhealth chroma output missing theme count")
assert(not output:find("ERROR", 1, true), ":checkhealth reported an error")

print("ok: :checkhealth chroma reports healthy state")
