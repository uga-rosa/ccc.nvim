local api = vim.api

local M = {
    config = {},
}

function M.setup(opt)
    local default = require("ccc.config.default")
    if opt.disable_default_mappings then
        default.mappings = {}
    else
        for lhs, rhs in pairs(opt.mappings or {}) do
            if rhs == "<Plug>(ccc-none)" then
                opt.mappings[lhs] = nil
                default.mappings[lhs] = nil
            end
        end
    end
    M.config = vim.tbl_deep_extend("force", M.config, default, opt)

    vim.validate({
        ["config.default_color"] = { M.config.default_color, "s" },
        ["config.bar_char"] = { M.config.bar_char, "s" },
        ["config.point_char"] = { M.config.point_char, "s" },
        ["config.point_color"] = { M.config.point_color, "s" },
        ["config.bar_len"] = { M.config.bar_len, "n" },
        ["config.win_opts"] = { M.config.win_opts, "t" },
        ["config.auto_close"] = { M.config.auto_close, "b" },
        ["config.preserve"] = { M.config.preserve, "b" },
        ["config.save_on_quit"] = { M.config.save_on_quit, "b" },
        ["config.inputs"] = { M.config.inputs, "t" },
        ["config.outputs"] = { M.config.outputs, "t" },
        ["config.pickers"] = { M.config.pickers, "t" },
        ["config.exclude_pattern"] = { M.config.exclude_pattern, "t" },
        ["config.highlight_mode"] = { M.config.highlight_mode, "s" },
        ["config.output_line"] = { M.config.output_line, "f" },
        ["config.highlighter"] = { M.config.highlighter, "t" },
        ["config.highlighter.auto_enable"] = { M.config.highlighter.auto_enable, "b" },
        ["config.highlighter.max_byte"] = { M.config.highlighter.max_byte, "n" },
        ["config.highlighter.filetypes"] = { M.config.highlighter.filetypes, "t" },
        ["config.highlighter.excludes"] = { M.config.highlighter.excludes, "t" },
        ["config.highlighter.lsp"] = { M.config.highlighter.lsp, "b" },
        ["config.convert"] = { M.config.convert, "t" },
        ["config.mappings"] = { M.config.mappings, "t" },
    })

    if M.config.highlighter.auto_enable then
        vim.schedule(function()
            local aug_name = "ccc-highlighter-auto-enable"
            api.nvim_create_augroup(aug_name, {})
            api.nvim_create_autocmd("BufEnter", {
                pattern = "*",
                group = aug_name,
                callback = function()
                    local bytes = vim.fn.wordcount().bytes
                    local max_byte = M.config.highlighter.max_byte
                    if bytes > max_byte then
                        return
                    end
                    require("ccc.highlighter"):enable()
                end,
            })
        end)
    end
end

---@param name string
---@return unknown
function M.get(name)
    local result = M.config[name]
    if result == nil then
        error("Invalid option name: " .. name)
    end
    return M.config[name]
end

return M
