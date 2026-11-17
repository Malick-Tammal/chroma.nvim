local M = {}

local function state_dir()
  return vim.fn.stdpath("state") .. "/chroma"
end

local function state_file()
  return state_dir() .. "/current"
end

function M.load()
  local ok, lines = pcall(vim.fn.readfile, state_file())
  if not ok or type(lines) ~= "table" then
    return nil
  end

  local name = vim.trim(lines[1] or "")
  return name ~= "" and name or nil
end

function M.save(name)
  if type(name) ~= "string" or name == "" then
    return false
  end

  pcall(vim.fn.mkdir, state_dir(), "p")
  return pcall(vim.fn.writefile, { name }, state_file())
end

function M.clear()
  pcall(vim.fn.delete, state_file())
end

return M
