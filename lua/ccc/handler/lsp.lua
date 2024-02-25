local utils = require("ccc.utils")
local api = require("ccc.utils.api")
local hl = require("ccc.handler.highlight")

---@class ccc.LspHandler
---@field enabled boolean
---@field color_info_map table<integer, lsp.ColorInformation[]> Keys are bufnrs
---@field update_callback? fun(bufnr: integer)
local LspHandler = {
  enabled = false,
  color_info_map = {},
}

function LspHandler:enable()
  self.enabled = true
  -- attach to current buffer
  self:attach(0)
  -- attach on LspAttach
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      self:attach(args.buf)
    end,
  })
end

function LspHandler:disable()
  self.enabled = false
  self.color_info_map = {}
end

---@param bufnr integer
function LspHandler:attach(bufnr)
  bufnr = utils.ensure_bufnr(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    self.color_info_map[bufnr] = nil
    return
  end
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      if not self.enabled then
        return true
      end
      self:update(bufnr)
    end,
  })
end

---@private
---Asynchronously update color informations
---@param bufnr integer
function LspHandler:update(bufnr)
  local param = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request_all(bufnr, "textDocument/documentColor", param, function(resps)
    local color_informations = {}
    for _, resp in pairs(resps) do
      if resp.result and resp.error == nil then
        vim.list_extend(color_informations, resp.result)
      end
    end
    self.color_info_map[bufnr] = color_informations
    if self.update_callback then
      self.update_callback(bufnr)
    end
  end)
end

---Whether the cursor is within range
---@param range lsp.Range
---@param cursor { [1]: integer, [2]: integer  } (0,0)-index
local function is_within(range, cursor)
  local within = true
  -- lsp.Range is 0-based and the end position is exclusive.
  within = within and range.start.line <= cursor[1]
  within = within and range.start.character <= cursor[2]
  within = within and range["end"].line >= cursor[1]
  within = within and range["end"].character > cursor[2]
  return within
end

---@return integer? start_col 1-indexed
---@return integer? end_col 1-indexed, inclusive
---@return RGB?
---@return Alpha?
function LspHandler:pick()
  local bufnr = utils.ensure_bufnr(0)
  local color_infos = self.color_info_map[bufnr] or {}
  local cursor = { api.get_cursor() }
  for _, color_info in ipairs(color_infos) do
    local range = color_info.range
    local color = color_info.color
    if is_within(range, cursor) then
      return range.start.character + 1, range["end"].character, { color.red, color.green, color.blue }, color.alpha
    end
  end
end

---@param bufnr integer
---@param start_line integer 0-based
---@param end_line integer 0-based
---@return ccc.hl_info[]
function LspHandler:info_in_range(bufnr, start_line, end_line)
  local color_infos = self.color_info_map[bufnr] or {}
  local infos = {}
  for _, color_info in ipairs(color_infos) do
    local range = color_info.range
    local color = color_info.color
    if range.start.line >= start_line and range["end"].line <= end_line then
      local hl_name = hl.ensure_hl_name({ color.alpha, color.green, color.blue })
      table.insert(infos, {
        range = {
          range.start.line,
          range.start.character,
          range["end"].line,
          range["end"].character,
        },
        hl_name = hl_name,
      })
    end
  end
  return infos
end

return LspHandler
