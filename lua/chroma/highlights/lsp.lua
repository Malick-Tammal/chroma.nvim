
local M = {
  LspReferenceText  = { bg = "one_bg2" },
  LspReferenceRead  = { bg = "one_bg2" },
  LspReferenceWrite = { bg = "one_bg2", bold = true },
  LspReferenceTarget = { underline = true },

  LspSignatureActiveParameter = { bg = "one_bg3", bold = true },
  LspCodeLens         = { fg = "grey" },
  LspCodeLensSeparator = { fg = "one_bg3" },
  LspInlayHint        = { fg = "grey", bg = "darker_black", italic = true },

  DiagnosticError = { fg = "red" },
  DiagnosticWarn  = { fg = "yellow" },
  DiagnosticInfo  = { fg = "cyan" },
  DiagnosticHint  = { fg = "blue" },
  DiagnosticOk    = { fg = "green" },

  DiagnosticUnderlineError = { sp = "red", undercurl = true },
  DiagnosticUnderlineWarn  = { sp = "yellow", undercurl = true },
  DiagnosticUnderlineInfo  = { sp = "cyan", undercurl = true },
  DiagnosticUnderlineHint  = { sp = "blue", undercurl = true },
  DiagnosticUnderlineOk    = { sp = "green", undercurl = true },

  DiagnosticVirtualTextError = { fg = "red", bg = { "black", "red", 12 } },
  DiagnosticVirtualTextWarn  = { fg = "yellow", bg = { "black", "yellow", 12 } },
  DiagnosticVirtualTextInfo  = { fg = "cyan", bg = { "black", "cyan", 12 } },
  DiagnosticVirtualTextHint  = { fg = "blue", bg = { "black", "blue", 12 } },

  DiagnosticFloatingError = { fg = "red" },
  DiagnosticFloatingWarn  = { fg = "yellow" },
  DiagnosticFloatingInfo  = { fg = "cyan" },
  DiagnosticFloatingHint  = { fg = "blue" },

  DiagnosticSignError = { fg = "red" },
  DiagnosticSignWarn  = { fg = "yellow" },
  DiagnosticSignInfo  = { fg = "cyan" },
  DiagnosticSignHint  = { fg = "blue" },

  DiagnosticUnnecessary = { fg = "grey" },

  LspInfoBorder    = { fg = "one_bg2", bg = "darker_black" },
  LspInfoTitle     = { fg = "yellow" },
  LspInfoList      = { fg = "text" },
  LspInfoFiletype  = { fg = "cyan" },
}

return M
