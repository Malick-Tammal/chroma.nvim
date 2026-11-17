local chroma = require("chroma")
local name = vim.env.THEME or "monokai-fusion"

chroma.setup({ theme = name, persist = false })

local notified = {}
local pick_calls = 0

local orig_notify = vim.notify
vim.notify = function(msg, level)
  notified[#notified + 1] = { msg = msg, level = level }
end

local telescope = require("chroma.pickers.telescope")
local orig_pick = telescope.pick
telescope.pick = function()
  pick_calls = pick_calls + 1
end

vim.cmd("Chroma")
assert(pick_calls == 0, "bare :Chroma opened the picker")
assert(#notified == 1, ("bare :Chroma sent %d notifications"):format(#notified))
assert(notified[1].level == vim.log.levels.WARN, "bare :Chroma did not warn")
assert(notified[1].msg:find("pick", 1, true), "usage does not mention pick")
assert(notified[1].msg:find("apply", 1, true), "usage does not mention apply")

vim.cmd("Chroma pick")
assert(pick_calls == 1, (":Chroma pick called pick %d times"):format(pick_calls))
assert(#notified == 1, ":Chroma pick notified unexpectedly")

telescope.pick = orig_pick

assert(chroma.set == nil, "chroma still exports set()")

local count = #notified
chroma.apply(name, { persist = false, quiet = true })
assert(#notified == count, "quiet apply notified")

chroma.apply(name, { persist = false })
assert(#notified == count + 1, "apply did not notify")
assert(notified[#notified].msg:find("Theme set to: ", 1, true), "unexpected apply message")

vim.notify = orig_notify

print("ok: bare :Chroma warns with usage; pick opens the picker")
