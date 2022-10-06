set termguicolors

let s:plug_dir = expand('/tmp/plugged/vim-plug')
if !filereadable(s:plug_dir .. '/autoload/plug.vim')
  execute printf('!curl -fLo %s/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', s:plug_dir)
end

execute 'set runtimepath+=' . s:plug_dir
call plug#begin(s:plug_dir)
Plug 'uga-rosa/ccc.nvim'
Plug 'neovim/nvim-lspconfig'
call plug#end()
PlugInstall | quit

lua <<EOF
local ccc = require("ccc")
local mapping = ccc.mapping

ccc.setup({
    -- Minimal configurations required to reproduce the problem.
})

require("lspconfig").cssls.setup({})
EOF
