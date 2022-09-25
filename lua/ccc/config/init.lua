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
        ["config.highlighter.filetypes"] = { M.config.highlighter.filetypes, "t" },
        ["config.highlighter.excludes"] = { M.config.highlighter.excludes, "t" },
        ["config.highlighter.events"] = { M.config.highlighter.events, "t" },
        ["config.convert"] = { M.config.convert, "t" },
        ["config.mappings"] = { M.config.mappings, "t" },
    })

    if M.config.highlighter.auto_enable then
        require("ccc.highlighter"):enable()
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
