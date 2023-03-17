local uv = require('luv')
local Session = require('ccc.kit.Thread.Server.Session')

---Return current executing file directory.
---@return string
local function dirname()
  return debug.getinfo(2, "S").source:sub(2):match("(.*)/")
end

---@class ccc.kit.Thread.Server
---@field private stdin uv.uv_pipe_t
---@field private stdout uv.uv_pipe_t
---@field private stderr uv.uv_pipe_t
---@field private dispatcher fun(session: ccc.kit.Thread.Server.Session): nil
---@field private process? uv.uv_process_t
---@field private session? ccc.kit.Thread.Server.Session
local Server = {}
Server.__index = Server

---Create new server instance.
---@param dispatcher fun(session: ccc.kit.Thread.Server.Session): nil
---@return ccc.kit.Thread.Server
function Server.new(dispatcher)
  local self = setmetatable({}, Server)
  self.stdin = uv.new_pipe()
  self.stdout = uv.new_pipe()
  self.stderr = uv.new_pipe()
  self.dispatcher = dispatcher
  self.process = nil
  self.session = nil
  return self
end

---Connect to server.
---@return ccc.kit.Async.AsyncTask
function Server:connect()
  self.process = uv.spawn('nvim', {
    cwd = uv.cwd(),
    args = {
      '--headless',
      '--noplugin',
      '-l',
      ('%s/_bootstrap.lua'):format(dirname()),
      vim.o.runtimepath
    },
    stdio = { self.stdin, self.stdout, self.stderr }
  })
  self.session = Session.new(self.stdout, self.stdin)
  return self.session:request('connect', {
    dispatcher = string.dump(self.dispatcher)
  })
end

--- Send request.
---@param method string
---@param params table
function Server:request(method, params)
  if not self.process then
    error('Server is not connected.')
  end
  return self.session:request(method, params)
end

---Send notification.
---@param method string
---@param params table
function Server:notify(method, params)
  if not self.process then
    error('Server is not connected.')
  end
  self.session:notify(method, params)
end

---Kill server process.
function Server:kill()
  if self.process then
    local ok, err = self.process:kill('SIGINT')
    if not ok then
      error(err)
    end
    self.process = nil
  end
end

return Server
