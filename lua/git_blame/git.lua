local Git = {}

local function exec_cmd(cmd, callback)
  local output = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data and type(data) == "table" then
        for _, line in ipairs(data) do
          if line and #line > 0 then
            table.insert(output, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code == 0 and callback then
        callback(output)
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
