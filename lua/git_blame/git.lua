local Utils = require("git_blame.utils")
local Git = {}

function Git:new(object)
  object = object or {}
  setmetatable(object, self)
  self.__index = self
  return object
end

function parseMetadata(raw_line)
  local author = string.match(raw_line, "^author%s(.*)$")
  if author then
    return "author", author
  end

  local time = string.match(raw_line, "^committer%-time%s(.*)$")
  if time then
    return "time", os.date("%B %d, %Y at %I:%M %p", time)
  end

  local message = string.match(raw_line, "^summary%s(.*)$")
  if message then
    return "message", message
  end

  return nil, nil
end

function Git:blame(file, callback)
  local result = {}
  local cmd = { "git", "blame", "--line-porcelain", "-L", "3,10", file }

  Utils.exec_cmd(cmd, function(output)
    local current_line = nil

    for _, raw_line in ipairs(output) do
      local hash, line_number = string.match(raw_line, "^(%w+)%s%d+%s(%d+)")
      if hash and line_number then
        current_line = tonumber(line_number)
        result[current_line] = {
          hash = string.sub(hash, 1, 6)
        }
      else
        local key, value = parseMetadata(raw_line)
        if key and value then
          result[current_line][key] = value
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
