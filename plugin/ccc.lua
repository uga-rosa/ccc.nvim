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
