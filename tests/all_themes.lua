local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local root = here .. "/.."
local lib = dofile(here .. "/lib.lua")
local palette_mod = require("chroma.engine.palette")
local apply = require("chroma.engine.apply")

local themes = lib.load_themes(root .. "/lua/chroma/themes")
local failures = {}
local applied = 0
local total_groups = 0

for _, entry in ipairs(themes) do
  local name = entry.name
  local errors = {}

  if entry.error then
    errors[#errors + 1] = "load error: " .. entry.error
  else
    local palette = palette_mod.build(entry.theme)
    errors = lib.palette_errors(entry.theme, palette)
    vim.list_extend(errors, lib.highlight_errors(palette))
    vim.list_extend(errors, lib.polish_errors(lib.load_polish(name), palette))

    if #errors == 0 then
      local ok, result = pcall(apply.apply, name, entry.theme, { transparency = false })
      if not ok then
        errors[#errors + 1] = "apply error: " .. tostring(result)
      else
        local count = 0
        for _, spec in pairs(vim.api.nvim_get_hl(0, {})) do
          if spec.fg or spec.bg or spec.sp then
            count = count + 1
          end
        end
        applied = applied + 1
        total_groups = total_groups + count

        if count < 500 then
          errors[#errors + 1] = "only " .. count .. " colored groups after apply"
        end
      end
    end
  end

  if #errors > 0 then
    failures[#failures + 1] = { name = name, errors = errors }
  end
end

print(("themes: %d total, %d applied, avg %d groups"):format(
  #themes,
  applied,
  applied > 0 and math.floor(total_groups / applied) or 0
))

if #failures > 0 then
  print(("FAIL: %d theme(s) with problems"):format(#failures))
  for _, failure in ipairs(failures) do
    print("  " .. failure.name .. ": " .. table.concat(failure.errors, "; "))
  end
  vim.cmd("cq")
end

print("ok: all themes valid")
