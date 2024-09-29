local Utils = require("git_blame.utils")
local Git = {}

function Git:new(object)
  object = object or {}
  setmetatable(object, self)
  self.__index = self
  return object
end

function Git:blame(file, callback)
  local result = {}
  local cmd = { "git", "blame", "--line-porcelain", "-L", "1,3", file }

  Utils.exec_cmd(cmd, function(output)
    local code_line = nil

    for _, raw_data in ipairs(output) do
      if not code_line then
        local hash, temp_code_line = string.match(raw_data, "^(%w+)%s%d+%s(%d+)")

        if hash and temp_code_line then
          code_line = temp_code_line
          result[code_line] = result[code_line] or {}
          result[code_line].hash = string.sub(hash, 1, 6)
        end
      else
        local author = string.match(raw_data, "^author%s(.*)$")
        if author then
          result[code_line].author = author
        end

        local time = string.match(raw_data, "^committer%-time%s(.*)$")
        if time then
          result[code_line].time = os.date("%B %d, %Y at %I:%M %p", time)
        end

        local message = string.match(raw_data, "^summary%s(.*)$")
        if message then
          result[code_line].message = message
        end

        if result[code_line].hash and
            result[code_line].author and
            result[code_line].time and
            result[code_line].message then
          code_line = nil
        end
      end
    end

    if callback then
      P(result)
      callback(result)
    end
  end)
end

return Git
