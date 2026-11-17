local M = {
  Comment = { fg = "grey_fg", italic = true },
  Constant = { fg = "purple" },
  String = { fg = "yellow" },
  Character = { fg = "purple" },
  Number = { fg = "purple" },
  Boolean = { fg = "purple" },
  Float = { fg = "purple" },
  Identifier = { fg = "text" },
  Function = { fg = "green" },

  Statement = { fg = "purple" },
  Conditional = { fg = "red" },
  Repeat = { fg = "red" },
  Label = { fg = "red" },
  Operator = { fg = "red" },
  Keyword = { fg = "red", italic = true },
  Exception = { fg = "red" },

  PreProc = { fg = "yellow" },
  Include = { fg = "red" },
  Define = { fg = "red" },
  Macro = { fg = "red" },
  PreCondit = { fg = "red" },

  Type = { fg = "text" },
  StorageClass = { fg = "red", italic = true },
  Structure = { fg = "cyan", italic = true },
  Typedef = { fg = "red" },

  Special = { fg = "blue" },
  SpecialChar = { fg = "blue" },
  Tag = { fg = "red" },
  Delimiter = { fg = "text" },
  SpecialComment = { fg = "grey_fg" },
  Debug = { fg = "red" },

  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Error = { fg = "red" },
  Todo = { fg = "purple", bg = "black", bold = true },

  javaAnnotation = { fg = "grey_fg" },
  luaFunc = { fg = "green" },
  luaFuncCall = { fg = "green" },
  luaTable = { fg = "text" },
}

return M
