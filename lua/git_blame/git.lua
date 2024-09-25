local Git = {}

local function exec_cmd(cmd, callback)
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        callback(data)
      end
    end,
  })
end

function Git:new(object)
  object = object or {}
  setmetatable(object, self)
  self.__index = self
  return object
end

function Git:blame(file, callback)
  local result = {}
  local cmd = {"git", "blame", file}

  exec_cmd(cmd, function(output)
    for _, line in ipairs(output) do
      local commit = line:match("^(%x+)")
      table.insert(result, commit)
    end

    if callback then
      callback(result)
    end
  end)
end

return Git
