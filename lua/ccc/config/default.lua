local ccc = require("ccc")
local input = ccc.input
local output = ccc.output
local picker = ccc.picker
local mapping = ccc.mapping
local utils = require("ccc.utils")

---@type ccc.Options
return {
  default_color = "#000000",
  bar_char = "█",
  point_char = "◊",
  point_color = "",
  empty_point_bg = true,
  point_color_on_dark = "#ffffff",
  point_color_on_light = "#000000",
  bar_len = 30,
  win_opts = {
    relative = "cursor",
    row = 1,
    col = 1,
    style = "minimal",
    border = "rounded",
  },
  auto_close = true,
  preserve = false,
  save_on_quit = false,
  max_prev_colors = 10,
  alpha_show = "auto",
  inputs = {
    input.rgb,
    input.hsl,
    input.cmyk,
  },
  outputs = {
    output.hex,
    output.hex_short,
    output.css_rgb,
    output.css_hsl,
  },
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
  ui = require("ccc.ui.float"),
  output_line = function(before_color, after_color, width)
    local b_hex = before_color:hex()
    local a_str = after_color:str()
    local line = b_hex .. " =>" .. (" "):rep(width - #b_hex - 3 - #a_str) .. a_str
    -- Range for highlight
    local b_start_col = 0
    local b_end_col = #b_hex
    local a_start_col = width - #a_str
    local a_end_col = width
    return line, b_start_col, b_end_col, a_start_col, a_end_col
  end,
  highlight_mode = "bg",
  virtual_symbol = " ● ",
  virtual_pos = "inline-left",
  lsp = true,
  highlighter = {
    auto_enable = false,
    max_byte = 100 * 1024, -- 100 KB
    filetypes = {},
    excludes = {},
    lsp = true,
    picker = true,
    update_insert = true,
  },
  -- stylua: ignore
  convert = {
      { picker.hex,     output.css_rgb },
      { picker.css_rgb, output.css_hsl },
      { picker.css_hsl, output.hex     },
  },
  recognize = {
    input = false,
    output = false,
    -- stylua: ignore
    pattern = {
        [picker.css_rgb]   = { input.rgb,   output.css_rgb   },
        [picker.css_name]  = { input.rgb,   output.css_rgb   },
        [picker.hex]       = { input.rgb,   output.hex       },
        [picker.hex_long]  = { input.rgb,   output.hex       },
        [picker.hex_short] = { input.rgb,   output.hex_short },
        [picker.css_hsl]   = { input.hsl,   output.css_hsl   },
        [picker.css_hwb]   = { input.hwb,   output.css_hwb   },
        [picker.css_lab]   = { input.lab,   output.css_lab   },
        [picker.css_lch]   = { input.lch,   output.css_lch   },
        [picker.css_oklab] = { input.oklab, output.css_oklab },
        [picker.css_oklch] = { input.oklch, output.css_oklch },
    },
  },
  mappings = {
    ["<CR>"] = mapping.complete,
    ["q"] = mapping.quit,
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
    ["1"] = utils.bind(mapping._set_percent, 10),
    ["2"] = utils.bind(mapping._set_percent, 20),
    ["3"] = utils.bind(mapping._set_percent, 30),
    ["4"] = utils.bind(mapping._set_percent, 40),
    ["5"] = mapping.set50,
    ["6"] = utils.bind(mapping._set_percent, 60),
    ["7"] = utils.bind(mapping._set_percent, 70),
    ["8"] = utils.bind(mapping._set_percent, 80),
    ["9"] = utils.bind(mapping._set_percent, 90),
    ["r"] = mapping.reset_mode,
    ["a"] = mapping.toggle_alpha,
    ["g"] = mapping.toggle_prev_colors,
    ["b"] = mapping.goto_prev,
    ["w"] = mapping.goto_next,
    ["B"] = mapping.goto_head,
    ["W"] = mapping.goto_tail,
    ["i"] = mapping.cycle_input_mode,
    ["o"] = mapping.cycle_output_mode,
    ["<LeftMouse>"] = mapping.click,
    ["<ScrollWheelDown>"] = mapping.decrease1,
    ["<ScrollWheelUp>"] = mapping.increase1,
  },
  disable_default_mappings = false,
}
