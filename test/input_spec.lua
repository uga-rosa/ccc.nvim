local utils = require("ccc.utils.test")
local cmyk = require("ccc.input.cmyk")
local hsl = require("ccc.input.hsl")
local hsluv = require("ccc.input.hsluv")
local hsv = require("ccc.input.hsv")
local hwb = require("ccc.input.hwb")
local lab = require("ccc.input.lab")
local lch = require("ccc.input.lch")
local okhsl = require("ccc.input.okhsl")
local okhsv = require("ccc.input.okhsv")
local oklab = require("ccc.input.oklab")
local oklch = require("ccc.input.oklch")
local rgb = require("ccc.input.rgb")
local xyz = require("ccc.input.xyz")

---@param colorInput ccc.ColorInput
---@param input number[] [n, i]
---@param expected string
local function format_test(colorInput, input, expected)
  assert.equals(expected, colorInput.format(unpack(input)))
end

---@param a number[]
---@return number[]
local function div255(a)
  return vim.tbl_map(function(x)
    return x / 255
  end, a)
end

---@param limit number|number[]|nil
---@param len integer
---@return number[]
local function normalize_limit(limit, len)
  limit = limit or (1 / 255)
  if type(limit) == "number" then
    local ret = {}
    for i = 1, len do
      ret[i] = limit
    end
    return ret
  end
  return limit
end

---@param colorInput ccc.ColorInput
---@param input number[] #RGB range in [0, 255]
---@param expected number[]
---@param limit? number|number[]
local function from_rgb_test(colorInput, input, expected, limit)
  input = div255(input)
  limit = normalize_limit(limit, #expected)
  local converted = colorInput.from_rgb(input)
  assert.equal(#expected, #converted)
  local msg = ("expected {%s}, but passed in {%s}"):format(table.concat(expected, ", "), table.concat(converted, ", "))
  for i = 1, #expected do
    assert.is_true(utils.near(expected[i], converted[i], limit[i]), msg)
  end
end

---@param colorInput ccc.ColorInput
---@param input number[]
---@param expected number[] #RGB range in [0, 255]
---@param limit? number|number[]
local function to_rgb_test(colorInput, input, expected, limit)
  expected = div255(expected)
  limit = normalize_limit(limit, #expected)
  local converted = colorInput.to_rgb(input)
  assert.equals(#expected, #converted)
  local msg = ("expected {%s}, but passed in {%s}"):format(table.concat(expected, ", "), table.concat(converted, ", "))
  for i = 1, #expected do
    assert.is_true(utils.near(expected[i], converted[i], limit[i]), msg)
  end
end

describe("input", function()
  describe("cmyk", function()
    it("format", function()
      format_test(cmyk, { 0.5 }, " 50.0%")
    end)
    it("from_rgb", function()
      from_rgb_test(cmyk, { 0, 0, 255 }, { 1, 1, 0, 0 })
    end)
    it("to_rgb", function()
      to_rgb_test(cmyk, { 1, 1, 0, 0 }, { 0, 0, 255 })
    end)
  end)

  describe("hsl", function()
    it("format", function()
      format_test(hsl, { 0.5, 2 }, "    50")
    end)
    it("from_rgb", function()
      from_rgb_test(hsl, { 255, 0, 0 }, { 0, 1, 0.5 })
    end)
    it("to_rgb", function()
      to_rgb_test(hsl, { 0, 1, 0.5 }, { 255, 0, 0 })
    end)
  end)

  describe("hsluv", function()
    it("format", function()
      format_test(hsluv, { 100 }, "   100")
    end)
    it("from_rgb", function()
      from_rgb_test(hsluv, { 17, 238, 0 }, { 127.48, 100, 82.52 })
    end)
    it("to_rgb", function()
      to_rgb_test(hsluv, { 127.48, 100, 82.52 }, { 17, 238, 0 })
    end)
  end)

  describe("hsv", function()
    it("format", function()
      format_test(hsv, { 0.5, 2 }, "    50")
    end)
    it("from_rgb", function()
      from_rgb_test(hsv, { 255, 0, 0 }, { 0, 1, 1 })
    end)
    it("to_rgb", function()
      to_rgb_test(hsv, { 0, 1, 1 }, { 255, 0, 0 })
    end)
  end)

  describe("hwb", function()
    it("format", function()
      format_test(hwb, { 0.5, 2 }, "    50")
    end)
    it("from_rgb", function()
      from_rgb_test(hwb, { 0, 0, 255 }, { 240, 0, 0 })
    end)
    it("to_rgb", function()
      to_rgb_test(hwb, { 240, 0, 0 }, { 0, 0, 255 })
    end)
  end)

  describe("lab", function()
    it("format", function()
      format_test(lab, { 100 }, "   100")
    end)
    it("from_rgb", function()
      from_rgb_test(lab, { 128, 128, 128 }, { 53.585, 0, 0 }, 0.01)
    end)
    it("to_rgb", function()
      to_rgb_test(lab, { 53.585, 0, 0 }, { 128, 128, 128 })
    end)
  end)

  describe("lch", function()
    it("format", function()
      format_test(lch, { 100 }, "   100")
    end)
    it("from_rgb", function()
      from_rgb_test(lch, { 255, 0, 0 }, { 53.233, 104.576, 40.000 }, 0.1)
    end)
    it("to_rgb", function()
      to_rgb_test(lch, { 53.233, 104.576, 40.000 }, { 255, 0, 0 })
    end)
  end)

  describe("okhsl", function()
    it("format", function()
      format_test(okhsl, { 1, 2 }, "   100")
    end)
    it("from_rgb", function()
      from_rgb_test(okhsl, { 35, 253, 0 }, { 142, 1, 0.84 }, { 0.1, 0.005, 0.005 })
    end)
    it("to_rgb", function()
      to_rgb_test(okhsl, { 142, 1, 0.84 }, { 35, 253, 0 })
    end)
  end)

  describe("okhsv", function()
    it("format", function()
      format_test(okhsv, { 1, 2 }, "   100")
    end)
    it("from_rgb", function()
      from_rgb_test(okhsv, { 255, 21, 0 }, { 30, 1, 1 }, { 0.1, 0.001, 0.001 })
    end)
    it("to_rgb", function()
      to_rgb_test(okhsv, { 30, 1, 1 }, { 255, 21, 0 })
    end)
  end)

  describe("oklab", function()
    it("format", function()
      format_test(oklab, { 0.2, 2 }, "   50%")
    end)
    it("from_rgb", function()
      from_rgb_test(oklab, { 255, 0, 0 }, { 0.628, 0.225, 0.126 }, { 0.1, 0.001, 0.001 })
    end)
    it("to_rgb", function()
      to_rgb_test(oklab, { 0.628, 0.225, 0.126 }, { 255, 0, 0 })
    end)
  end)

  -- oklch(62.8%, 64.5%, 29.234%)
  describe("oklch", function()
    it("format", function()
      format_test(oklch, { 1, 1 }, "  100%")
    end)
    it("from_rgb", function()
      from_rgb_test(oklch, { 255, 0, 0 }, { 0.628, 0.258, 29.234 }, { 0.1, 0.001, 0.001 })
    end)
    it("to_rgb", function()
      to_rgb_test(oklch, { 0.628, 0.258, 29.234 }, { 255, 0, 0 })
    end)
  end)

  describe("rgb", function()
    it("format", function()
      format_test(rgb, { 1 }, "   255")
    end)
    it("from_rgb", function()
      from_rgb_test(rgb, { 255, 0, 0 }, { 1, 0, 0 })
    end)
    it("to_rgb", function()
      to_rgb_test(rgb, { 1, 0, 0 }, { 255, 0, 0 })
    end)
  end)

  describe("xyz", function()
    it("format", function()
      format_test(xyz, { 1, 1 }, "100.0%")
    end)
    it("from_rgb", function()
      from_rgb_test(xyz, { 255, 0, 0 }, { 0.4124, 0.2126, 0.0193 })
    end)
    it("to_rgb", function()
      to_rgb_test(xyz, { 0.4124, 0.2126, 0.0193 }, { 255, 0, 0 })
    end)
  end)
end)
