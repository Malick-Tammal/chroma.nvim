local lualine_engine = require("chroma.engine.lualine")

local theme = lualine_engine.get()

return setmetatable(type(theme) == "table" and theme or {}, {
  __call = function()
    return lualine_engine.get()
  end,
  __index = function(_, key)
    local t = lualine_engine.get()
    return type(t) == "table" and t[key] or nil
  end,
})
