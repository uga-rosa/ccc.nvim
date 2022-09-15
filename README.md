![ccc](https://user-images.githubusercontent.com/82267684/190083999-48d50982-6805-43db-9ed7-2fd5775c0285.gif)

![prev](https://user-images.githubusercontent.com/82267684/190240122-35a66537-9f07-41cf-aa49-ef5158358866.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

- Features
    - RGB and HSL sliders for color adjustment.
    - Dynamic highlighting of sliders.
    - Record and restore previously used colors.
    - 3 output formats (HEX, RGB, HSL).

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

- `<CR>`: Close the UI and perform a replace or insert.
    - If the cursor is under the previous color, select it.
- `q`: Cancel and close the UI without replace or insert.
- `i`: Toggle input mode.
    - `RGB` -> `HSL` -> `RGB` -> ...
- `o`: Toggle output mode.
    - `HEX` -> `RGB` -> `HSL` -> `HEX` -> ...
- `g`: Toggle show and hide the previous colors pallet.
    - `W/B` are useful for moving colors; they are also mapped to `w/b`.
- `h/s/m`: Decrease the value of the slider by 1/5/10.
- `l/d/,`: Increase the value of the slider by 1/5/10.
- `H/M/L`: Set the value of the slider to 0%/50%/100%.
- `0-9`: Set to 0% - 90%.
