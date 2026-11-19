local chroma = require("chroma")

-- Fixed reference theme; overrides are theme-independent.
local name = "monokai-fusion"

local function hl(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false })
end

local OVERRIDE_FG = "#ff0000"
local expected_fg = tonumber(OVERRIDE_FG:gsub("#", ""), 16)

-- 1. Table override: force Normal.fg to a known hex.
chroma.setup({
  theme = name,
  persist = false,
  overrides = { Normal = { fg = OVERRIDE_FG } },
})
local normal = hl("Normal")
assert(
  normal.fg == expected_fg,
  ("table override: Normal.fg = %06x, expected %06x"):format(normal.fg or 0, expected_fg)
)

-- 2. Function override: same but via callback receiving palette and theme name.
chroma.setup({
  theme = name,
  persist = false,
  overrides = function(_p, _theme_name)
    return { Normal = { fg = OVERRIDE_FG } }
  end,
})
normal = hl("Normal")
assert(
  normal.fg == expected_fg,
  ("function override: Normal.fg = %06x, expected %06x"):format(normal.fg or 0, expected_fg)
)

-- 3. Broken function override: must not crash, should notify an error.
local notified = false
local orig_notify = vim.notify
vim.notify = function(msg, level)
  if level == vim.log.levels.ERROR then
    notified = true
  end
end
chroma.setup({
  theme = name,
  persist = false,
  overrides = function()
    error("intentional override error")
  end,
})
vim.notify = orig_notify
assert(notified, "broken override function did not notify an error")

-- 4. No override: Normal.fg returns to palette color (no override leaks between setups).
chroma.setup({ theme = name, persist = false })
local fresh = hl("Normal")
assert(fresh.fg ~= expected_fg, "no-override apply still has the overridden fg — override leaked between setups")

print("ok: table, function, and broken overrides behave correctly")
