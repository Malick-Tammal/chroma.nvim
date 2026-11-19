local M = {}

M.base30 = {
  "white",
  "darker_black",
  "black",
  "black2",
  "one_bg",
  "one_bg2",
  "one_bg3",
  "grey",
  "grey_fg",
  "grey_fg2",
  "light_grey",
  "red",
  "baby_pink",
  "pink",
  "line",
  "green",
  "vibrant_green",
  "blue",
  "yellow",
  "sun",
  "purple",
  "dark_purple",
  "teal",
  "orange",
  "cyan",
  "statusline_bg",
  "lightbg",
  "pmenu_bg",
  "folder_bg",
  "nord_blue",
}

M.base16 = {
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

local function is_ref(value)
  return type(value) == "string" and value:sub(1, 1) ~= "#" and value:upper() ~= "NONE" and value:upper() ~= "NIL"
end

local function check_spec(out, label, spec, palette)
  if type(spec) ~= "table" then
    return
  end

  for _, attr in ipairs({ "fg", "bg", "sp" }) do
    local value = spec[attr]

    if is_ref(value) and not palette[value] then
      out[#out + 1] = ("%s.%s = %q (unknown color)"):format(label, attr, value)
    elseif type(value) == "table" then
      if value[1] == "contrast" then
        local name = value[2]
        if type(name) ~= "string" or not palette[name] then
          out[#out + 1] = ("%s.%s = {contrast, %q} (unknown color)"):format(label, attr, tostring(name))
        end
      else
        for _, name in ipairs({ value[1], value[2] }) do
          if type(name) == "string" and name:sub(1, 1) ~= "#" and not palette[name] then
            out[#out + 1] = ("%s.%s = {%q, ...} (unknown color)"):format(label, attr, name)
          end
        end
      end
    end
  end
end

function M.palette_errors(theme, palette)
  local out = {}

  if type(theme.base_30) ~= "table" then
    out[#out + 1] = "base_30 missing"
  end
  if type(theme.base_16) ~= "table" then
    out[#out + 1] = "base_16 missing"
  end

  for _, key in ipairs(M.base30) do
    if not palette[key] then
      out[#out + 1] = "base_30." .. key .. " missing"
    end
  end

  for _, key in ipairs(M.base16) do
    if not palette[key] then
      out[#out + 1] = "base_16." .. key .. " missing"
    end
  end

  if theme.type ~= "dark" and theme.type ~= "light" then
    out[#out + 1] = "type must be dark|light, got " .. tostring(theme.type)
  end

  for integration, spec in pairs(theme.polish_hl or {}) do
    for group, hl in pairs(spec) do
      check_spec(out, integration .. "." .. group, hl, palette)
    end
  end

  return out
end

function M.highlight_errors(palette)
  local out = {}

  for _, module in ipairs(require("chroma.highlights")) do
    local ok, tbl = pcall(require, "chroma.highlights." .. module)
    if not ok then
      out[#out + 1] = "module failed: " .. module .. " (" .. tostring(tbl) .. ")"
    else
      for group, spec in pairs(tbl) do
        check_spec(out, module .. ":" .. group, spec, palette)
      end
    end
  end

  return out
end

function M.load_polish(name)
  local ok, mod = pcall(require, "chroma.polish." .. name)
  if ok and type(mod) == "table" then
    return mod
  end

  ok, mod = pcall(require, "polish." .. name)
  if ok and type(mod) == "table" then
    return mod
  end

  return nil
end

function M.polish_errors(polish, palette)
  local out = {}

  for integration, spec in pairs(polish or {}) do
    for group, hl in pairs(spec) do
      check_spec(out, "polish/" .. integration .. "." .. group, hl, palette)
    end
  end

  return out
end

function M.load_themes(dir)
  local themes = {}
  local files = vim.fn.glob(dir .. "/*.lua", false, true)

  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    local chunk, err = loadfile(file)

    if not chunk then
      themes[#themes + 1] = { name = name, error = err }
    else
      local ok, theme = pcall(chunk)
      if not ok or type(theme) ~= "table" then
        themes[#themes + 1] = { name = name, error = tostring(theme) }
      else
        themes[#themes + 1] = { name = name, theme = theme }
      end
    end
  end

  table.sort(themes, function(a, b)
    return a.name < b.name
  end)

  return themes
end

return M
