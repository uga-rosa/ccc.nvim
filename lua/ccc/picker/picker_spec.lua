local hex = require("ccc.picker.hex")
local css_rgb = require("ccc.picker.css_rgb")
local css_hsl = require("ccc.picker.css_hsl")
local css_hwb = require("ccc.picker.css_hwb")
local css_oklab = require("ccc.picker.css_oklab")
local css_name = require("ccc.picker.css_name")

---@param module ColorPicker
---@param str string
---@param expect_rgb integer[] #range in [0-255]
---@param expect_alpha Alpha
local function test(module, str, expect_rgb, expect_alpha)
    local start, end_, rgb, alpha = module:parse_color(str)
    assert.equals(2, start)
    assert.equals(#str - 1, end_)
    ---@cast rgb RGB
    for i = 1, 3 do
        local diff = rgb[i] - expect_rgb[i] / 255
        assert.is_true(diff < 1 / 255, diff)
    end
    if expect_alpha == nil then
        assert.is_nil(alpha)
    else
        assert.equals(expect_alpha, alpha)
    end
end

describe("Color detection test", function()
    before_each(function()
        require("ccc").setup({})
    end)

    describe("hex", function()
        it("6 digits", function()
            test(hex, " #ffff00 ", { 255, 255, 0 }, nil)
        end)
        it("8 digits (with alpha)", function()
            test(hex, " #ffff0000 ", { 255, 255, 0 }, 0)
        end)
        it("3 digits", function()
            test(hex, " #ff0 ", { 255, 255, 0 }, nil)
        end)
        it("4 digits (with alpha)", function()
            test(hex, " #ff00 ", { 255, 255, 0 }, 0)
        end)
    end)
end)
