local utils = require("ccc.utils")
local api = require("ccc.utils.api")
local hl = require("ccc.handler.highlight")

---@class ccc.LspHandler
---@field enabled boolean
---@field color_info_map table<integer, lsp.ColorInformation[]> Keys are bufnrs
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
  if not utils.bufnr_is_valid(bufnr) then
    self.color_info_map[bufnr] = nil
    return
  end
  vim.api.nvim_create_autocmd("LspAttach", {
    buffer = bufnr,
    callback = function()
      self:update(bufnr)
    end,
    once = true,
  })
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
  local method = "textDocument/documentColor"
  local param = { textDocument = vim.lsp.util.make_text_document_params() }

  ---@diagnostic disable-next-line
  local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({ bufnr = bufnr })
  clients = vim.tbl_filter(function(client)
    return client.supports_method(method, { bufnr = bufnr })
  end, clients)
  -- Number of clients who responsed
  local result_count = 0
  local color_informations = {}
  for _, client in ipairs(clients) do
    client.request(method, param, function(err, result)
      result_count = result_count + 1
      if result and err == nil then
        vim.list_extend(color_informations, result)
      end
      -- Responses have been received from all expected clients
      if result_count >= #clients then
        self.color_info_map[bufnr] = color_informations
      end
    end)
  end
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
      local hl_name = hl.ensure_hl_name({ color.red, color.green, color.blue })
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
