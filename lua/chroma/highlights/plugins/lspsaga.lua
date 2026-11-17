local M = {
  SagaWinbarSep = { fg = "grey", bg = "NONE" },
  SagaWinbarFolder = { fg = "cyan", bg = "NONE" },
  SagaWinbarFile = { fg = "grey_fg2", bg = "NONE" },
  SagaWinbarWord = { fg = "grey_fg2", bg = "NONE" },

  SagaNormal = { bg = "darker_black" },
  SagaBorder = { fg = "one_bg2", bg = "darker_black" },
  SagaTitle = { fg = { "contrast", "cyan" }, bg = "cyan" },
  SagaBeacon = { bg = "one_bg3" },

  SagaCodeActionBorder = { fg = "one_bg2" },
  SagaCodeActionTitle = { fg = "yellow" },
  SagaCodeActionNum = { fg = "red" },

  SagaHoverNormal = { bg = "darker_black" },
  SagaHoverBorder = { fg = "one_bg2" },
  SagaHoverTitle = { fg = "cyan" },
  SagaHoverLine = { bg = "one_bg" },

  SagaRenameNormal = { bg = "darker_black" },
  SagaRenameBorder = { fg = "one_bg2" },
  SagaRenameTitle = { fg = "red" },

  SagaDiagnosticBorder = { fg = "one_bg2" },
  SagaDiagnosticTitle = { fg = "yellow" },
  SagaDiagnosticError = { fg = "red" },
  SagaDiagnosticWarning = { fg = "yellow" },
  SagaDiagnosticInformation = { fg = "cyan" },
  SagaDiagnosticHint = { fg = "blue" },

  SagaSignatureHelpNormal = { bg = "darker_black" },
  SagaSignatureHelpBorder = { fg = "one_bg2" },
  SagaSignatureHelpCurrentArgument = { fg = "yellow", bold = true },

  SagaFinderNormal = { bg = "darker_black" },
  SagaFinderBorder = { fg = "one_bg2" },
  SagaFinderTitle = { fg = "green" },
  SagaFinderMatch = { fg = "yellow", bold = true },

  SagaDefinitionPreviewNormal = { bg = "darker_black" },
  SagaDefinitionPreviewBorder = { fg = "one_bg2" },
  SagaDefinitionPreviewTitle = { fg = "cyan" },

  SagaLightBulb = { fg = "yellow" },
  SagaSpinner = { fg = "green" },
  SagaWinbarSepNC = { fg = "one_bg3" },
}

return M
