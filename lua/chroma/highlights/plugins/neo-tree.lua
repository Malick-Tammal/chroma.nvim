local M = {
  NeoTreeNormal = { fg = "grey_fg2", bg = "darker_black" },
  NeoTreeNormalNC = { fg = "grey_fg2", bg = "darker_black" },
  NeoTreeSignColumn = { fg = "grey", bg = "darker_black" },
  NeoTreeWinSeparator = { fg = "one_bg", bg = "darker_black" },
  NeoTreeEndOfBuffer = { fg = "darker_black", bg = "darker_black" },

  NeoTreeIndentMarker = { fg = "grey_fg2", nocombine = true },
  NeoTreeExpander = { fg = "grey_fg2", nocombine = true },
  NeoTreeDotfile = { fg = "grey_fg" },

  NeoTreeRootName = { fg = "yellow", bold = true },
  NeoTreeDirectoryName = { fg = "light_grey" },
  NeoTreeDirectoryIcon = { fg = "orange" },
  NeoTreeFileName = { fg = "white" },
  NeoTreeFileIcon = { fg = "grey_fg2" },
  NeoTreeSymbolicLinkTarget = { fg = "purple" },

  NeoTreeCursorLine = { bg = "one_bg" },
  NeoTreeStatusLine = { fg = "grey", bg = "darker_black" },

  NeoTreeGitModified = { fg = "yellow" },
  NeoTreeGitAdded = { fg = "green" },
  NeoTreeGitDeleted = { fg = "red" },
  NeoTreeGitRenamed = { fg = "purple" },
  NeoTreeGitUntracked = { fg = "cyan" },
  NeoTreeGitStaged = { fg = "green" },
  NeoTreeGitConflict = { fg = "red", bold = true },
  NeoTreeGitIgnored = { fg = "grey" },

  NeoTreeTitleBar = { fg = { "contrast", "cyan" }, bg = "cyan" },
  NeoTreeModified = { fg = "yellow" },
  NeoTreeFloatBorder = { fg = "one_bg2", bg = "darker_black" },
  NeoTreeMessage = { fg = "grey_fg" },
  NeoTreePreview = { bg = "one_bg" },
}

return M
