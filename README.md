![ccc](https://user-images.githubusercontent.com/82267684/190083999-48d50982-6805-43db-9ed7-2fd5775c0285.gif)

![prev](https://user-images.githubusercontent.com/82267684/190240122-35a66537-9f07-41cf-aa49-ef5158358866.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

- Features
    - RGB and HSL sliders for color adjustment.
    - Dynamic highlighting of sliders.
    - Record and restore previously used colors.
    - 3 output formats (HEX, RGB, HSL).

# Usage

This plugin provides one command and one mapping.

- `:CccPick`
    - Detects and replaces the color under the cursor.
    - If nothing is detected, it is inserted at a cursor position.

- `<Plug>(ccc-insert)`
    - Defined in insert mode.
    - Insert the color without detection.

# Default mappings

- `<CR>`: Complete, and perform a replace or insert.
    - If the cursor is under the previous color, select it.
- `q`: Cancel.
- `i`: Toggle input mode. `RGB` -> `HSL` -> `RGB` -> ...
- `o`: Toggle output mode. `HEX` -> `RGB` -> `HSL` -> `HEX` -> ...
- `g`: Toggle previous colors.
    - `W/B` is useful for moving colors; it is also mapped to `w/b`.
- `h/l`: Decrease/increase by 1.
- `s/d`: Decrease/increase by 5.
- `m/,`: Decrease/increase by 10.
- `H/M/L`: Set to 0%/50%/100%.
- `0-9`: Set to 0% - 90%.

# Setup

The default settings are listed below.
If you do not want to change this, there is no need to call setup (Empty setup is done automatically by plugin/ccc.lua).

```lua
local ccc = require("ccc")
local mapping = ccc.mapping

ccc.setup({
    default_input_mode = "RGB",
    default_output_mode = "HEX",
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
    default_color = "#000000",
    preserve = false,
    save_on_quit = false,
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
})
```
