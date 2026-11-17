local M = {
  Normal = { fg = "text", bg = "black" },
  NormalNC = { fg = "text", bg = "black" },
  NormalFloat = { fg = "text", bg = "darker_black" },
  FloatBorder = { fg = "darker_black", bg = "darker_black" },
  FloatTitle = { fg = "darker_black", bg = "purple", bold = true },
  FloatFooter = { fg = "grey", bg = "darker_black" },

  Cursor = { fg = { "contrast", "white" }, bg = "white" },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  TermCursor = { link = "Cursor" },
  CursorLine = { bg = "one_bg2" },
  CursorColumn = { bg = "one_bg" },
  ColorColumn = { bg = "darker_black" },

  LineNr = { fg = "grey" },
  LineNrAbove = { fg = "grey_fg" },
  LineNrBelow = { fg = "grey_fg" },
  CursorLineNr = { fg = "yellow", bold = true },

  SignColumn = { bg = "black" },
  FoldColumn = { fg = "grey", bg = "black" },
  Folded = { fg = "light_grey", bg = "one_bg3" },

  Visual = { bg = "one_bg2" },
  VisualNOS = { link = "Visual" },
  Search = { bg = "one_bg3", fg = "text" },
  IncSearch = { bg = "yellow", fg = { "contrast", "yellow" } },
  CurSearch = { link = "IncSearch" },
  Substitute = { bg = "red", fg = { "contrast", "red" } },

  Pmenu = { fg = "grey_fg2", bg = "one_bg" },
  PmenuSel = { fg = { "contrast", "pmenu_bg" }, bg = "pmenu_bg" },
  PmenuSbar = { bg = "one_bg" },
  PmenuThumb = { bg = "grey" },
  PmenuKind = { fg = "cyan", bg = "one_bg" },
  PmenuExtra = { fg = "grey", bg = "one_bg" },

  StatusLine = { fg = "grey_fg2", bg = "black2" },
  StatusLineNC = { fg = "grey", bg = "darker_black" },
  WinBar = { fg = "grey_fg2", bg = "black" },
  WinBarNC = { fg = "grey", bg = "darker_black" },

  TabLine = { fg = "grey", bg = "darker_black" },
  TabLineFill = { bg = "darker_black" },
  TabLineSel = { fg = "text", bg = "one_bg" },

  WinSeparator = { fg = "grey", bg = "black" },
  VertSplit = { link = "WinSeparator" },

  NonText = { fg = "one_bg3" },
  SpecialKey = { fg = "grey" },
  Whitespace = { fg = "one_bg3" },
  EndOfBuffer = { fg = "black" },
  Conceal = { fg = "grey_fg" },

  Directory = { fg = "cyan" },
  Title = { fg = "yellow", bold = true },
  MatchParen = { fg = "yellow", bg = "one_bg3", bold = true },

  DiffAdd = { bg = { "black", "green", 14 } },
  DiffChange = { bg = { "black", "yellow", 12 } },
  DiffDelete = { bg = { "black", "red", 14 } },
  DiffText = { bg = { "black", "yellow", 30 } },
  Added = { fg = "green" },
  Changed = { fg = "yellow" },
  Removed = { fg = "red" },

  SpellBad = { sp = "red", undercurl = true },
  SpellCap = { sp = "yellow", undercurl = true },
  SpellLocal = { sp = "cyan", undercurl = true },
  SpellRare = { sp = "purple", undercurl = true },

  ErrorMsg = { fg = "red", bold = true },
  WarningMsg = { fg = "yellow" },
  ModeMsg = { fg = "green", bold = true },
  MoreMsg = { fg = "green" },
  Question = { fg = "cyan" },
  MsgArea = { fg = "text", bg = "black" },
  MsgSeparator = { fg = "one_bg3", bg = "black" },

  QuickFixLine = { bg = "one_bg2" },
  qfFileName = { fg = "cyan" },
  qfLineNr = { fg = "grey_fg" },

  HealthError = { fg = "red" },
  HealthWarning = { fg = "yellow" },
  HealthSuccess = { fg = "green" },
  HealthInfo = { fg = "cyan" },

  DiagnosticDeprecated = { fg = "grey", strikethrough = true },
}

return M
