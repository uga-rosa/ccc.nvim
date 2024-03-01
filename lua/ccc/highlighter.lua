local utils = require("ccc.utils")
local api = require("ccc.utils.api")
local lsp_handler = require("ccc.handler.lsp")
local picker_handler = require("ccc.handler.picker")

---@class ccc.Highlighter
---@field picker_ns_id integer
---@field lsp_ns_id integer
---@field custom_ns_id integer
---@field attached_buffer table<integer, boolean> Keys are bufnrs.
---@field is_defined table<string, boolean> Keys are highlight names.
local Highlighter = {
  picker_ns_id = vim.api.nvim_create_namespace("ccc-highlighter-picker"),
  lsp_ns_id = vim.api.nvim_create_namespace("ccc-highlighter-lsp"),
  custom_ns_id = vim.api.nvim_create_namespace("ccc-highlighter-custom"),
  attached_buffer = {},
  is_defined = {},
}

function Highlighter:init()
  local opts = require("ccc.config").options
  if opts.highlighter.auto_enable then
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Re-highlight only visible buffers.
        local visible_buf = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          visible_buf[vim.api.nvim_win_get_buf(win)] = true
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
  if not opts.highlighter.update_insert then
    vim.api.nvim_create_autocmd("InsertLeave", {
      callback = function(args)
        self:update(args.buf, 0, -1)
      end,
    })
  end
end

---Return true if ft is valid.
---@param ft string
---@return boolean
local function ft_filter(ft)
  -- Disable in UI
  if ft == "ccc-ui" then
    return false
  end
  local opts = require("ccc.config").options
  if not opts.highlighter.auto_enable then
    return true
  elseif #opts.highlighter.filetypes > 0 then
    return vim.tbl_contains(opts.highlighter.filetypes, ft)
  else
    return not vim.tbl_contains(opts.highlighter.excludes, ft)
  end
end

---@param bufnr? integer
function Highlighter:enable(bufnr)
  bufnr = utils.ensure_bufnr(bufnr)
  if self.attached_buffer[bufnr] then
    return
  end
  -- filetype filter for auto_enable
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if not ft_filter(filetype) then
    return
  end
  self.attached_buffer[bufnr] = true
  self:update(bufnr, 0, -1)

  local opts = require("ccc.config").options
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function(_, _, _, first_line, _, last_line)
      if self.attached_buffer[bufnr] == nil then
        return true
      elseif not opts.highlighter.update_insert and vim.fn.mode() == "i" then
        return
      end
      -- Without vim.schedule(), it does not update correctly when undo/redo
      vim.schedule(function()
        self:update(bufnr, first_line, last_line)
      end)
    end,
    on_detach = function()
      self.attached_buffer[bufnr] = nil
    end,
  })
end

---@param bufnr? integer
function Highlighter:disable(bufnr)
  bufnr = utils.ensure_bufnr(bufnr)
  self.attached_buffer[bufnr] = nil
  vim.api.nvim_buf_clear_namespace(bufnr, self.lsp_ns_id, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, self.picker_ns_id, 0, -1)
end

---@param bufnr? integer
function Highlighter:toggle(bufnr)
  bufnr = utils.ensure_bufnr(bufnr)
  if self.attached_buffer[bufnr] then
    self:disable(bufnr)
  else
    self:enable(bufnr)
  end
end

---@param bufnr integer
---@param start_line integer
---@param end_line integer
---@param pickers? ccc.ColorPicker[]
function Highlighter:update(bufnr, start_line, end_line, pickers)
  if pickers then
    local custom_info = picker_handler.info_in_range(bufnr, start_line, end_line, pickers)
    vim.api.nvim_buf_clear_namespace(bufnr, self.custom_ns_id, start_line, end_line)
    for _, info in ipairs(custom_info) do
      api.set_hl(bufnr, self.custom_ns_id, info.range, info.hl_name)
    end
    return
  end

  local opts = require("ccc.config").options
  if opts.highlighter.lsp then
    local lsp_info = lsp_handler:info_in_range(bufnr, start_line, end_line)
    vim.api.nvim_buf_clear_namespace(bufnr, self.lsp_ns_id, start_line, end_line)
    for _, info in ipairs(lsp_info) do
      api.set_hl(bufnr, self.lsp_ns_id, info.range, info.hl_name)
    end
  end
  if opts.highlighter.picker then
    local picker_info = picker_handler.info_in_range(bufnr, start_line, end_line)
    vim.api.nvim_buf_clear_namespace(bufnr, self.picker_ns_id, start_line, end_line)
    for _, info in ipairs(picker_info) do
      api.set_hl(bufnr, self.picker_ns_id, info.range, info.hl_name)
    end
  end
end

return Highlighter
