## Selectable input/output mode

![toggle](https://user-images.githubusercontent.com/82267684/190847776-81763c84-2662-4693-97df-b15e8d9115ec.gif)

## Restore previously used colors

![prev](https://user-images.githubusercontent.com/82267684/190847777-e1f434f9-a8f9-4cb9-b496-cbd849e71a9c.gif)

## Colorizer

- LSP `textDocument/documentColor` is supported (Requires neovim built-in LSP client).

![image](https://user-images.githubusercontent.com/430272/192379267-7b069281-021a-4ee5-bc65-58def20f9c0d.png)

- Many color formats conforming to CSS Color Module level4 can be highlighted without LSP.

![image](https://user-images.githubusercontent.com/82267684/196505445-fac76002-7344-47f7-84cb-710c3ecbb717.png)

## Use multiple color spaces simultaneously

- Advanced settings
- See wiki

![multi](https://user-images.githubusercontent.com/82267684/190847778-751e7656-985b-47e7-890f-91339ee354e9.gif)

# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Super powerful color picker plugin.

- Features

  - No dependency.
  - RGB, HSL, CMYK, and other color space sliders for color creation.
  - Dynamic highlighting of sliders.
  - Restore previously used colors.
  - Selectable output formats.
  - Transparent slider for css functions (e.g. `rgb()`, `hsl()`)
  - Fast colorizer.

- Requirements
  - neovim 0.8+

# Setup

If you do not change the default setting, there is no need to call `setup`.
See `ccc-option` in [doc](./doc/ccc.txt) for the options that can be used.
You can see the default options [here](./lua/ccc/config/default.lua).

```lua
-- Enable true color
vim.opt.termguicolors = true

local ccc = require("ccc")
local mapping = ccc.mapping

ccc.setup({
	-- Your favorite settings

	-- Example: Set auto_enable to true for the highlighter
	highlighter = {

		auto_enable = true,
	},
})
```

# Interface

This plugin provides five commands and one mapping.

- `:CccPick`

  - Detects and replaces the color under the cursor.
    - Detectable formats are defined in `ccc-option-pickers` (See [doc](./doc/ccc.txt)).
    - If nothing is detected, the color is inserted at a cursor position.

- `<Plug>(ccc-insert)`

  - Defined in insert mode.
  - Insert the color without detection.

- `:CccConvert`

  - Convert color formats directly without opening the UI.
  - The conversion rules are defined in `ccc-option-convert`.

- `:CccHighlighterToggle`
- `:CccHighlighterEnable`
- `:CccHighlighterDisable`
  - Highlight colors in the buffer.
    - The colors to be highlighted are those returned by textDocument/documentColor request or those registered in `ccc-option-pickers`.
  - Highlight is managed on a buffer-by-buffer basis, so you must use this command each time to enable highlight on a new buffer.
    - You can use `ccc-option-highlighter-auto-enable` to enable automatically on `BufEnter`.
  - The following options are available.
    - `ccc-option-highlighter-auto-enable`
    - `ccc-option-highlighter-filetypes`
    - `ccc-option-highlighter-excludes`
    - `ccc-option-highlighter-lsp`

# Action

All actions have been implemented as lua functions.
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
  - Alias of `:quit`.
  - Cancel and close the UI without replace or insert.
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
  - `ccc.delta(integer)`

- decrease

  - Default mapping: `h` / `s` / `m` (1 / 5 / 10)
  - Decrease the value times delta of the slider.
  - The delta is defined each color system, e.g. RGB is 1.
  - `mapping.decrease1()`
  - `mapping.decrease5()`
  - `mapping.decrease10()`
  - `ccc.delta(integer)`

- set
  - Default mapping: `H` / `M` / `L` (0 / 50 / 100), `1` - `9` (10% - 90%)
  - Set the value of the slider as a percentage.
  - `mapping.set0()`
  - `mapping.set50()`
  - `mapping.set100()`
  - `ccc.set_percent(integer)`

# Similar plugins

See [awesome-neovim#color](https://github.com/rockerBOO/awesome-neovim#color).
