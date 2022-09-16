## Selectable input/output mode

![ccc](https://user-images.githubusercontent.com/82267684/190639755-6b1f3ea3-35f9-461a-be37-2df30146a9bc.gif)

## Restore previously used colors

![prev](https://user-images.githubusercontent.com/82267684/190639758-a974b892-6266-480d-96d3-2348d84e6369.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Super powerful color picker plugin.

- Features
    - You can use RGB, HSL, CMYK, and other color space sliders for color adjustment.
    - Dynamic highlighting of sliders.
    - Restore previously used colors.
    - Selectable output formats.

# Setup

If you do not want to change the default setting, there is no need to call setup (Empty setup is done automatically by plugin/ccc.lua).
See `ccc-option` in [doc](./doc/ccc.txt) for the options that can be specified.

```lua
local ccc = require("ccc")
local mapping = ccc.mapping
ccc.setup({
    -- Your favorite settings
})
```

# Interface

This plugin provides one command and one mapping.

- `:CccPick`
	- Detects and replaces the color under the cursor.
	- Detectable formats are HEX (#000000), RGB (rgb(0,0,0)), and HSL (hsl(0,0%,0%)).
	- If nothing is detected, it is inserted at a new cursor position.

- `<Plug>(ccc-insert)`
    - Defined in insert mode.
    - Insert the color without detection.

# Action

All functions are implemented as lua functions.
To customize, use `ccc-option-mappings`.

```lua
local ccc = require("ccc")
local mapping = ccc.mapping
```

- complete
    - Default mapping: `<CR>`
	- Close the UI and perform a replace or insert.
	- If open the previous colors pallet, select the color under the cursor.
    - `mapping.complete()`

- quit
    - Default mapping: `q`
    - Cancel and close the UI without replace or insert. Don't use `:q`.
    - `mapping.quit()`

- toggle_input_mode
    - Default mapping: `i`
    - Toggle input mode. See `ccc-option-inputs` in [doc](./doc/ccc.txt).
    - `mapping.toggle_input_mode()`

- toggle_output_mode
    - Default mapping: `o`
    - Toggle output mode. See `ccc-option-outputs` in [doc](./doc/ccc.txt).
    - `mapping.toggle_output_mode()`

- toggle_prev_colors
    - Default mapping: `g`
    - Toggle show and hide the previous colors pallet.
    - `mapping.toggle_prev_colors()`
    - Use the following to move colors.
    - `goto_next`
    - `goto_prev`
    - `goto_tail`
    - `goto_head`

- goto_next
    - Default mapping: `w`
    - Go to next (right) color.
    - `mapping.goto_next()`

- goto_prev
    - Default mapping: `b`
    - Go to previous (left) color.
    - `mapping.goto_next()`

- goto_tail
    - Default mapping: `W`
    - Go to the last color.
    - `mapping.goto_next()`

- goto_head
    - Default mapping: `B`
    - Go to the first color.
    - `mapping.goto_next()`

- increase
    - Default mapping: `l` / `d` / `,` (1 / 5 / 10)
    - Increase the value times delta of the slider.
    - The delta is defined each color system, e.g. RGB is 1.
    - `mapping.increase1()`
    - `mapping.increase5()`
    - `mapping.increase10()`
    - `mapping.delta(intger)`

- decrease
    - Default mapping: `h` / `s` / `m` (1 / 5 / 10)
    - Decrease the value times delta of the slider.
    - The delta is defined each color system, e.g. RGB is 1.
    - `mapping.decrease1()`
    - `mapping.decrease5()`
    - `mapping.decrease10()`
    - `mapping.delta(intger)`

- set
    - Default mapping: `H` / `M` / `L` (0 / 50 / 100), `1` - `9` (10% - 90%)
    - Set the value of the slider as a percentage.
    - `mapping.set0()`
    - `mapping.set50()`
    - `mapping.set100()`
    - `ccc.set_percent(integer)`
