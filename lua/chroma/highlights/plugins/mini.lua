local M = {
  MiniIconsAzure = { fg = "cyan" },
  MiniIconsBlue = { fg = "blue" },
  MiniIconsCyan = { fg = "cyan" },
  MiniIconsGreen = { fg = "green" },
  MiniIconsGrey = { fg = "grey_fg2" },
  MiniIconsOrange = { fg = "orange" },
  MiniIconsPurple = { fg = "purple" },
  MiniIconsRed = { fg = "red" },
  MiniIconsYellow = { fg = "yellow" },

  MiniFilesNormal = { fg = "text", bg = "black" },
  MiniFilesBorder = { fg = "black", bg = "black" },
  MiniFilesBorderModified = { fg = "yellow", bg = "black" },
  MiniFilesTitle = { fg = "grey_fg2", bg = "one_bg2" },
  MiniFilesTitleFocused = { fg = { "contrast", "green" }, bg = "green" },
  MiniFilesDirectory = { fg = "cyan" },
  MiniFilesFile = { fg = "text" },
  MiniFilesCursorLine = { bg = "one_bg" },

  MiniIndentscopeSymbol = { fg = "green" },
  MiniIndentscopeSymbolOff = { fg = "grey" },
  MiniIndentscopeSymbolWithStartup = { fg = "grey" },

  MiniStatuslineModeNormal = { fg = { "contrast", "yellow" }, bg = "yellow", bold = true },
  MiniStatuslineModeInsert = { fg = { "contrast", "green" }, bg = "green", bold = true },
  MiniStatuslineModeVisual = { fg = { "contrast", "purple" }, bg = "purple", bold = true },
  MiniStatuslineModeReplace = { fg = { "contrast", "red" }, bg = "red", bold = true },
  MiniStatuslineModeCommand = { fg = { "contrast", "cyan" }, bg = "cyan", bold = true },
  MiniStatuslineModeOther = { fg = { "contrast", "blue" }, bg = "blue", bold = true },
  MiniStatuslineDevinfo = { fg = "grey_fg2", bg = "black2" },
  MiniStatuslineFileinfo = { fg = "grey_fg2", bg = "black2" },
  MiniStatuslineFilename = { fg = "grey_fg2", bg = "darker_black" },
  MiniStatuslineInactive = { fg = "grey", bg = "darker_black" },
}

return M
