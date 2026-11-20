local chroma = require("chroma")

-- TEST: Verify transparency toggles and restores Normal and floating backgrounds correctly.
-- NOTE: Use fixed reference theme; transparency logic is theme-independent.
local name = "monokai-fusion"

local TRANSPARENT_GROUPS = { "Normal", "NormalNC", "NormalFloat", "SignColumn" }

local function hl(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false })
end

chroma.setup({ theme = name, persist = false, transparency = false })
local normal = hl("Normal")
assert(type(normal.bg) == "number", "Normal.bg should be set without transparency")

chroma.setup({ theme = name, persist = false, transparency = true })
for _, group in ipairs(TRANSPARENT_GROUPS) do
  local h = hl(group)
  assert(h.bg == nil, ("transparency: %s.bg = %s, expected nil"):format(group, tostring(h.bg)))
end

chroma.setup({ theme = name, persist = false, transparency = false })
local restored = hl("Normal")
assert(type(restored.bg) == "number", "Normal.bg should be restored after disabling transparency")

print("ok: transparency clears and restores bg correctly")
