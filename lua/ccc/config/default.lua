local ccc = require("ccc")
local mapping = ccc.mapping

return {
    default_input_mode = "RGB",
    default_output_mode = "HEX",
    default_color = "#000000",
    bar_char = "■",
    point_char = "◇",
    bar_len = 30,
    win_opts = {
        relative = "cursor",
        row = 1,
        col = 1,
        style = "minimal",
        border = "rounded",
    },
    preserve = false,
    save_on_quit = false,
    inputs = {
        require("ccc.input.rgb"):new(),
        require("ccc.input.hsl"):new(),
    },
    outputs = {
        require("ccc.output.hex"),
        require("ccc.output.css_rgb"),
        require("ccc.output.css_hsl"),
    },
    pickers = {
        require("ccc.picker.hex"),
        require("ccc.picker.css_rgb"),
        require("ccc.picker.css_hsl"),
    },
    hex_format = "#%02x%02x%02x",
    rgb_format = "rgb(%d,%d,%d)",
    hsl_format = "hsl(%d,%d%%,%d%%)",
    mappings = {
        ["q"] = mapping.quit,
        ["<CR>"] = mapping.complete,
        ["i"] = mapping.toggle_input_mode,
        ["o"] = mapping.toggle_output_mode,
        ["g"] = mapping.toggle_prev_colors,
        ["h"] = mapping.decrease1,
        ["l"] = mapping.increase1,
        ["s"] = mapping.decrease5,
        ["d"] = mapping.increase5,
        ["m"] = mapping.decrease10,
        [","] = mapping.increase10,
        ["H"] = mapping.set0,
        ["M"] = mapping.set50,
        ["L"] = mapping.set100,
        ["0"] = mapping.set0,
        ["1"] = function()
            ccc.set_percent(10)
        end,
        ["2"] = function()
            ccc.set_percent(20)
        end,
        ["3"] = function()
            ccc.set_percent(30)
        end,
        ["4"] = function()
            ccc.set_percent(40)
        end,
        ["5"] = mapping.set50,
        ["6"] = function()
            ccc.set_percent(60)
        end,
        ["7"] = function()
            ccc.set_percent(70)
        end,
        ["8"] = function()
            ccc.set_percent(80)
        end,
        ["9"] = function()
            ccc.set_percent(90)
        end,
        ["w"] = "W",
        ["b"] = "B",
    },
}
