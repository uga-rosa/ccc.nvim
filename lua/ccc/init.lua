local function loader(root)
  return function(self, key)
    local modname = table.concat({ "ccc", root, key }, ".")
    local ok, module = pcall(require, modname)
    if not ok then
      vim.notify("Unknown module: " .. modname)
      return
    end
    rawset(self, key, module)
    return module
  end
end

---@param user_opts? ccc.Options.P
local function setup(user_opts)
  user_opts = user_opts or {}
  require("ccc.config").setup(user_opts)
  local opts = require("ccc.config").options

  if opts.lsp then
    require("ccc.handler.lsp"):enable()
  end

  local core = require("ccc.core").new()
  vim.api.nvim_create_user_command("CccPick", function()
    core:pick()
  end, {})
  vim.keymap.set("i", "<Plug>(ccc-insert)", function()
    core:insert()
  end)

  vim.keymap.set("o", "<Plug>(ccc-select-color)", function()
    require("ccc.select").select("v")
  end)
  vim.keymap.set("x", "<Plug>(ccc-select-color)", function()
    require("ccc.select").select("o")
  end)

  vim.api.nvim_create_user_command("CccConvert", function()
    require("ccc.convert").toggle()
  end, {})

  local highlighter = require("ccc.highlighter")
  highlighter:init()

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

  if opts.highlighter.auto_enable then
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("ccc-highlighter-auto-enable", {}),
      callback = function(ev)
        local ok, stat = pcall(vim.loop.fs_stat, ev.file)
        if ok and stat and stat.size > opts.highlighter.max_byte then
          return
        end
        highlighter:enable(ev.buf)
      end,
    })
  end

  return core
end

return {
  input = setmetatable({}, {
    __index = loader("input"),
  }),
  output = setmetatable({}, {
    __index = loader("output"),
  }),
  picker = setmetatable({}, {
    __index = loader("picker"),
  }),
  setup = setup,
  mapping = require("ccc.mapping"),
}
