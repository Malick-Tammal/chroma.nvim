local M = {
  CmpPmenu = { bg = "black2", fg = "grey_fg2" },
  CmpSel = { link = "PmenuSel" },
  CmpBorder = { fg = "one_bg2", bg = "black" },
  CmpDoc = { bg = "darker_black" },
  CmpDocBorder = { fg = "black", bg = "black" },
  CmpDocNormal = { bg = "black", fg = "grey_fg2" },
  CmpDocFloat = { bg = "black" },
  CmpGhostText = { fg = "grey", italic = true },

  CmpItemAbbr = { fg = "text" },
  CmpItemAbbrDeprecated = { fg = "grey", strikethrough = true },
  CmpItemAbbrMatch = { fg = "yellow", bold = true },
  CmpItemAbbrMatchFuzzy = { fg = "yellow" },
  CmpItemMenu = { fg = "grey" },
  CmpItemKind = { fg = "purple" },
}

local kinds = {
  Text = "white",
  Method = "cyan",
  Function = "purple",
  Constructor = "yellow",
  Field = "red",
  Variable = "red",
  Class = "yellow",
  Interface = "green",
  Module = "cyan",
  Property = "cyan",
  Unit = "grey_fg",
  Value = "blue",
  Enum = "yellow",
  Keyword = "purple",
  Snippet = "green",
  Color = "blue",
  File = "grey_fg",
  Reference = "grey_fg",
  Folder = "cyan",
  EnumMember = "cyan",
  Constant = "blue",
  Struct = "blue",
  Event = "red",
  Operator = "grey_fg",
  TypeParameter = "yellow",
  Emoji = "yellow",
  Look = "blue",
  Calc = "cyan",
}

for kind, color in pairs(kinds) do
  M["CmpItemKind" .. kind] = {
    fg = color,
    bg = color,
    bg_alpha = 0.18,
    bg_base = "black2",
  }
end

return M
