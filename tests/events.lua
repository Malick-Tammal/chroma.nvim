local chroma = require("chroma")
-- NOTE: Fixed reference theme; ColorScheme event tests are theme-agnostic.
local name = "monokai-fusion"
local count = 0

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    count = count + 1
  end,
})

chroma.setup({ theme = name, persist = false })
assert(count == 1, ("setup fired %d ColorScheme events"):format(count))

vim.cmd("colorscheme ch-" .. name)
assert(count == 2, (":colorscheme fired %d total ColorScheme events"):format(count))

chroma.apply(name, { persist = false, quiet = true })
assert(count == 3, ("apply() fired %d total ColorScheme events"):format(count))

print("ok: one ColorScheme event per apply path")
