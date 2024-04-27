local utils = require("ccc.utils")
local api = require("ccc.utils.api")
local convert = require("ccc.utils.convert")

---@class ccc.UI
---@field prev_pos? ccc.Position For toggle_prev_colors()
---@field augroup integer
local UI = {}
UI.__index = UI

function UI.new()
  return setmetatable({
    ns_id = vim.api.nvim_create_namespace("ccc-ui-float-highlight"),
    augroup = vim.api.nvim_create_augroup("ccc-ui-float-close", {}),
    show_prev_colors = false,
  }, UI)
end

function UI:open(color, prev_colors)
  -- Avoid to nest ccc UI
  if vim.api.nvim_win_is_valid(self.winid or -1) then
    return
  end
  local opts = require("ccc.config").options
  self.color = color
  -- Store const. values for UI:buffer() in UI:update()
  self.before_color = color:copy()
  self.prev_colors = prev_colors
  -- Create new buffer and window and set text
  self.bufnr = vim.api.nvim_create_buf(false, true)
  local buffer, width = self:buffer()
  api.set_lines(self.bufnr, 0, -1, buffer)
  self:highlight(width)
  opts.win_opts.height = #buffer
  opts.win_opts.width = width
  self.winid = vim.api.nvim_open_win(self.bufnr, true, opts.win_opts)
  vim.api.nvim_win_set_hl_ns(self.winid, self.ns_id)
  -- Move cursor to the top color bar
  api.set_cursor(1, 0)
  -- Set options
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
  vim.api.nvim_set_option_value("filetype", "ccc-ui", { buf = self.bufnr })
  vim.api.nvim_set_option_value("signcolumn", "no", { win = self.winid })
  -- Set highlight
  local float_normal = vim.api.nvim_get_hl(0, { name = "CccFloatNormal" }) --[[@as vim.api.keyset.highlight]]
  local float_border = vim.api.nvim_get_hl(0, { name = "CccFloatBorder" }) --[[@as vim.api.keyset.highlight]]
  vim.api.nvim_set_hl(self.ns_id, "Normal", float_normal)
  vim.api.nvim_set_hl(self.ns_id, "EndOfBuffer", float_normal)
  vim.api.nvim_set_hl(self.ns_id, "FloatBorder", float_border)
  -- For callback
  self.is_quit = true
  -- Clean up on closing a window
  vim.api.nvim_clear_autocmds({ group = self.augroup })
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = self.winid .. "",
    group = self.augroup,
    callback = utils.bind(self.on_close, self),
    once = true,
  })
  if opts.auto_close then
    vim.api.nvim_create_autocmd("WinLeave", {
      buffer = self.bufnr,
      group = self.augroup,
      callback = utils.bind(self.close, self),
      once = true,
    })
  end
end

function UI:update()
  if not vim.api.nvim_win_is_valid(self.winid or -1) then
    return
  end
  local buffer, width = self:buffer()
  api.set_lines(self.bufnr, 0, -1, buffer)
  self:highlight(width)
  vim.api.nvim_win_set_config(self.winid, { height = #buffer, width = width })
  -- In v0.9.5, nvim_win_set_config() destroys the association between window and namespace.
  -- This bug is fixed in nightly.
  vim.api.nvim_win_set_hl_ns(self.winid, self.ns_id)
end

--- Close UI manually.
function UI:close()
  vim.api.nvim_clear_autocmds({ group = self.augroup })
  -- A floating window is automatically closed by nvim_buf_delete().
  vim.api.nvim_buf_delete(self.bufnr, { force = true })
  self:on_close()
end

--- Called on closing UI.
function UI:on_close()
  self.bufnr = nil
  self.winid = nil
  self.before_color = nil
  self.prev_colors = nil
  if self.is_quit and self.on_quit_callback then
    self.on_quit_callback()
  end
end

---@param open? boolean If true/false, shows/hides view; if nil, toggles.
function UI:toggle_prev_colors(open)
  if open then
    self.prev_pos = { api.get_cursor() }
    self.show_prev_colors = true
    self:update()
    self.prev_colors._index = 1
    self:set_point({ type = "prev", index = 1 })
  elseif open == false then
    self.show_prev_colors = false
    self:update()
    api.set_cursor(unpack(self.prev_pos))
  else
    open = not self.show_prev_colors
    self:toggle_prev_colors(open)
  end
end

-- Hides an alpha slider and prev colors.
function UI:reset_view()
  self.color.alpha:hide()
  self.show_prev_colors = false
  self:update()
end

function UI:point_at()
  local row, col = api.get_cursor()
  local num_color = #self.color:input():get()
  if row > 0 and row < num_color + 1 then
    return { type = "color", index = row }
  elseif not self.color.alpha.is_hide and row == num_color + 1 then
    return { type = "alpha" }
  elseif self.show_prev_colors and row == vim.fn.line("$") - 1 then
    return { type = "prev", index = math.floor(col / 8) + 1 }
  end
  return { type = "none" }
end

function UI:set_point(point)
  local row, col = 0, 0
  if point.type == "color" then
    row = point.index
  elseif point.type == "alpha" and not self.color.alpha.is_hide then
    row = #self.color:input().value + 1
  elseif point.type == "prev" and self.show_prev_colors then
    row = vim.api.nvim_buf_line_count(self.bufnr) - 1
    col = point.index * 8 - 8
  end
  api.set_cursor(row, col)
end

---@param value number
---@param min number
---@param max number
---@return integer
local function adjust2bar(value, min, max)
  local opts = require("ccc.config").options
  return utils.round((value - min) / (max - min) * opts.bar_len)
end

---@param value number
---@param min number
---@param max number
---@return string
local function create_bar(value, min, max)
  local opts = require("ccc.config").options
  local point_idx = adjust2bar(value, min, max)
  if point_idx == 0 then
    return opts.point_char .. opts.bar_char:rep(opts.bar_len - 1)
  end
  return opts.bar_char:rep(point_idx - 1) .. opts.point_char .. opts.bar_char:rep(opts.bar_len - point_idx)
end

---@private
---@return string[]
---@return integer
function UI:buffer()
  local opts = require("ccc.config").options
  local input = self.color:input()

  local buffer = {}
  -- Title
  table.insert(buffer, input.name)
  -- Color sliders
  for i, v in ipairs(input.value) do
    local line = ("%s : %s %s"):format(input.bar_name[i], input.format(v, i), create_bar(v, input.min[i], input.max[i]))
    table.insert(buffer, line)
  end
  local width = vim.api.nvim_strwidth(buffer[2])
  -- Alpha slider
  local alpha = self.color.alpha:get()
  if alpha then
    local line = ("A%s : %s %s"):format(
      (" "):rep(#input.bar_name[1] - 1),
      self.color.alpha:str(),
      create_bar(alpha, 0, 1)
    )
    table.insert(buffer, line)
  end
  -- Output
  local output_line = opts.output_line(self.before_color, self.color, width)
  table.insert(buffer, output_line)
  -- Prev colors
  if self.show_prev_colors then
    table.insert(buffer, self.prev_colors:str())
  end

  return buffer, width
end

---@private
---@param width integer
function UI:highlight(width)
  local opts = require("ccc.config").options
  vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)

  -- No highlight for title
  local row = 0

  -- Color sliders
  local bar_name_len = #self.color:input().bar_name[1]
  for i, v in ipairs(self.color:get()) do
    row = row + 1
    local min = self.color:input().min[i]
    local max = self.color:input().max[i]
    local point_idx = adjust2bar(v, min, max)

    -- {bar_name} + " : " + {formatted_value} + " "
    -- {formatted_value} is must be 6 byte (See `ccc.ColorInput.format()`)
    -- So, +10 (0-indexed)
    local start_col, end_col = bar_name_len + 10, 0
    for j = 1, opts.bar_len do
      -- Update end_
      if j == point_idx then
        end_col = start_col + #opts.point_char
      else
        end_col = start_col + #opts.bar_char
      end
      -- Calculate a new color for highlight of a slider
      local new_value = (j - 0.5) / opts.bar_len * (max - min) + min
      local hex = self.color:hex(i, new_value)
      local hl = { fg = hex }
      if j == point_idx then
        if not opts.empty_point_bg then
          local RGB = self.color:get_rgb()
          local R, G, B = convert.rgb_format(RGB)
          hl = {
            fg = utils.is_bright_RGB(R, G, B) and opts.point_color_on_light or opts.point_color_on_dark,
            bg = hex,
          }
        end
        if opts.point_color ~= "" then
          hl.fg = opts.point_color
        end
      end
      -- Set highlight
      local color_name = "CccBar" .. i .. "_" .. j
      api.set_hl(self.bufnr, self.ns_id, { row, start_col, row, end_col }, color_name, hl)

      start_col = end_col
    end
  end

  -- Alpha slider
  local alpha = self.color.alpha:get()
  if alpha then
    row = row + 1
    local point_idx = adjust2bar(alpha, 0, 1)

    local start_col, end_col = bar_name_len + 10, 0
    for i = 1, opts.bar_len do
      -- Update end_
      if i == point_idx then
        end_col = start_col + #opts.point_char
      else
        end_col = start_col + #opts.bar_char
      end
      -- Calculate a new color for highlight of an alpha slider
      local alpha_ratio = (i - 0.5) / opts.bar_len
      local hex = self.color.alpha:hex(alpha_ratio)
      local hl = { fg = hex }
      if i == point_idx then
        if not opts.empty_point_bg then
          hl = {
            fg = alpha_ratio > 0.5 and opts.point_color_on_dark or opts.point_color_on_light,
            bg = hex,
          }
        end
        if opts.point_char ~= "" then
          hl.fg = opts.point_color
        end
      end
      local color_name = "CccAlpha" .. i
      api.set_hl(self.bufnr, self.ns_id, { row, start_col, row, end_col }, color_name, hl)

      start_col = end_col
    end
  end

  -- Output
  row = row + 1

  -- {bar_name} : {color_name: 6byte} {slider}
  local _, b_start, b_end, a_start, a_end = opts.output_line(self.before_color, self.color, width)

  api.set_hl(
    self.bufnr,
    self.ns_id,
    { row, b_start, row, b_end },
    "CccBefore",
    utils.create_highlight(self.before_color:hex(), opts.highlight_mode)
  )
  api.set_hl(
    self.bufnr,
    self.ns_id,
    { row, a_start, row, a_end },
    "CccAfter",
    utils.create_highlight(self.color:hex(), opts.highlight_mode)
  )

  -- Prev colors
  if self.show_prev_colors then
    row = row + 1
    local start_col, end_col = 0, 7
    for i, c in ipairs(self.prev_colors:get_all()) do
      api.set_hl(
        self.bufnr,
        self.ns_id,
        { row, start_col, row, end_col },
        "CccPrev" .. i,
        utils.create_highlight(c:hex(), opts.highlight_mode)
      )
      start_col = end_col + 1
      end_col = start_col + 7
    end
  end
end

return UI
