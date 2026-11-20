local M = {
  TelescopeNormal = { fg = "light_grey", bg = "darker_black" },
  TelescopeBorder = { fg = "darker_black", bg = "darker_black" },
  TelescopeTitle = { fg = { "contrast", "cyan" }, bg = "cyan" },

  TelescopePromptNormal = { bg = "black2" },
  TelescopePromptBorder = { fg = "black2", bg = "black2" },
  TelescopePromptTitle = { fg = { "contrast", "blue" }, bg = "blue" },
  TelescopePromptPrefix = { fg = "red" },
  TelescopePromptCounter = { fg = "grey_fg" },

  TelescopeResultsNormal = { bg = "darker_black", fg = "light_grey" },
  TelescopeResultsBorder = { fg = "darker_black", bg = "darker_black" },
  TelescopeResultsTitle = { fg = { "contrast", "red" }, bg = "red" },
  TelescopeResultsComment = { fg = "grey" },
  TelescopeResultsDirectory = { fg = "cyan" },
  TelescopeResultsFileIcon = { fg = "cyan" },

  TelescopePreviewNormal = { bg = "black", fg = "light_grey" },
  TelescopePreviewBorder = { fg = "black", bg = "black" },
  TelescopePreviewTitle = { fg = { "contrast", "yellow" }, bg = "yellow" },
  TelescopePreviewLine = { bg = "one_bg" },
  TelescopePreviewMatch = { bg = "one_bg3" },

  TelescopeSelection = { bg = "one_bg" },
  TelescopeSelectionCaret = { fg = "purple" },
  TelescopeMultiSelection = { bg = "one_bg3" },
  TelescopeMatching = { fg = "green", bold = true },
}

return M
