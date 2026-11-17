local M = {
  BufferLineFill = { bg = "darker_black" },
  BufferLineBackground = { fg = "grey_fg2", bg = "black" },
  BufferLineBuffer = { fg = "text", bg = "black" },
  BufferLineBufferSelected = { fg = "text", bg = "black2", bold = true },
  BufferLineBufferVisible = { fg = "grey_fg2", bg = "black" },

  BufferLineCloseButton = { fg = "grey", bg = "one_bg" },
  BufferLineCloseButtonSelected = { fg = "grey_fg2", bg = "black2" },
  BufferLineCloseButtonVisible = { fg = "grey", bg = "one_bg" },

  BufferLineIndicatorSelected = { fg = { "contrast", "orange" }, bg = "orange" },
  BufferLineIndicatorVisible = { fg = "one_bg3", bg = "one_bg" },

  BufferLineModified = { fg = "yellow", bg = "one_bg" },
  BufferLineModifiedSelected = { fg = "yellow", bg = "black2" },
  BufferLineModifiedVisible = { fg = "yellow", bg = "one_bg" },

  BufferLineDuplicate = { fg = "grey", italic = true },
  BufferLineDuplicateSelected = { fg = "grey_fg2", italic = true, bg = "black2" },
  BufferLineDuplicateVisible = { fg = "grey", italic = true, bg = "one_bg" },

  BufferLineSeparator = { fg = "one_bg", bg = "black" },
  BufferLineSeparatorSelected = { fg = "black", bg = "black" },
  BufferLineSeparatorVisible = { fg = "one_bg", bg = "black" },
  BufferLineOffsetSeparator = { fg = "one_bg", bg = "black" },
  BufferLineNeoTree = { fg = "grey_fg2", bg = "black" },
  BufferLineTab = { fg = "grey_fg2", bg = "one_bg" },
  BufferLineTabSelected = { fg = "text", bg = "black" },
  BufferLineTabClose = { fg = "red", bg = "black2" },
  BufferLineError = { fg = "red", bg = "one_bg" },
  BufferLineErrorSelected = { fg = "red", bg = "black", bold = true },
  BufferLineWarning = { fg = "yellow", bg = "one_bg" },
  BufferLineWarningSelected = { fg = "yellow", bg = "black", bold = true },
  BufferLineInfo = { fg = "cyan", bg = "one_bg" },
  BufferLineInfoSelected = { fg = "cyan", bg = "black", bold = true },
  BufferLineHint = { fg = "blue", bg = "one_bg" },
  BufferLineHintSelected = { fg = "blue", bg = "black", bold = true },
  BufferLinePick = { fg = "red", bold = true },
  BufferLinePickSelected = { fg = "red", bg = "black", bold = true },
}

return M
