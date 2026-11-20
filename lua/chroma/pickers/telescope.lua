local M = {}

local chroma = require("chroma")
local engine = require("chroma.engine.apply")
local data_mod = require("chroma.pickers.data")

function M.pick()
  local names = chroma.list()
  if #names == 0 then
    vim.notify("[chroma] no themes found on runtimepath", vim.log.levels.ERROR)
    return
  end

  -- Snapshot the active theme so it can be silently restored if the picker is dismissed.
  local original_theme = chroma.current()
  local previewed_theme = original_theme
  local pending_id = 0

  local defined_hl = {}

  local function define_hl(group, hex)
    if not defined_hl[group] then
      vim.api.nvim_set_hl(0, group, { fg = hex })
      defined_hl[group] = hex -- store hex so groups can be re-defined after engine.apply's hi clear
    end
    return group
  end

  local function redefine_swatch_hls()
    for group, hex in pairs(defined_hl) do
      vim.api.nvim_set_hl(0, group, { fg = hex })
    end
  end

  local function preview_theme(name)
    if name == previewed_theme then
      return
    end
    -- Debounce: only the last move within 80 ms actually fires.
    pending_id = pending_id + 1
    local my_id = pending_id
    vim.defer_fn(function()
      if my_id ~= pending_id then
        return
      end
      local theme = chroma.find(name)
      if not theme then
        return
      end
      previewed_theme = name
      pcall(engine.apply, name, theme, chroma.config, { fire_event = false })
      redefine_swatch_hls()
      if package.loaded["lualine"] then
        pcall(function()
          require("lualine").setup()
        end)
      end
      vim.cmd("redrawstatus!")
    end, 80)
  end

  local function restore_original()
    -- Invalidate any pending preview so it doesn't fire after restore.
    pending_id = pending_id + 1
    if previewed_theme == original_theme then
      return
    end
    local theme = chroma.find(original_theme)
    if theme then
      pcall(engine.apply, original_theme, theme, chroma.config, { fire_event = false })
      redefine_swatch_hls()
      if package.loaded["lualine"] then
        pcall(function()
          require("lualine").setup()
        end)
      end
      vim.cmd("redrawstatus!")
    end
    previewed_theme = original_theme
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
  local entry_display = require("telescope.pickers.entry_display")

  local inline_ns = vim.api.nvim_create_namespace("chroma_inline_swatches")

  local items = {}
  local max_name_len = 0

  for _, name in ipairs(names) do
    local data = build_theme_data(name)
    if data then
      max_name_len = math.max(max_name_len, vim.fn.strdisplaywidth(data.display))
      items[#items + 1] = data
    end
  end

  local gap_width = 6
  local name_col_width = max_name_len + gap_width

  local displayer_items = {
    { width = name_col_width },
  }
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
    restore_original()
    actions.close(prompt_bufnr)
    if entry and entry.value then
      chroma.apply(entry.value)
    end
  end

  local num_swatches = #data_mod.INLINE_SWATCH_KEYS
  local total_content_width = name_col_width + (num_swatches * 2) + 4

  pickers
    .new({}, {
      prompt_title = "",
      results_title = "󱥚 Themes",
      prompt_prefix = "   ",
      selection_caret = "",
      entry_prefix = "",

      layout_strategy = "vertical",
      layout_config = {
        width = total_content_width,
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
      previewer = false,
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

        local function preview_selected()
          local entry = action_state.get_selected_entry()
          if entry and entry.value then
            preview_theme(entry.value)
          end
        end

        -- Live preview: hook into Telescope's selection actions so arrow-key navigation
        -- triggers preview. CursorMoved on results_bufnr covers mouse clicks (the cursor
        -- physically moves there), but does NOT fire for arrow keys because the cursor
        -- stays in the prompt buffer while Telescope updates the highlight internally.
        local next_with_preview = actions.move_selection_next:enhance({ post = preview_selected })
        local prev_with_preview = actions.move_selection_previous:enhance({ post = preview_selected })
        map("i", "<Down>", next_with_preview)
        map("i", "<Up>", prev_with_preview)
        map("n", "j", next_with_preview)
        map("n", "k", prev_with_preview)
        map("i", "<C-n>", next_with_preview)
        map("i", "<C-p>", prev_with_preview)

        local preview_augroup = vim.api.nvim_create_augroup("ChromaPickerPreview", { clear = true })
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = preview_augroup,
          buffer = picker.results_bufnr,
          callback = preview_selected,
        })

        -- Restore the original theme whenever the picker closes (dismiss or select).
        vim.api.nvim_create_autocmd("BufWipeout", {
          group = preview_augroup,
          buffer = prompt_bufnr,
          once = true,
          callback = function()
            restore_original()
            pcall(vim.api.nvim_del_augroup_by_id, preview_augroup)
          end,
        })

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
