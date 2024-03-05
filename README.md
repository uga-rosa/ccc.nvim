# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Use the colorful sliders to easily generate any desired color!

- Features
    - No dependency.
    - Dynamic highlighting of sliders.
    - Supports more than 10 color spaces (RGB, HSL, CMYK, etc.).
    - Seamless input/output mode change.
    - Restore previously used colors.
    - Transparent slider for css functions (e.g. `rgb()`, `hsl()`)
    - Color Highlighter for many formats.
    - Programmable modules (input/output/picker)

- Requirements
    - neovim 0.9.0+

See [doc](./doc/ccc.txt) for details.

# GIF

## Seamless mode change

![cccpick](https://user-images.githubusercontent.com/82267684/225461164-a36d4ad3-da49-4124-b957-e0749f14fa05.gif)

## Restore previously used colors

![restore](https://user-images.githubusercontent.com/82267684/225461172-4c3e17af-99b6-4da9-8216-c00dc20c7a40.gif)

## Highlight pickable colors

- LSP `textDocument/documentColor` is supported (Requires neovim built-in LSP client).

![image](https://user-images.githubusercontent.com/430272/192379267-7b069281-021a-4ee5-bc65-58def20f9c0d.png)

- Many color formats conforming to CSS Color Module level4 can be highlighted without LSP.

![image](https://user-images.githubusercontent.com/82267684/196505445-fac76002-7344-47f7-84cb-710c3ecbb717.png)

There are some special picker to highlight. Descriptions are in the doc.
If you would like to see images, please visit the [wiki](https://github.com/uga-rosa/ccc.nvim/wiki/Special-pickers).

## Use multiple color spaces simultaneously

- Advanced settings
- See [wiki](https://github.com/uga-rosa/ccc.nvim/wiki/Use-multiple-color-spaces-simultaneously)

![multi](https://user-images.githubusercontent.com/82267684/225504962-bf71730e-e681-4ee3-8a26-f949b1973e71.gif)
