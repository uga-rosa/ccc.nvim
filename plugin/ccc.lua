if vim.g.loaded_ccc then
    return
end
vim.g.loaded_ccc = true

require("ccc").setup(true)

vim.api.nvim_create_user_command("CccStart", function()
    require("ccc.ui"):open(false)
end, {})
vim.api.nvim_create_user_command("CccInsert", function()
    require("ccc.ui"):open(true)
end, {})
