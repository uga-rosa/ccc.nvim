# ccc.nvim

**C**reate **C**olor **C**ode in neovim.

Use the colorful sliders, easy, to create any color you want!

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

See [doc](./doc/ccc.txt) for details.

# GIF 

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
