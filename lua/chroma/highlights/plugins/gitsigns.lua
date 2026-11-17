local M = {
  GitSignsAdd = { fg = "green" },
  GitSignsChange = { fg = "yellow" },
  GitSignsDelete = { fg = "red" },
  GitSignsChangedelete = { fg = "orange" },
  GitSignsTopdelete = { fg = "red" },
  GitSignsUntracked = { fg = "cyan" },

  GitSignsAddNr = { fg = "green" },
  GitSignsChangeNr = { fg = "yellow" },
  GitSignsDeleteNr = { fg = "red" },

  GitSignsAddLn = { bg = { "black", "green", 14 } },
  GitSignsChangeLn = { bg = { "black", "yellow", 12 } },
  GitSignsDeleteLn = { bg = { "black", "red", 14 } },

  GitSignsAddInline = { bg = { "black", "green", 25 } },
  GitSignsChangeInline = { bg = { "black", "yellow", 25 } },
  GitSignsDeleteInline = { bg = { "black", "red", 25 } },

  GitSignsCurrentLineBlame = { fg = "grey", italic = true },
  GitSignsAddPreview = { bg = { "black", "green", 10 } },
  GitSignsDeletePreview = { bg = { "black", "red", 10 } },

  GitSignsStagedAdd = { fg = "green" },
  GitSignsStagedChange = { fg = "yellow" },
  GitSignsStagedDelete = { fg = "red" },
}

return M
