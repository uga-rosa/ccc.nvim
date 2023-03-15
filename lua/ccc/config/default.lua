local ccc = require("ccc")
local mapping = ccc.mapping
local input = ccc.input
local output = ccc.output
local picker = ccc.picker

---@alias hl_mode "fg" | "foreground" | "bg" | "background"
---@alias show_mode "auto" | "show" | "hide"

return {
  ---@type string hex
  default_color = "#000000",
  ---@type string
  bar_char = "█",
  ---@type string
  point_char = "◊",
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
  ---@type show_mode
  alpha_show = "auto",
  ---@type ColorInput[]
  inputs = {
    input.rgb,
    input.hsl,
    input.cmyk,
  },
  ---@type ColorOutput[]
  outputs = {
    output.hex,
    output.hex_short,
    output.css_rgb,
    output.css_hsl,
  },
  ---@type ColorPicker[]
  pickers = {
    picker.hex,
    picker.css_rgb,
    picker.css_hsl,
    picker.css_hwb,
    picker.css_lab,
    picker.css_lch,
    picker.css_oklab,
    picker.css_oklch,
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
    max_byte = 100 * 1024, -- 100 KB
    ---@type string[]
    filetypes = {},
    ---@type string[]
    excludes = {},
    ---@type boolean
    lsp = true,
  },
    -- stylua: ignore
    ---@type {[1]: ColorPicker, [2]: ColorOutput}[]
    convert = {
        { picker.hex,     output.css_rgb },
        { picker.css_rgb, output.css_hsl },
        { picker.css_hsl, output.hex     },
    },
  recognize = {
    input = false,
    output = false,
        -- stylua: ignore
        ---@alias RecognizePattern table<ColorPicker, {[1]: ColorInput, [2]: ColorOutput}>
        ---@type RecognizePattern
        pattern = {
            [picker.css_rgb]   = { input.rgb,   output.rgb       },
            [picker.css_name]  = { input.rgb,   output.rgb       },
            [picker.hex]       = { input.rgb,   output.hex       },
            [picker.css_hsl]   = { input.hsl,   output.css_hsl   },
            [picker.css_hwb]   = { input.hwb,   output.css_hwb   },
            [picker.css_lab]   = { input.lab,   output.css_lab   },
            [picker.css_lch]   = { input.lch,   output.css_lch   },
            [picker.css_oklab] = { input.oklab, output.css_oklab },
            [picker.css_oklch] = { input.oklch, output.css_oklch },
        },
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
