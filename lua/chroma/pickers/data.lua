local palette = require("chroma.engine.palette")

local M = {}

local BASE16_KEYS = {}
for i = 0, 15 do
  BASE16_KEYS[#BASE16_KEYS + 1] = ("base%02X"):format(i)
end

local INLINE_SWATCH_KEYS = {
  "base00",
  "base01",
  "base02",
  "base03",
  "base08",
  "base0A",
  "base0B",
  "base0C",
  "base0D",
  "base0E",
}

M.INLINE_SWATCH_KEYS = INLINE_SWATCH_KEYS
M.CELL_W = 40

local BLOCK = "██"

local function is_hex(value)
  return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

local function pick_swatch_hex(p, key)
  local hex = p[key]
  if is_hex(hex) then
    return hex
  end
  return p.text or p.white or p.base05 or "#888888" -- hex-ok: swatch fallback
end

function M.display_name(name)
  local display = name:gsub("-", " ")
  display = display:gsub("([a-z])([A-Z])", "%1 %2")
  display = display:gsub("_", " ")
  display = display:gsub("(%w)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
  return display
end

local function collect_preview_swatches(p)
  local swatches, seen = {}, {}

  local function add(key, hex)
    if is_hex(hex) and not seen[key] then
      seen[key] = true
      swatches[#swatches + 1] = { key = key, hex = hex }
    end
  end

  for _, key in ipairs(BASE16_KEYS) do
    add(key, p[key])
  end

  local rest = {}
  for key in pairs(p) do
    if not seen[key] then
      rest[#rest + 1] = key
    end
  end
  table.sort(rest)

  for _, key in ipairs(rest) do
    add(key, p[key])
  end

  return swatches
end

function M.build(name, theme)
  if not theme then
    return nil
  end

  local p = palette.build(theme)
  local inline_swatches = {}

  for _, key in ipairs(INLINE_SWATCH_KEYS) do
    inline_swatches[#inline_swatches + 1] = pick_swatch_hex(p, key)
  end

  return {
    name = name,
    display = M.display_name(name),
    type = p.type or theme.type or "",
    palette = p,
    preview_swatches = collect_preview_swatches(p),
    inline_swatches = inline_swatches,
    name_hex = pick_swatch_hex(p, "light_grey"),
  }
end

function M.format_cell(swatch)
  if not swatch then
    return string.rep(" ", M.CELL_W)
  end

  local cell = BLOCK .. "  " .. ("%-14.14s %s"):format(swatch.key, swatch.hex)
  if #cell < M.CELL_W then
    cell = cell .. string.rep(" ", M.CELL_W - #cell)
  end
  return cell
end

function M.preview_lines(data, columns)
  columns = math.max(1, columns or 1)
  local swatches = data.preview_swatches

  local title = data.display
  if data.type and data.type ~= "" then
    title = title .. "  (" .. data.type .. ")"
  end

  local lines = { title, "" }
  local spans = {}

  local i = 1
  while i <= #swatches do
    local row = #lines
    local cells = {}

    for col = 1, columns do
      local swatch = swatches[i + col - 1]
      cells[col] = M.format_cell(swatch)
      if swatch then
        local offset = (col - 1) * M.CELL_W
        spans[#spans + 1] = {
          row = row,
          start = offset,
          finish = offset + #BLOCK,
          hex = swatch.hex,
        }
      end
    end

    lines[#lines + 1] = table.concat(cells)
    i = i + columns
  end

  return lines, spans
end

return M
