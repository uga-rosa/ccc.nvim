local config = require("ccc.config")
local handler = require("ccc.handler.lsp")
local highlighter = require("ccc.highlighter")

local function color_information(red, green, blue)
  return {
    {
      range = {
        start = { line = 0, character = 0 },
        ["end"] = { line = 0, character = 1 },
      },
      color = { red = red, green = green, blue = blue, alpha = 1 },
    },
  }
end

describe("LSP document colors", function()
  local original_config_options
  local original_get_clients
  local original_highlighter_update
  local original_attached_buffer
  local original_enabled
  local original_color_info_map
  local original_request_generation
  local original_next_generation
  local original_mode
  local bufnr
  local previous_bufnr

  before_each(function()
    original_config_options = config.options
    original_get_clients = vim.lsp.get_clients
    original_highlighter_update = highlighter.update
    original_attached_buffer = highlighter.attached_buffer
    original_enabled = handler.enabled
    original_color_info_map = handler.color_info_map
    original_request_generation = handler.request_generation
    original_next_generation = handler.next_generation
    original_mode = vim.fn.mode

    config.options = {
      highlight_mode = "bg",
      highlighter = { lsp = true, picker = false, update_insert = true },
    }
    handler:disable()
    handler.enabled = true
    highlighter.attached_buffer = {}

    previous_bufnr = vim.api.nvim_get_current_buf()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { "x" })
  end)

  after_each(function()
    vim.lsp.get_clients = original_get_clients
    highlighter.update = original_highlighter_update
    highlighter.attached_buffer = original_attached_buffer
    config.options = original_config_options
    handler.enabled = original_enabled
    handler.color_info_map = original_color_info_map
    handler.request_generation = original_request_generation
    handler.next_generation = original_next_generation
    vim.fn.mode = original_mode

    if vim.api.nvim_buf_is_valid(bufnr) then
      if vim.api.nvim_get_current_buf() == bufnr and vim.api.nvim_buf_is_valid(previous_bufnr) then
        vim.api.nvim_set_current_buf(previous_bufnr)
      end
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  local function deferred_client()
    local callbacks = {}
    vim.lsp.get_clients = function()
      return {
        {
          supports_method = function()
            return true
          end,
          request = function(_, _, _, response)
            callbacks[#callbacks + 1] = response
          end,
        },
      }
    end
    return callbacks
  end

  it("redraws real extmarks after accepting a current response while attached", function()
    local callbacks = deferred_client()
    local redraw_end_line
    highlighter.update = function(self, redraw_bufnr, start_line, end_line)
      redraw_end_line = end_line
      original_highlighter_update(self, redraw_bufnr, start_line, end_line)
    end
    highlighter.attached_buffer[bufnr] = true

    handler:update(bufnr)
    callbacks[1](nil, color_information(1, 0, 0))

    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, highlighter.lsp_ns_id, 0, -1, {})
    assert.equals(1, #handler.color_info_map[bufnr])
    assert.equals(1, #extmarks)
    assert.equals(vim.api.nvim_buf_line_count(bufnr), redraw_end_line)
  end)

  it("does not redraw while the buffer is unattached", function()
    local callbacks = deferred_client()
    local redraw_count = 0
    highlighter.update = function()
      redraw_count = redraw_count + 1
    end

    handler:update(bufnr)
    callbacks[1](nil, color_information(1, 0, 0))

    assert.equals(1, #handler.color_info_map[bufnr])
    assert.equals(0, redraw_count)
  end)

  it("does not redraw in insert mode when updates are disabled", function()
    local callbacks = deferred_client()
    local redraw_count = 0
    config.options.highlighter.update_insert = false
    highlighter.attached_buffer[bufnr] = true
    highlighter.update = function()
      redraw_count = redraw_count + 1
    end
    vim.fn.mode = function()
      return "i"
    end

    handler:update(bufnr)
    callbacks[1](nil, color_information(1, 0, 0))

    assert.equals(1, #handler.color_info_map[bufnr])
    assert.equals(0, redraw_count)
  end)

  it("rejects responses after the buffer changes", function()
    local callbacks = deferred_client()

    handler:update(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { "y" })
    callbacks[1](nil, color_information(1, 0, 0))

    assert.is_nil(handler.color_info_map[bufnr])
  end)

  it("rejects responses from older generations", function()
    local callbacks = deferred_client()
    highlighter.update = function() end

    handler:update(bufnr)
    handler:update(bufnr)
    callbacks[2](nil, color_information(0, 1, 0))
    callbacks[1](nil, color_information(1, 0, 0))

    assert.equals(0, handler.color_info_map[bufnr][1].color.red)
    assert.equals(1, handler.color_info_map[bufnr][1].color.green)
  end)

  it("rejects responses from before disable and re-enable", function()
    local callbacks = deferred_client()
    highlighter.update = function() end

    handler:update(bufnr)
    handler:disable()
    handler.enabled = true
    handler:update(bufnr)
    callbacks[2](nil, color_information(0, 1, 0))
    callbacks[1](nil, color_information(1, 0, 0))

    assert.equals(0, handler.color_info_map[bufnr][1].color.red)
    assert.equals(1, handler.color_info_map[bufnr][1].color.green)
  end)

  it("cleans up state when a buffer detaches", function()
    local detached_bufnr = vim.api.nvim_create_buf(false, true)
    handler:attach(detached_bufnr)
    handler.color_info_map[detached_bufnr] = color_information(1, 0, 0)
    handler.request_generation[detached_bufnr] = 1

    vim.api.nvim_buf_delete(detached_bufnr, { force = true })

    assert.is_nil(handler.color_info_map[detached_bufnr])
    assert.is_nil(handler.request_generation[detached_bufnr])
  end)

  it("safely ignores updates for an invalid buffer", function()
    local invalid_bufnr = vim.api.nvim_create_buf(false, true)
    handler.color_info_map[invalid_bufnr] = color_information(1, 0, 0)
    handler.request_generation[invalid_bufnr] = 1
    vim.api.nvim_buf_delete(invalid_bufnr, { force = true })

    assert.has_no_errors(function()
      handler:update(invalid_bufnr)
    end)
    assert.is_nil(handler.color_info_map[invalid_bufnr])
    assert.is_nil(handler.request_generation[invalid_bufnr])
  end)
end)
