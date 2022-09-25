if vim.g.loaded_ccc then
    return
end
vim.g.loaded_ccc = true

require("ccc").setup(true)

vim.api.nvim_create_user_command("CccPick", function()
    require("ccc.ui"):open(false)
end, {})

vim.keymap.set("i", "<Plug>(ccc-insert)", function()
    require("ccc.ui"):open(true)
end)

vim.api.nvim_create_user_command("CccHighlighterEnable", function()
    require("ccc.highlighter"):enable()
end, {})

vim.api.nvim_create_user_command("CccHighlighterDisable", function()
    require("ccc.highlighter"):disable()
end, {})

vim.api.nvim_create_user_command("CccHighlighterToggle", function()
    require("ccc.highlighter"):toggle()
end, {})

vim.api.nvim_create_user_command("CccConvert", function()
    require("ccc.convert"):toggle()
end, {})

vim.cmd([[
hi def link CccFloatNormal NormalFloat
hi def link CccFloatBorder FloatBorder
]])
