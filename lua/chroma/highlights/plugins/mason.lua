local M = {
  MasonNormal = { fg = "text", bg = "darker_black" },
  MasonHeader = { fg = "darker_black", bg = "green" },
  MasonHighlight = { fg = "cyan" },
  MasonHighlightBlock = { fg = { "contrast", "cyan" }, bg = "cyan" },
  MasonHighlightBlockBold = { fg = { "contrast", "cyan" }, bg = "cyan", bold = true },
  MasonHighlightSecondary = { fg = "yellow" },
  MasonHighlightBlockSecondary = { fg = { "contrast", "yellow" }, bg = "yellow" },
  MasonHighlightBlockBoldSecondary = { fg = { "contrast", "yellow" }, bg = "yellow", bold = true },
  MasonLink = { fg = "blue", underline = true },
  MasonMuted = { fg = "grey" },
  MasonMutedBlock = { fg = "grey_fg2", bg = "one_bg" },
  MasonMutedBlockBold = { fg = "grey_fg2", bg = "one_bg", bold = true },
  MasonError = { fg = "red" },
  MasonWarning = { fg = "yellow" },
  MasonHeaderSecondary = { fg = { "contrast", "purple" }, bg = "purple" },
}

return M
