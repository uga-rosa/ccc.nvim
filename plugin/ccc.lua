if vim.g.loaded_ccc then
    return
end
vim.g.loaded_ccc = true

vim.api.nvim_create_user_command("CccPick", function()
    require("ccc.ui"):open(false)
end, {})

vim.keymap.set("i", "<Plug>(ccc-insert)", function()
    require("ccc.ui"):open(true)
end)

vim.api.nvim_create_user_command("CccHighlighterEnable", function(opt)
    local bufnr = tonumber(opt.args)
    require("ccc.highlighter"):enable(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccHighlighterDisable", function(opt)
    local bufnr = tonumber(opt.args)
    require("ccc.highlighter"):disable(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccHighlighterToggle", function(opt)
    local bufnr = tonumber(opt.args)
    require("ccc.highlighter"):toggle(bufnr)
end, { nargs = "?" })

vim.api.nvim_create_user_command("CccConvert", function()
    require("ccc.convert"):toggle()
end, {})

vim.cmd([[
hi def link CccFloatNormal NormalFloat
hi def link CccFloatBorder FloatBorder
]])
