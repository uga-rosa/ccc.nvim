local utils = require("ccc.utils.test")
local hex = require("ccc.picker.hex")
local css_rgb = require("ccc.picker.css_rgb")
local css_hsl = require("ccc.picker.css_hsl")
local css_hwb = require("ccc.picker.css_hwb")
local css_lab = require("ccc.picker.css_lab")
local css_lch = require("ccc.picker.css_lch")
local css_oklab = require("ccc.picker.css_oklab")
local css_oklch = require("ccc.picker.css_oklch")
local css_name = require("ccc.picker.css_name")
local custom_entries = require("ccc.picker.custom_entries")
local trailing_whitespace = require("ccc.picker.trailing_whitespace")
local ansi_escape = require("ccc.picker.ansi_escape")

---@param a number[]
---@return number[]
local function div255(a)
  return vim.tbl_map(function(x)
    return x / 255
  end, a)
end

---@param module ccc.ColorPicker
---@param str string
---@param expect_rgb integer[]? #range in [0-255]. If nil, expect parsing fail.
---@param expect_alpha Alpha?
local function test_rgb(module, str, expect_rgb, expect_alpha)
  local start, end_, rgb, alpha = module:parse_color(str)
  if expect_rgb == nil then
    assert.is_nil(start)
    assert.is_nil(end_)
    assert.is_nil(rgb)
    assert.is_nil(alpha)
  else
    assert(start and end_ and rgb, "Can't parse color")
    assert.equals(2, start)
    assert.equals(#str - 1, end_)
    expect_rgb = div255(expect_rgb)
    local msg = ("expected {%s}, but passed in {%s}"):format(table.concat(expect_rgb, ", "), table.concat(rgb, ", "))
    ---@cast rgb RGB
    for i = 1, 3 do
      assert.is_true(utils.near(expect_rgb[i], rgb[i], 1 / 255), msg)
    end
    assert.equals(expect_alpha, alpha)
  end
end

describe("Color detection test", function()
  it("none", function()
    test_rgb(css_rgb, " rgb(255 none 255) ", { 255, 0, 255 }, nil)
  end)

  describe("hex", function()
    it("6 digits", function()
      test_rgb(hex, " #ffff00 ", { 255, 255, 0 }, nil)
    end)
    it("8 digits (with alpha)", function()
      test_rgb(hex, " #ffff0000 ", { 255, 255, 0 }, 0)
    end)
    it("3 digits", function()
      test_rgb(hex, " #ff0 ", { 255, 255, 0 }, nil)
    end)
    it("4 digits (with alpha)", function()
      test_rgb(hex, " #ff00 ", { 255, 255, 0 }, 0)
    end)
    it("word boundary", function()
      test_rgb(hex, " dein#add ", nil, nil)
    end)
  end)

  describe("The RGB functions: rgb() and rgba()", function()
    it("Modern, rgb()", function()
      test_rgb(css_rgb, " rgb(255 0 255) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgb(255 0 255 / 0.8) ", { 255, 0, 255 }, 0.8)
      test_rgb(css_rgb, " rgb(100% 0% 100%) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgb(100% 0% 100% / 80%) ", { 255, 0, 255 }, 0.8)
    end)
    it("Modern, rgba()", function()
      test_rgb(css_rgb, " rgba(255 0 255) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgba(255 0 255 / 0.8) ", { 255, 0, 255 }, 0.8)
      test_rgb(css_rgb, " rgba(100% 0% 100%) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgba(100% 0% 100% / 80%) ", { 255, 0, 255 }, 0.8)
    end)
    it("Legacy, rgb()", function()
      test_rgb(css_rgb, " rgb(255, 0, 255) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgb(255, 0, 255, 0.8) ", { 255, 0, 255 }, 0.8)
      test_rgb(css_rgb, " rgb(100%, 0%, 100%) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgb(100%, 0%, 100%, 80%) ", { 255, 0, 255 }, 0.8)
    end)
    it("Legacy, rgba()", function()
      test_rgb(css_rgb, " rgba(255, 0, 255) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgba(255, 0, 255, 0.8) ", { 255, 0, 255 }, 0.8)
      test_rgb(css_rgb, " rgba(100%, 0%, 100%) ", { 255, 0, 255 }, nil)
      test_rgb(css_rgb, " rgba(100%, 0%, 100%, 80%) ", { 255, 0, 255 }, 0.8)
    end)
  end)

  describe("HSL Colors: hsl() and hsla() functions", function()
    it("Modern, hsl()", function()
      test_rgb(css_hsl, " hsl(180 50% 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsl(180deg 50% 50% / 80%) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsl(200grad 50% 50% / 0.8) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsl(3.14rad 50% 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsl(0.5turn 50% 50%) ", { 63, 191, 191 }, nil)
    end)
    it("Modern, hsla()", function()
      test_rgb(css_hsl, " hsla(180 50% 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsla(180deg 50% 50% / 80%) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsla(200grad 50% 50% / 0.8) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsla(3.14rad 50% 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsla(0.5turn 50% 50%) ", { 63, 191, 191 }, nil)
    end)
    it("Legacy, hsl()", function()
      test_rgb(css_hsl, " hsl(180, 50%, 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsl(180deg, 50%, 50%, 80%) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsl(200grad, 50%, 50%, 0.8) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsl(3.14rad, 50%, 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsl(0.5turn, 50%, 50%) ", { 63, 191, 191 }, nil)
    end)
    it("Legacy, hsla()", function()
      test_rgb(css_hsl, " hsla(180, 50%, 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsla(180deg, 50%, 50%, 80%) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsla(200grad, 50%, 50%, 0.8) ", { 63, 191, 191 }, 0.8)
      test_rgb(css_hsl, " hsla(3.14rad, 50%, 50%) ", { 63, 191, 191 }, nil)
      test_rgb(css_hsl, " hsla(0.5turn, 50%, 50%) ", { 63, 191, 191 }, nil)
    end)
  end)

  describe("HWB Colors: hwb() function", function()
    it("hwb() without alpha", function()
      test_rgb(css_hwb, " hwb(180 30% 30%) ", { 77, 179, 179 }, nil)
      test_rgb(css_hwb, " hwb(180deg 30% 30%) ", { 77, 179, 179 }, nil)
      test_rgb(css_hwb, " hwb(200grad 30% 30%) ", { 77, 179, 179 }, nil)
      test_rgb(css_hwb, " hwb(3.14rad 30% 30%) ", { 77, 179, 179 }, nil)
      test_rgb(css_hwb, " hwb(0.5turn 30% 30%) ", { 77, 179, 179 }, nil)
    end)
    it("hwb() with alpha", function()
      test_rgb(css_hwb, " hwb(180 30% 30% / 0.8) ", { 77, 179, 179 }, 0.8)
      test_rgb(css_hwb, " hwb(180deg 30% 30% / 0.8) ", { 77, 179, 179 }, 0.8)
      test_rgb(css_hwb, " hwb(200grad 30% 30% / 0.8) ", { 77, 179, 179 }, 0.8)
      test_rgb(css_hwb, " hwb(3.14rad 30% 30% / 80%) ", { 77, 179, 179 }, 0.8)
      test_rgb(css_hwb, " hwb(0.5turn 30% 30% / 80%) ", { 77, 179, 179 }, 0.8)
    end)
  end)

  describe("Lab Color: lab() function", function()
    it("lab() without alpha", function()
      test_rgb(css_lab, " lab(60% 40% -20%) ", { 209, 109, 190 }, nil)
      test_rgb(css_lab, " lab(60 50 -25) ", { 209, 109, 190 }, nil)
    end)
    it("lab() with alpha", function()
      test_rgb(css_lab, " lab(60% 40% -20% / 80%) ", { 209, 109, 190 }, 0.8)
      test_rgb(css_lab, " lab(60 50 -25 / 0.8) ", { 209, 109, 190 }, 0.8)
    end)
  end)

  describe("LCH Color: lch() function", function()
    it("lch() without alpha", function()
      test_rgb(css_lch, " lch(60% 20% 270) ", { 108, 147, 197 }, nil)
      test_rgb(css_lch, " lch(60 30 270deg) ", { 108, 147, 197 }, nil)
      test_rgb(css_lch, " lch(60 30 300grad) ", { 108, 147, 197 }, nil)
      test_rgb(css_lch, " lch(60 30 4.71rad) ", { 108, 147, 197 }, nil)
      test_rgb(css_lch, " lch(60 30 0.75turn) ", { 108, 147, 197 }, nil)
    end)
    it("lch() with alpha", function()
      test_rgb(css_lch, " lch(60% 20% 270 / 80%) ", { 108, 147, 197 }, 0.8)
      test_rgb(css_lch, " lch(60 30 270deg / 0.8) ", { 108, 147, 197 }, 0.8)
      test_rgb(css_lch, " lch(60 30 300grad / 0.8) ", { 108, 147, 197 }, 0.8)
      test_rgb(css_lch, " lch(60 30 4.71rad / 0.8) ", { 108, 147, 197 }, 0.8)
      test_rgb(css_lch, " lch(60 30 0.75turn / 0.8) ", { 108, 147, 197 }, 0.8)
    end)
  end)

  describe("OKLab Color: oklab() function", function()
    it("oklab() without alpha", function()
      test_rgb(css_oklab, " oklab(50% 40% -40%) ", { 145, 29, 184 }, nil)
      test_rgb(css_oklab, " oklab(0.5 0.16 -0.16) ", { 145, 29, 184 }, nil)
    end)
    it("oklab() with alpha", function()
      test_rgb(css_oklab, " oklab(50% 40% -40% / 80%) ", { 145, 29, 184 }, 0.8)
      test_rgb(css_oklab, " oklab(0.5 0.16 -0.16 / 0.8) ", { 145, 29, 184 }, 0.8)
    end)
  end)

  describe("OKLCH Color: oklch() function", function()
    it("lch() without alpha", function()
      test_rgb(css_oklch, " oklch(60% 20% 270) ", { 109, 126, 177 }, nil)
      test_rgb(css_oklch, " oklch(0.6 0.08 270deg) ", { 109, 126, 177 }, nil)
      test_rgb(css_oklch, " oklch(0.6 0.08 300grad) ", { 109, 126, 177 }, nil)
      test_rgb(css_oklch, " oklch(0.6 0.08 4.71rad) ", { 109, 126, 177 }, nil)
      test_rgb(css_oklch, " oklch(0.6 0.08 0.75turn) ", { 109, 126, 177 }, nil)
    end)
    it("lch() with alpha", function()
      test_rgb(css_oklch, " oklch(60% 20% 270 / 80%) ", { 109, 126, 177 }, 0.8)
      test_rgb(css_oklch, " oklch(0.6 0.08 270deg / 0.8) ", { 109, 126, 177 }, 0.8)
      test_rgb(css_oklch, " oklch(0.6 0.08 300grad / 0.8) ", { 109, 126, 177 }, 0.8)
      test_rgb(css_oklch, " oklch(0.6 0.08 4.71rad / 0.8) ", { 109, 126, 177 }, 0.8)
      test_rgb(css_oklch, " oklch(0.6 0.08 0.75turn / 0.8) ", { 109, 126, 177 }, 0.8)
    end)
  end)

  it("Named Colors", function()
    test_rgb(css_name, " yellow ", { 255, 255, 0 }, nil)
    test_rgb(css_name, " yellowgreen ", { 154, 205, 50 }, nil)
  end)

  it("Custom Entries", function()
    test_rgb(custom_entries({ red = "#ff0000" }), " red ", { 255, 0, 0 }, nil)
    test_rgb(custom_entries({ [ [[foo\bar]] ] = "#ff0000" }), [[ foo\bar ]], { 255, 0, 0 }, nil)

    local orig = vim.opt.iskeyword:get()
    vim.opt.iskeyword = { "@", "48-57", "_", "128-167", "224-235" } -- default for Lua
    test_rgb(custom_entries({ red = "#ff0000", ["red-green"] = "#ffff00" }), " red-green ", { 255, 255, 0 }, nil)
    vim.opt.iskeyword = orig
  end)

  describe("Trailing Whitespace", function()
    after_each(function()
      vim.bo.filetype = ""
    end)

    ---@param ft string
    ---@param opts TrailingWhitespaceConfig
    ---@param str string
    ---@param expected? string
    ---@param length integer
    local function test(ft, opts, str, expected, length)
      vim.bo.filetype = ft
      local start, end_, _, _, hl_def = trailing_whitespace(opts):parse_color(str)
      assert.equals(length, end_ - start + 1)
      assert.same({ bg = expected }, hl_def)
    end

    ---@param ft string
    ---@param opts TrailingWhitespaceConfig
    ---@param str string
    local function test_fail(ft, opts, str)
      vim.bo.filetype = ft
      local start = trailing_whitespace(opts):parse_color(str)
      assert.is_nil(start)
    end

    local default_color = "#db7093"

    it("enable for all filetypes (default)", function()
      test("markdown", {}, "ccc  ", default_color, 2)
      test("text", {}, "ccc   ", default_color, 3)
    end)

    it("enable in only markdown", function()
      local opts = { enable = { "markdown" } }
      test("markdown", opts, "ccc  ", default_color, 2)
      test_fail("text", opts, "ccc  ")
    end)

    it("enable in except markdown", function()
      local opts = { disable = { "markdown" } }
      test_fail("markdown", opts, "ccc  ")
      test("text", opts, "ccc  ", default_color, 2)
      test("lua", opts, "ccc  ", default_color, 2)
    end)

    it("Set default color", function()
      test("markdown", { default_color = "#ff0000" }, "ccc  ", "#ff0000", 2)
    end)

    it("Set palette to specify color per filetype", function()
      local opts = {
        palette = {
          markdown = "#ff0000",
        },
        default_color = "#00ff00",
      }
      test("markdown", opts, "ccc  ", "#ff0000", 2)
      test("text", opts, "ccc  ", "#00ff00", 2)
    end)
  end)

  describe("ANSI Escape", function()
    ---@param module ccc.ColorPicker
    ---@param str string
    ---@param expect_hl_def highlightDefinition
    local function test_hl_def(module, str, expect_hl_def)
      local start, end_, _, _, hl_def = module:parse_color(str)
      assert(start and end_ and hl_def, "Can't parse color")
      assert.equals(2, start)
      assert.equals(#str - 1, end_)
      assert.same(expect_hl_def, hl_def)
    end

    it("bold", function()
      test_hl_def(
        ansi_escape({ red = "#ff0000", blue = "#0000ff" }, { meaning1 = "bold" }),
        " \\u001b[31;44;1m ",
        { fg = "#ff0000", bg = "#0000ff", bold = true }
      )
    end)
    it("bright", function()
      test_hl_def(
        ansi_escape({ bright_red = "#ff0000", bright_blue = "#0000ff" }, { meaning1 = "bright" }),
        " \\u001b[31;44;1m ",
        { fg = "#ff0000", bg = "#0000ff" }
      )
    end)
    it("attributes", function()
      test_hl_def(
        ansi_escape({ foreground = "#ffffff", background = "#000000" }, { meaning1 = "bold" }),
        " \\u001b[1;3;4;7;9m ",
        {
          fg = "#ffffff",
          bg = "#000000",
          bold = true,
          italic = true,
          underline = true,
          reverse = true,
          strikethrough = true,
        }
      )
    end)
    it([[In a string (\ may become \\)]], function()
      test_hl_def(
        ansi_escape({ red = "#ff0000", blue = "#0000ff" }),
        [["\\u001b[31;44m"]],
        { fg = "#ff0000", bg = "#0000ff" }
      )
    end)
  end)
end)
