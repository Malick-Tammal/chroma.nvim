local chroma = require("chroma")
local data_mod = require("chroma.pickers.data")

local name = vim.env.THEME or "monokai-fusion"
local theme = chroma.find(name)
assert(theme, "theme not found: " .. name)

local data = data_mod.build(name, theme)
assert(data, "picker data is nil")
assert(#data.preview_swatches > 0, "no preview swatches")
assert(#data.inline_swatches == #data_mod.INLINE_SWATCH_KEYS, "wrong inline swatch count")

local lines, spans = data_mod.preview_lines(data, 2)
assert(#lines >= 3, "preview needs a title, separator and at least one swatch row")
assert(#spans == #data.preview_swatches, "span count does not match swatch count")
assert(spans[1].row == 2, ("first swatch row = %d, expected 2"):format(spans[1].row))

for _, span in ipairs(spans) do
  local line = lines[span.row + 1]
  assert(line, "span points outside the preview")
  assert(span.start >= 0 and span.finish <= #line, "span is outside its line")
  assert(line:sub(span.start + 1, span.finish) == "██", "span does not cover the color block")
end

local cell = data_mod.format_cell({ key = "vibrant_green", hex = "#ffffff" })
assert(#cell == data_mod.CELL_W, "long palette keys overflow the cell")

print(("ok: picker data, %d swatches, %d spans"):format(#data.preview_swatches, #spans))
