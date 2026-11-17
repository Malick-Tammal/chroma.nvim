local M = {}

local function hex2rgb(hex)
  hex = hex:gsub("#", "")
  if #hex == 3 then
    hex = hex:sub(1, 1):rep(2) .. hex:sub(2, 2):rep(2) .. hex:sub(3, 3):rep(2)
  end
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb2hex(r, g, b)
  local function clamp(x)
    return math.max(0, math.min(255, math.floor(x + 0.5)))
  end
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

local function rgb2hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2

  if max ~= min then
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l
end

local function hsl2rgb(h, s, l)
  if s == 0 then
    return l * 255, l * 255, l * 255
  end

  local function hue(p, q, t)
    if t < 0 then
      t = t + 1
    end
    if t > 1 then
      t = t - 1
    end
    if t < 1 / 6 then
      return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
      return q
    end
    if t < 2 / 3 then
      return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
  end

  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return hue(p, q, h + 1 / 3) * 255, hue(p, q, h) * 255, hue(p, q, h - 1 / 3) * 255
end

function M.lighten(hex, percent)
  if type(hex) ~= "string" or not hex:find("#") then
    return hex
  end
  local h, s, l = rgb2hsl(hex2rgb(hex))
  l = math.max(0, math.min(1, l + percent / 100))
  return rgb2hex(hsl2rgb(h, s, l))
end

function M.mix(first, second, strength)
  if type(first) ~= "string" or type(second) ~= "string" then
    return first
  end
  strength = strength == nil and 50 or strength
  local s = strength / 100
  if s <= 0 then
    return first
  elseif s >= 1 then
    return second
  end
  local r1, g1, b1 = hex2rgb(first)
  local r2, g2, b2 = hex2rgb(second)
  if not (r1 and r2) then
    return first
  end
  return rgb2hex(r1 * (1 - s) + r2 * s, g1 * (1 - s) + g2 * s, b1 * (1 - s) + b2 * s)
end

function M.blend(hex1, hex2, alpha)
  if type(hex1) ~= "string" or type(hex2) ~= "string" then
    return hex1
  end
  if not hex1:find("#") or not hex2:find("#") then
    return hex1
  end
  alpha = math.max(0, math.min(1, alpha))
  local s = 1 - alpha
  local r1, g1, b1 = hex2rgb(hex1)
  local r2, g2, b2 = hex2rgb(hex2)
  if not (r1 and r2) then
    return hex1
  end
  return rgb2hex(r1 * alpha + r2 * s, g1 * alpha + g2 * s, b1 * alpha + b2 * s)
end

function M.color(value, palette)
  if type(value) == "table" then
    local a, b, c = value[1], value[2], value[3]

    -- Pick black/white per theme so accent blocks stay readable in light and dark palettes.
    if a == "contrast" then
      return M.contrast(palette[b])
    end

    if c ~= nil then
      return M.mix(palette[a] or a, palette[b] or b, c)
    elseif b ~= nil then
      return M.lighten(palette[a] or a, b)
    end

    return value
  end

  if type(value) ~= "string" then
    return value
  end

  local upper = value:upper()
  if upper == "NONE" or upper == "NIL" or value:sub(1, 1) == "#" then
    return value
  end

  return palette[value] or value
end

function M.luminance(hex)
  if type(hex) ~= "string" or not hex:find("#") then
    return nil
  end

  local function channel(c)
    c = c / 255
    return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
  end

  local r, g, b = hex2rgb(hex)
  if not (r and g and b) then
    return nil
  end

  return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
end

function M.ratio(first, second)
  local a, b = M.luminance(first), M.luminance(second)
  if not a or not b then
    return nil
  end

  local hi, lo = math.max(a, b), math.min(a, b)
  return (hi + 0.05) / (lo + 0.05)
end

function M.contrast(hex)
  local luminance = M.luminance(hex)
  if not luminance then
    return "#ffffff" -- hex-ok: contrast extreme, not a theme color
  end

  return luminance > 0.179 and "#000000" or "#ffffff" -- hex-ok: contrast extreme, not a theme color
end

function M.spec(spec, palette)
  local out = {}
  local bg_alpha = spec.bg_alpha
  local bg_base = spec.bg_base or "black2"
  for key, value in pairs(spec) do
    if key == "fg" or key == "sp" then
      out[key] = M.color(value, palette)
    elseif key == "bg" then
      local resolved = M.color(value, palette)
      if bg_alpha then
        local base_hex = type(bg_base) == "string" and (palette[bg_base] or bg_base) or bg_base
        resolved = M.blend(resolved, base_hex, bg_alpha)
      end
      out[key] = resolved
    elseif key ~= "bg_alpha" and key ~= "bg_base" then
      out[key] = value
    end
  end
  return out
end
return M
