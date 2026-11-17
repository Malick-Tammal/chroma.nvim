local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local lib = dofile(here .. "/lib.lua")

local theme_name = vim.env.THEME or "monokai-fusion"
local theme = require("chroma.themes." .. theme_name)
local palette = require("chroma.engine.palette").build(theme)

local errors = lib.palette_errors(theme, palette)
vim.list_extend(errors, lib.highlight_errors(palette))
vim.list_extend(errors, lib.polish_errors(lib.load_polish(theme_name), palette))

if #errors > 0 then
  print(("FAIL: %d problem(s) for theme %s"):format(#errors, theme_name))
  for _, line in ipairs(errors) do
    print("  " .. line)
  end
  vim.cmd("cq")
end

print(("ok: %s, %d highlight modules, no unresolved colors"):format(theme_name, #require("chroma.highlights")))
