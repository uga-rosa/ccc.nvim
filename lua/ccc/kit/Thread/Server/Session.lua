local mpack = require("mpack")
local Async = require("ccc.kit.Async")

---Encode data to msgpack.
---@param v any
---@return string
local function encode(v)
  if v == nil then
    return mpack.encode(mpack.NIL)
  end
  return mpack.encode(v)
end

---@class ccc.kit.Thread.Server.Session
---@field private reader uv.uv_pipe_t
---@field private writer uv.uv_pipe_t
---@field private mpack_session any
---@field public on_request table<string, fun(params: table): any>
---@field public on_notification table<string, fun(params: table): nil>
local Session = {}
Session.__index = Session

---@param reader uv.uv_pipe_t
---@param writer uv.uv_pipe_t
function Session.new(reader, writer)
  local self = setmetatable({}, Session)
  self.on_request = {}
  self.on_notification = {}
  self.mpack_session = mpack.Session({ unpack = mpack.Unpacker() })
  self.reader = reader
  self.writer = writer
  self.reader:read_start(function(err, data)
    if err then
      error(err)
    end

    local offset = 1
    local length = #data
    while offset <= length do
      local type, id_or_cb, method_or_error, params_or_result, new_offset = self.mpack_session:receive(data, offset)
      if type == "request" then
        local request_id, method, params = id_or_cb, method_or_error, params_or_result
        Async.resolve()
          :next(function()
            return Async.run(function()
              return self.on_request[method](params)
            end)
          end)
          :next(function(res)
            self.writer:write(self.mpack_session:reply(request_id) .. encode(mpack.NIL) .. encode(res))
          end)
          :catch(function(err_)
            self.writer:write(self.mpack_session:reply(request_id) .. encode(err_) .. encode(mpack.NIL))
          end)
      elseif type == "notification" then
        local method, params = method_or_error, params_or_result
        self.on_notification[method](params)
      elseif type == "response" then
        local callback, err_, res = id_or_cb, method_or_error, params_or_result
        if err_ == mpack.NIL then
          callback(nil, res)
        else
          callback(err_, nil)
        end
      end
      offset = new_offset
    end
  end)
  return self
end

---Send request to the peer.
---@param method string
---@param params table
---@return ccc.kit.Async.AsyncTask
function Session:request(method, params)
  return Async.new(function(resolve, reject)
    local request = self.mpack_session:request(function(err, res)
      if err then
        reject(err)
      else
        resolve(res)
      end
    end)
    self.writer:write(request .. encode(method) .. encode(params))
  end)
end

---Send notification to the peer.
---@param method string
---@param params table
function Session:notify(method, params)
  self.writer:write(self.mpack_session:notify() .. encode(method) .. encode(params))
end

return Session
