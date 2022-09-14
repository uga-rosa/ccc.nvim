![ccc](https://user-images.githubusercontent.com/82267684/190044933-ab2c52af-4cba-4222-8d1f-8519af2c38e4.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Supported formats are RGB, HSL, and color code.

# Usage

This plugin provides two commands.

- `:CccStart`
    - Detects and replaces the color under the cursor.
    - If nothing is detected, it is inserted at a new cursor position.

- `:CccInsert`
    - For insert mode command.
    - It is recommend to use `<Cmd>` mapping

# Default mappings

- `<CR>`: Complete, and perform a replace or insert.
- `q`: Cancel.
- `i`: Toggle input mode. They are `RGB` and `HSL`.
- `o`: Toggle output mode. They are `RGB`, `HSL`, and `ColorCode`.
- `h/l`: Decrease/increase by 1.
- `s/d`: Decrease/increase by 5.
- `m/,`: Decrease/increase by 10.
- `H/M/L`: Set to 0%/50%/100%.
- `0-9`: Set to 0% - 90%.

# Setup

The default settings are listed below.
If you do not want to change this, there is no need to call setup (Empty setup is done automatically by plugin/ccc.lua).

```lua
require("ccc").setup({
    default_input_mode = "RGB",
    default_output_mode = "ColorCode",
    win_opts = {
        relative = "cursor",
        row = 1,
        col = 1,
        style = "minimal",
        border = "rounded",
    },
    mappings = {
        ["q"] = mapping.quit,
        ["<CR>"] = mapping.complete,
        ["i"] = mapping.input_mode_toggle,
        ["o"] = mapping.output_mode_toggle,
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
    },
})
```
