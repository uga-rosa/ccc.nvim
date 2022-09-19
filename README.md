## Selectable input/output mode

![toggle](https://user-images.githubusercontent.com/82267684/190847776-81763c84-2662-4693-97df-b15e8d9115ec.gif)

## Restore previously used colors

![prev](https://user-images.githubusercontent.com/82267684/190847777-e1f434f9-a8f9-4cb9-b496-cbd849e71a9c.gif)

## Highlight colors that can be picked up by ccc.nvim

![image](https://user-images.githubusercontent.com/82267684/190941438-9dba6f6a-fc87-4d47-8106-bfc865913b97.png)

## Use multiple color spaces simultaneously

- Advanced settings
- See wiki

![multi](https://user-images.githubusercontent.com/82267684/190847778-751e7656-985b-47e7-890f-91339ee354e9.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Super powerful color picker plugin.

- Features
    - RGB, HSL, CMYK, and other color space sliders for color adjustment.
    - Dynamic highlighting of sliders.
    - Restore previously used colors.
    - Selectable output formats.
    - Transparent slider (for css `rgb()`/`hsl()`)
    - Highlight colors that can be picked up for current buffer.

**If you use release version (0.7.2), use branch** `0.7.2`

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
    - Detectable formats are defined in `ccc-option-pickers` (See [doc](./doc/ccc.txt)).
    - If nothing is detected, the color is inserted at a cursor position.

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

- toggle_alpha
    - Default mapping: `a`
	- Toggle show/hide alpha (transparency) slider.
	- Transparency is used only when output mode is `css_rgb` or `css_hsl`.
    - `mapping.toggle_alpha()`

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
    - `mapping.delta(integer)`

- decrease
    - Default mapping: `h` / `s` / `m` (1 / 5 / 10)
    - Decrease the value times delta of the slider.
    - The delta is defined each color system, e.g. RGB is 1.
    - `mapping.decrease1()`
    - `mapping.decrease5()`
    - `mapping.decrease10()`
    - `mapping.delta(integer)`

- set
    - Default mapping: `H` / `M` / `L` (0 / 50 / 100), `1` - `9` (10% - 90%)
    - Set the value of the slider as a percentage.
    - `mapping.set0()`
    - `mapping.set50()`
    - `mapping.set100()`
    - `ccc.set_percent(integer)`
