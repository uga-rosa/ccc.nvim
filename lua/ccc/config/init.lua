local M = {}

---@type ccc.Options
---@diagnostic disable-next-line
M.options = {}

---@param opts ccc.Options.P
function M.setup(opts)
  -- Merge user options to default one.
  local default = require("ccc.config.default")
  if opts.disable_default_mappings then
    default = vim.tbl_extend("force", {}, default, { mappings = {} })
  end
  M.options = vim.tbl_deep_extend("force", {}, default, M.options, opts)
  for lhs, rhs in pairs(M.options.mappings) do
    if rhs == require("ccc.mapping").none then
      M.options.mappings[lhs] = nil
    end
  end
end

return M
