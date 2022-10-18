local highlighter = require("ccc.highlighter")
local utils = require("ccc.utils")

local LspPicker = {}

---@return integer? start
---@return integer? end_
---@return RGB?
---@return Alpha?
function LspPicker.pick()
    local ls_colors = highlighter:get_ls_color()
    if ls_colors == nil then
        return
    end

    local row, col = unpack(utils.cursor())
    for _, ls_color in ipairs(ls_colors) do
        if ls_color.row == row and ls_color.start <= col and col <= ls_color.end_ then
            return ls_color.start, ls_color.end_, ls_color.rgb, ls_color.alpha
        end
    end
end

return LspPicker
