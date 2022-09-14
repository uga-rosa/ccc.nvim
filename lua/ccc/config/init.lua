local M = {
    config = {},
}

function M.setup(opt)
    local default = require("ccc.config.default")
    if opt.disable_default_mappings then
        default.mappings = {}
    end
    M.config = vim.tbl_deep_extend("force", M.config, default, opt)

    local i_mode = M.config.default_input_mode
    local o_mode = M.config.default_output_mode
    vim.validate({
        ["config.default_input_mode"] = { i_mode, "s" },
        ["config.default_output_mode"] = { o_mode, "s" },
        ["config.win_opts"] = { M.config.win_opts, "t" },
    })
    assert(vim.tbl_contains({ "RGB", "HSL" }, i_mode), "Invalid input mode: " .. i_mode)
    assert(vim.tbl_contains({ "RGB", "HSL", "HEX" }, o_mode), "Invalid output mode: " .. o_mode)
end

---@param name string
---@return any
function M.get(name)
    return M.config[name] or error("Invalid option name: " .. name)
end

return M
