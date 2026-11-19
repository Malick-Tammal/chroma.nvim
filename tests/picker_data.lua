local chroma = require("chroma")
local data_mod = require("chroma.pickers.data")

-- Sample a dark theme, a light theme, and a custom one to give broader coverage.
local SAMPLE = { "monokai-fusion", "catppuccin-latte", "rosepine" }

for _, name in ipairs(SAMPLE) do
  local theme = chroma.find(name)
  assert(theme, "theme not found: " .. name)

  local data = data_mod.build(name, theme)
  assert(data, "picker data is nil for " .. name)
  assert(#data.preview_swatches > 0, "no preview swatches for " .. name)
  assert(#data.inline_swatches == #data_mod.INLINE_SWATCH_KEYS, "wrong inline swatch count for " .. name)

  local lines, spans = data_mod.preview_lines(data, 2)
  assert(#lines >= 3, name .. ": preview needs a title, separator and at least one swatch row")
  assert(#spans == #data.preview_swatches, name .. ": span count does not match swatch count")
  assert(spans[1].row == 2, ("%s: first swatch row = %d, expected 2"):format(name, spans[1].row))

  for _, span in ipairs(spans) do
    local line = lines[span.row + 1]
    assert(line, name .. ": span points outside the preview")
    assert(span.start >= 0 and span.finish <= #line, "span is outside its line")
    assert(line:sub(span.start + 1, span.finish) == "██", "span does not cover the color block")
  end

  local cell = data_mod.format_cell({ key = "vibrant_green", hex = "#ffffff" })
  assert(#cell == data_mod.CELL_W, name .. ": long palette keys overflow the cell")
end

print(("ok: picker data, %d themes checked"):format(#SAMPLE))
