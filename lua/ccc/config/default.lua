local ccc = require("ccc")
local mapping = ccc.mapping

---@alias hl_mode "fg" | "foreground" | "bg" | "background"

return {
    ---@type string hex
    default_color = "#000000",
    ---@type string
    bar_char = "■",
    ---@type string
    point_char = "◇",
    ---@type string hex
    point_color = "",
    ---@type integer
    bar_len = 30,
    ---@type table
    win_opts = {
        relative = "cursor",
        row = 1,
        col = 1,
        style = "minimal",
        border = "rounded",
    },
    ---@type boolean
    auto_close = true,
    ---@type boolean
    preserve = false,
    ---@type boolean
    save_on_quit = false,
    ---@type ColorInput[]
    inputs = {
        ccc.input.rgb,
        ccc.input.hsl,
        ccc.input.cmyk,
    },
    ---@type ColorOutput[]
    outputs = {
        ccc.output.hex,
        ccc.output.hex_short,
        ccc.output.css_rgb,
        ccc.output.css_hsl,
    },
    ---@type ColorPicker[]
    pickers = {
        ccc.picker.hex,
        ccc.picker.css_rgb,
        ccc.picker.css_hsl,
    },
    ---@type table<string, string[] | string | nil>
    exclude_pattern = {
        hex = {
            "[%w_]{{pattern}}",
        },
        css_rgb = nil,
        css_hsl = nil,
        css_name = {
            "[%w_]{{pattern}}",
            "{{pattern}}[%w_]",
        },
    },
    ---@type hl_mode
    highlight_mode = "bg",
    ---@type function
    output_line = ccc.output_line,
    ---@type table
    highlighter = {
        ---@type boolean
        auto_enable = false,
        ---@type integer
        max_byte = 50 * 1000 * 1000, -- 50 MB
        ---@type string[]
        filetypes = {},
        ---@type string[]
        excludes = {},
        ---@type boolean
        lsp = true,
    },
    ---@type {[1]: ColorPicker, [2]: ColorOutput}[]
    convert = {
        { ccc.picker.hex, ccc.output.css_rgb },
        { ccc.picker.css_rgb, ccc.output.css_hsl },
        { ccc.picker.css_hsl, ccc.output.hex },
    },
    ---@type table<string, function>
    mappings = {
        ["q"] = mapping.quit,
        ["<CR>"] = mapping.complete,
        ["i"] = mapping.toggle_input_mode,
        ["o"] = mapping.toggle_output_mode,
        ["a"] = mapping.toggle_alpha,
        ["g"] = mapping.toggle_prev_colors,
        ["w"] = mapping.goto_next,
        ["b"] = mapping.goto_prev,
        ["W"] = mapping.goto_tail,
        ["B"] = mapping.goto_head,
        ["l"] = mapping.increase1,
        ["d"] = mapping.increase5,
        [","] = mapping.increase10,
        ["h"] = mapping.decrease1,
        ["s"] = mapping.decrease5,
        ["m"] = mapping.decrease10,
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
    },
}
