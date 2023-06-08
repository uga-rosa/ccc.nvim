---@class TrailingWhitespacePicker: ColorPicker
---@field ft2color table<string, RGB>
---@field filter table<string, boolean>
---@field already_in_insert boolean
---@field highlighter? Highlighter
local TrailingWhitespacePicker = {}

---@class TrailingWhitespaceConfig
---@field palette table<string, string> Keys are filetypes, values are colors (hex)
---@field default_color string Hex
---@field enable string[]|true List of filetypes for which highlighting is enabled or true.
---@field disable string[]|fun(bufnr: number): boolean List of filetypes to disable highlighting or a function that returns true when you want to disable it
local default = {
  palette = {},
  default_color = "#db7093",
  enable = true,
  disable = {},
}

local contains = vim.list_contains or vim.tbl_contains

---@param opts? TrailingWhitespaceConfig
---@return TrailingWhitespacePicker
function TrailingWhitespacePicker.new(opts)
  opts = vim.tbl_extend("keep", opts or {}, default)

  local palette = {}
  for ft, hex in pairs(opts.palette) do
    palette[ft] = hex
  end
  local default_color = opts.default_color
  local ft2color = setmetatable(palette, {
    __index = function()
      return default_color
    end,
  })

  local filter
  if opts.enable == true then
    if type(opts.disable) == "table" then
      function filter(bufnr)
        local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
        return not contains(opts.disable, ft)
      end
    elseif type(opts.disable) == "function" then
      function filter(bufnr)
        return not opts.disable(bufnr)
      end
    end
  else
    function filter(bufnr)
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      return contains(opts.enable, ft)
    end
  end

  return setmetatable({
    ft2color = ft2color,
    filter = filter,
  }, { __index = TrailingWhitespacePicker })
end

---@param s string
---@param init? integer
---@param bufnr? integer
---@return integer? start
---@return integer? end_
---@return nil
---@return nil
---@return highlightDefinition?
function TrailingWhitespacePicker:parse_color(s, init, bufnr)
  bufnr = vim.F.if_nil(bufnr, 0)
  if not self.filter(bufnr) then
    return
  end
  if vim.startswith(vim.fn.mode(), "i") then
    if not self.already_in_insert then
      if self.highlighter == nil then
        -- Can't initialize in new() because setup() must be called before highlighter.new()
        self.highlighter = require("ccc.highlighter").new(false)
        self.highlighter.pickers = { self }
      end
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function(opts)
          self.highlighter:update_picker(opts.buf, 0, -1, true)
          self.already_in_insert = false
        end,
        once = true,
      })
      self.already_in_insert = true
    end
    return
  end
  local start, end_ = s:find("%s+$", init or 1)
  if start then
    local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
    local hex = self.ft2color[ft]
    return start, end_, nil, nil, { bg = hex }
  end
end

return TrailingWhitespacePicker.new
