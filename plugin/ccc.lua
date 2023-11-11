if vim.g.loaded_ccc then
  return
end
vim.g.loaded_ccc = true

require("ccc").setup()

vim.api.nvim_create_user_command("CccPick", function()
  require("ccc.ui"):open(false)
end, {})

vim.keymap.set("i", "<Plug>(ccc-insert)", function()
  require("ccc.ui"):open(true)
end)

vim.keymap.set("o", "<Plug>(ccc-select-color)", function()
  require("ccc.ui"):select_color("v")
end)

vim.keymap.set("v", "<Plug>(ccc-select-color)", function()
  require("ccc.ui"):select_color("o")
end)

local highlighter = require("ccc.highlighter").new(true)

vim.api.nvim_create_user_command("CccHighlighterEnable", function(opt)
  local bufnr = tonumber(opt.args)
  highlighter:enable(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccHighlighterDisable", function(opt)
  local bufnr = tonumber(opt.args)
  highlighter:disable(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccHighlighterToggle", function(opt)
  local bufnr = tonumber(opt.args)
  highlighter:toggle(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccConvert", function()
  require("ccc.convert"):toggle()
end, {})

vim.cmd([[
hi def link CccFloatNormal NormalFloat
hi def link CccFloatBorder FloatBorder
]])
