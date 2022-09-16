local M = {
    config = {},
}

function M.setup(opt)
    local default = require("ccc.config.default")
    if opt.disable_default_mappings then
        default.mappings = {}
    end
    M.config = vim.tbl_deep_extend("force", M.config, default, opt)

    vim.validate({
        ["config.default_color"] = { M.config.default_color, "s" },
        ["config.bar_char"] = { M.config.bar_char, "s" },
        ["config.point_char"] = { M.config.point_char, "s" },
        ["config.bar_len"] = { M.config.bar_len, "n" },
        ["config.win_opts"] = { M.config.win_opts, "t" },
        ["config.preserve"] = { M.config.preserve, "b" },
        ["config.save_on_quit"] = { M.config.save_on_quit, "b" },
        ["config.inputs"] = { M.config.inputs, "t" },
        ["config.outputs"] = { M.config.outputs, "t" },
        ["config.pickers"] = { M.config.pickers, "t" },
        ["config.mappings"] = { M.config.mappings, "t" },
    })
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
