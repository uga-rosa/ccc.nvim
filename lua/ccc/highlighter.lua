local api = vim.api

local config = require("ccc.config")
local utils = require("ccc.utils")
local rgb2hex = require("ccc.output.hex").str

---@alias ls_color { row: integer, start: integer, end_: integer, rgb: number[], alpha: number }

---@class Highlighter
---@field pickers ColorPicker[]
---@field picker_ns_id integer
---@field lsp_ns_id integer
---@field is_defined table<string, boolean> #Set. Keys are hexes.
---@field ft_filter table<string, boolean>
---@field lsp boolean
---@field hl_mode hl_mode
---@field attached_buffer table<integer, boolean>
---@field ls_colors table<integer, ls_color[]> #Keys are bufnr
local Highlighter = {}

function Highlighter:init()
  if self.pickers ~= nil then
    return
  end

  self.pickers = config.get("pickers")
  self.picker_ns_id = api.nvim_create_namespace("ccc-highlighter-picker")
  self.lsp_ns_id = api.nvim_create_namespace("ccc-highlighter-lsp")
  self.is_defined = {}
  local highlighter_config = config.get("highlighter")
  local filetypes = highlighter_config.filetypes
  local ft_filter = {}
  if #filetypes > 0 then
    for _, v in ipairs(filetypes) do
      ft_filter[v] = true
    end
  else
    for _, v in ipairs(highlighter_config.excludes) do
      ft_filter[v] = false
    end
    setmetatable(ft_filter, {
      __index = function()
        return true
      end,
    })
  end
  self.ft_filter = ft_filter
  self.lsp = highlighter_config.lsp
  self.hl_mode = config.get("highlight_mode")
  self.attached_buffer = {}
  self.ls_colors = {}

  api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      -- Re-highlight only visible buffers.
      local visible_buf = {}
      for _, win in ipairs(api.nvim_list_wins()) do
        visible_buf[api.nvim_win_get_buf(win)] = true
      end
      self.is_defined = {}
      for bufnr in pairs(self.attached_buffer) do
        if visible_buf[bufnr] then
          self:update(bufnr, 0, -1)
        else
          self:disable(bufnr)
        end
      end
    end,
  })
end

---@param bufnr? integer
---@param filter? boolean
function Highlighter:enable(bufnr, filter)
  self:init()
  if filter and not self.ft_filter[vim.bo.filetype] then
    return
  end

  bufnr = utils.resolve_bufnr(bufnr)

  if self.attached_buffer[bufnr] then
    return
  end
  self.attached_buffer[bufnr] = true

  self:start(bufnr)

  api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, _, _, first_line, _, last_line)
      if self.attached_buffer[bufnr] == nil then
        return true
      end
      self:update(bufnr, first_line, last_line)
    end,
    on_detach = function()
      self.attached_buffer[bufnr] = nil
    end,
  })
end

---@param bufnr? integer
function Highlighter:disable(bufnr)
  self:init()
  bufnr = utils.resolve_bufnr(bufnr)
  self.attached_buffer[bufnr] = nil
  api.nvim_buf_clear_namespace(bufnr, self.picker_ns_id, 0, -1)
  api.nvim_buf_clear_namespace(bufnr, self.lsp_ns_id, 0, -1)
end

---@param bufnr? integer
function Highlighter:toggle(bufnr)
  self:init()
  bufnr = utils.resolve_bufnr(bufnr)
  if self.attached_buffer[bufnr] then
    self:disable(bufnr)
  else
    self:enable(bufnr)
  end
end

---@param bufnr integer
function Highlighter:start(bufnr)
  vim.schedule(function()
    if self.lsp then
      if not self:update_lsp(bufnr) then
        -- Wait for LS initialization
        vim.defer_fn(function()
          if not self.attached_buffer[bufnr] then
            return
          end
          if not self:update_lsp(bufnr) then
            self:update_picker(bufnr, 0, -1)
          end
        end, 200)
      end
    else
      self:update_picker(bufnr, 0, -1)
    end
  end)
end

---@param bufnr integer
---@param first_line integer 0-index
---@param last_line integer 0-index
function Highlighter:update(bufnr, first_line, last_line)
  vim.schedule(function()
    if not (self.lsp and self:update_lsp(bufnr)) then
      self:update_picker(bufnr, first_line, last_line)
    end
  end)
end

---@param rgb number[]
---@return string hl_name
function Highlighter:_get_or_create_hl(rgb)
  local hex = rgb2hex(rgb)
  local hl_name = "CccHighlighter" .. hex:sub(2)
  if not self.is_defined[hex] then
    local highlight = utils.create_highlight(hex, self.hl_mode)
    api.nvim_set_hl(0, hl_name, highlight)
    self.is_defined[hex] = true
  end
  return hl_name
end

---@param bufnr integer
---@return boolean available
function Highlighter:update_lsp(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local available = false
  api.nvim_buf_clear_namespace(bufnr, self.lsp_ns_id, 0, -1)

  self.ls_colors[bufnr] = {}
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
    if client.server_capabilities.colorProvider then
      local param = { textDocument = vim.lsp.util.make_text_document_params() }
      ---@param err any
      ---@param color_informations lsp.ColorInformation[]
      client.request("textDocument/documentColor", param, function(err, color_informations)
        if err or color_informations == nil then
          return
        end
        available = #color_informations > 0

        for _, color_info in ipairs(color_informations) do
          local color = color_info.color
          local range = color_info.range

          local ls_color = self._create_ls_color(range, color)
          table.insert(self.ls_colors[bufnr], ls_color)

          local hl_name = self:_get_or_create_hl(ls_color.rgb)
          api.nvim_buf_add_highlight(0, self.lsp_ns_id, hl_name, ls_color.row - 1, ls_color.start - 1, ls_color.end_)
        end
      end)
    end
  end

  return available
end

---@param range lsp.Range
---@param color lsp.Color
---@return ls_color
function Highlighter._create_ls_color(range, color)
  -- To end-included 1-index
  local row = range.start.line + 1
  local start = range.start.character + 1
  local end_ = range["end"].character
  local rgb = { color.red, color.green, color.blue }
  local alpha = color.alpha or 1
  return { row = row, start = start, end_ = end_, rgb = rgb, alpha = alpha }
end

---@param bufnr? integer
---@return ls_color[]?
function Highlighter:get_ls_color(bufnr)
  bufnr = utils.resolve_bufnr(bufnr)
  if self.ls_colors then
    return self.ls_colors[bufnr]
  end
end

---@param bufnr integer
---@param start_row integer 0-index
---@param end_row integer 0-index
function Highlighter:update_picker(bufnr, start_row, end_row)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  api.nvim_buf_clear_namespace(bufnr, self.picker_ns_id, start_row, end_row)
  for i, line in ipairs(api.nvim_buf_get_lines(bufnr, start_row, end_row, false)) do
    local row = start_row + i - 1
    local init = 1
    while true do
      local start, end_, RGB
      for _, picker in ipairs(self.pickers) do
        local s_, e_, rgb = picker:parse_color(line, init)
        if s_ and (start == nil or s_ < start) then
          start = s_
          end_ = e_
          RGB = rgb
        end
      end
      if RGB == nil then
        break
      end
      local hl_name = self:_get_or_create_hl(RGB)
      api.nvim_buf_add_highlight(bufnr, self.picker_ns_id, hl_name, row, start - 1, end_)
      init = end_ + 1
    end
  end
end

return Highlighter
