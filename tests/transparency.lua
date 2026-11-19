local chroma = require("chroma")

-- Use a fixed reference theme; transparency applies to all themes equally.
local name = "monokai-fusion"

-- Groups whose bg must become nil when transparency = true (sampled from TRANSPARENT_GROUPS).
local TRANSPARENT_GROUPS = { "Normal", "NormalNC", "NormalFloat", "SignColumn" }

local function hl(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false })
end

-- 1. Without transparency: Normal.bg must be a number (a real color).
chroma.setup({ theme = name, persist = false, transparency = false })
local normal = hl("Normal")
assert(type(normal.bg) == "number", "Normal.bg should be set without transparency")

-- 2. With transparency: all TRANSPARENT_GROUPS must have bg = nil (no background).
chroma.setup({ theme = name, persist = false, transparency = true })
for _, group in ipairs(TRANSPARENT_GROUPS) do
  local h = hl(group)
  assert(h.bg == nil,
    ("transparency: %s.bg = %s, expected nil"):format(group, tostring(h.bg)))
end

-- 3. Switching back to no transparency restores Normal.bg.
chroma.setup({ theme = name, persist = false, transparency = false })
local restored = hl("Normal")
assert(type(restored.bg) == "number", "Normal.bg should be restored after disabling transparency")

print("ok: transparency clears and restores bg correctly")
