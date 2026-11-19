local chroma = require("chroma")
local resolve = require("chroma.engine.resolve")

local name = vim.env.THEME or "monokai-fusion"
-- persist=false: tests must not pick up a saved theme from the user's state.
chroma.setup({ theme = name, persist = false })

local p = chroma.palette()
assert(type(p) == "table", "palette is nil after setup")

-- current() and palette() must reflect the applied theme immediately after setup.
assert(chroma.current() == name, ("current() = %s, expected %s"):format(tostring(chroma.current()), name))
assert(type(chroma.palette()) == "table", "palette() returned nil after setup")

local function num(hex)
  assert(type(hex) == "string" and hex:find("#"), "not a hex color: " .. tostring(hex))
  return tonumber(hex:gsub("#", ""), 16)
end

local function hl(group)
  return vim.api.nvim_get_hl(0, { name = group, link = false })
end

local normal = hl("Normal")
assert(normal, "Normal is not defined")
assert(normal.bg == num(p.black), ("Normal.bg = %06x, expected %s"):format(normal.bg or 0, p.black))
assert(normal.fg == num(p.text), ("Normal.fg = %06x, expected text %s"):format(normal.fg or 0, p.text))

local pmenu = hl("PmenuSel")
assert(pmenu.bg == num(p.pmenu_bg), ("PmenuSel.bg = %06x, expected pmenu_bg %s"):format(pmenu.bg or 0, p.pmenu_bg))
assert(
  pmenu.fg == num(resolve.contrast(p.pmenu_bg)),
  ("PmenuSel.fg = %06x, expected contrast %s"):format(pmenu.fg or 0, resolve.contrast(p.pmenu_bg))
)

assert(vim.g.colors_name == "ch-" .. name, "colors_name = " .. tostring(vim.g.colors_name))
assert(
  vim.g.terminal_color_1 == p.base08,
  ("terminal_color_1 = %s, expected base08 %s"):format(tostring(vim.g.terminal_color_1), tostring(p.base08))
)
assert(#chroma.list() >= 99, "expected at least 99 themes, got " .. #chroma.list())

local groups = 0
for _, spec in pairs(vim.api.nvim_get_hl(0, {})) do
  if spec.fg or spec.bg or spec.sp then
    groups = groups + 1
  end
end
assert(groups > 500, "only " .. groups .. " colored groups after apply")

-- Cache: calling list() twice must return the same table object.
local list1 = chroma.list()
local list2 = chroma.list()
assert(list1 == list2, "list() should return the cached table on the second call")

-- refresh() must invalidate the cache (new table, same contents).
chroma.refresh()
local list3 = chroma.list()
assert(list1 ~= list3, "refresh() should return a new table after refresh()")
assert(#list1 == #list3, "refresh() changed the number of themes")

print(("ok: %s applied, %d colored groups, %d themes available"):format(vim.g.colors_name, groups, #chroma.list()))
