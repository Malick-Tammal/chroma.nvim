local M = {}

function M.set(p)
  local ansi = {
    p.base00 or p.black,
    p.base08 or p.red,
    p.base0B or p.green,
    p.base0A or p.yellow,
    p.base0D or p.blue,
    p.base0E or p.purple,
    p.base0C or p.cyan,
    p.base05 or p.text,
    p.base03 or p.grey,
    p.base08 or p.red,
    p.base0B or p.green,
    p.base0A or p.yellow,
    p.base0D or p.blue,
    p.base0E or p.purple,
    p.base0C or p.cyan,
    p.base07 or p.white,
  }

  for i = 0, 15 do
    local color = ansi[i + 1]
    if color then
      vim.g["terminal_color_" .. i] = color
    end
  end
end

return M
