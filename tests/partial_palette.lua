local here = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local lib = dofile(here .. "/lib.lua")
local palette = require("chroma.engine.palette")

local function assert_complete(p)
  for _, key in ipairs(lib.base30) do
    assert(p[key], "missing base_30 key: " .. key)
  end
  for _, key in ipairs(lib.base16) do
    assert(p[key], "missing base_16 key: " .. key)
  end
end

local base30 = {}
for _, key in ipairs(lib.base30) do
  base30[key] = "#808080"
end

local base16 = {}
for _, key in ipairs(lib.base16) do
  base16[key] = "#808080"
end

assert_complete(palette.build({ base_30 = base30, type = "dark" }))
assert_complete(palette.build({ base_16 = base16, type = "light" }))

print("ok: partial palettes fill")
