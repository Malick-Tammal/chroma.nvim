local M = {}

local chroma = require("chroma")
local data_mod = require("chroma.pickers.data")

function M.pick()
  local names = chroma.list()
  if #names == 0 then
    vim.notify("[chroma] no themes found on runtimepath", vim.log.levels.ERROR)
    return
  end

  local defined_hl = {}

  local function define_hl(group, hex)
    if not defined_hl[group] then
      vim.api.nvim_set_hl(0, group, { fg = hex })
      defined_hl[group] = true
    end
    return group
  end

  local function swatch_hl(hex)
    return define_hl("ChromaSwatch_" .. hex:gsub("#", ""), hex)
  end

  local function build_theme_data(name)
    local data = data_mod.build(name, chroma.find(name))
    if not data then
      return nil
    end

    data.name_hl = define_hl("ChromaEntry_" .. data.name_hex:gsub("#", ""), data.name_hex)
    return data
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")
  local entry_display = require("telescope.pickers.entry_display")

  local swatch_ns = vim.api.nvim_create_namespace("chroma_swatches")
  local inline_ns = vim.api.nvim_create_namespace("chroma_inline_swatches")

  local items = {}
  for _, name in ipairs(names) do
    local data = build_theme_data(name)
    if data then
      items[#items + 1] = data
    end
  end

  local displayer_items = { { width = 25 } }
  for _ = 1, #data_mod.INLINE_SWATCH_KEYS do
    displayer_items[#displayer_items + 1] = { width = 1 }
  end

  local displayer = entry_display.create({
    separator = " ",
    items = displayer_items,
  })

  local function make_display(entry)
    local data = entry.data
    local cols = { { data.display, data.name_hl } }
    for _, hex in ipairs(data.inline_swatches) do
      cols[#cols + 1] = { "󱓻", swatch_hl(hex) }
    end
    return displayer(cols)
  end

  local function select(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if entry and entry.value then
      chroma.apply(entry.value)
    end
  end

  local previewer = previewers.new_buffer_previewer({
    title = "",
    define_preview = function(self, entry)
      local data = entry.data
      if not data then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "unknown theme" })
        return
      end

      local preview_width = self.state.winid
          and vim.api.nvim_win_is_valid(self.state.winid)
          and vim.api.nvim_win_get_width(self.state.winid)
        or vim.o.columns
      local columns = preview_width >= (data_mod.CELL_W * 2 + 2) and 2 or 1
      local lines, spans = data_mod.preview_lines(data, columns)

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_clear_namespace(self.state.bufnr, swatch_ns, 0, -1)

      for _, span in ipairs(spans) do
        vim.api.nvim_buf_add_highlight(
          self.state.bufnr,
          swatch_ns,
          swatch_hl(span.hex),
          span.row,
          span.start,
          span.finish
        )
      end
    end,
  })

  pickers
    .new({}, {
      prompt_title = "",
      results_title = "",
      prompt_prefix = "   ",
      selection_caret = "",
      entry_prefix = "",

      layout_strategy = "vertical",
      layout_config = {
        width = 0.30,
        height = 0.7,
      },
      finder = finders.new_table({
        results = items,
        entry_maker = function(data)
          return {
            value = data.name,
            display = make_display,
            ordinal = data.name .. " " .. data.display,
            data = data,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewer,
      attach_mappings = function(prompt_bufnr, map)
        local picker = action_state.get_current_picker(prompt_bufnr)

        local has_linespace, prev_linespace = pcall(function()
          return vim.o.linespace
        end)
        local linespace_ok = has_linespace and pcall(function()
          vim.o.linespace = 18
        end)

        if linespace_ok then
          local augroup = vim.api.nvim_create_augroup("ChromaPickerLinespace", { clear = true })
          vim.api.nvim_create_autocmd("BufWipeout", {
            group = augroup,
            buffer = prompt_bufnr,
            once = true,
            callback = function()
              pcall(function()
                vim.o.linespace = prev_linespace
              end)
              pcall(vim.api.nvim_del_augroup_by_id, augroup)
            end,
          })
        end

        local function reapply_swatches(self)
          local bufnr = self and self.results_bufnr
          if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          if not self.manager or self.manager == false then
            return
          end

          vim.api.nvim_buf_clear_namespace(bufnr, inline_ns, 0, -1)

          local glyph = "󱓻"
          local glyph_bytes = #glyph
          local row = 0

          for entry in self.manager:iter() do
            local data = entry.data
            if data and data.inline_swatches then
              local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""

              local name_start = line:find(data.display, 1, true)
              if name_start and data.name_hl then
                vim.api.nvim_buf_set_extmark(bufnr, inline_ns, row, name_start - 1, {
                  end_col = name_start - 1 + #data.display,
                  hl_group = data.name_hl,
                  priority = 100,
                })
              end

              local from = 1
              for _, hex in ipairs(data.inline_swatches) do
                local swatch_start = line:find(glyph, from, true)
                if not swatch_start then
                  break
                end
                local start = swatch_start - 1
                vim.api.nvim_buf_set_extmark(bufnr, inline_ns, row, start, {
                  end_col = start + glyph_bytes,
                  hl_group = swatch_hl(hex),
                  priority = 100,
                })
                from = swatch_start + glyph_bytes
              end
            end
            row = row + 1
          end
        end

        picker:register_completion_callback(reapply_swatches)

        actions.select_default:replace(function()
          select(prompt_bufnr)
        end)
        map("i", "<C-c>", actions.close)
        map("n", "q", actions.close)
        return true
      end,
    })
    :find()
end

return M
