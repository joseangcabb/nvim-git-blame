local Utils = require "git_blame.utils"

-- Module to handle blame logic in git
local Git = {}
Git.__index = Git

-- Create a new Git instance
-- @param object table: An optional table to initialize the instance
-- @return Git: A new instance of Git
function Git:new(object)
  return setmetatable(object or {}, self)
end

-- Table with patterns to extract metadata
local metadata_patterns = {
  hash_and_line_number = "^(%w+)%s%d+%s(%d+)",
  author = "^author%s(.*)$",
  time = "^committer%-time%s(.*)$",
  message = "^summary%s(.*)$",
}

-- Function to parse the metadata of a blame line
-- @param raw_line string: A line from git blame output
-- @return string|nil, string|nil: Returns key-value pairs for metadata or nil
local function parseMetadata(raw_line)
  for key, pattern in pairs(metadata_patterns) do
    local value = string.match(raw_line, pattern)
    if value then
      return key, value
    end
  end

  return nil, nil
end

-- Main function to execute the blame command and process the result
-- @param file string: The file path on which to execute the git blame command
-- param callback function: A function to call with the result
function Git:blame(file, callback)
  local result = {}
  local cmd = { "git", "blame", "--line-porcelain", "-L", "3,10", file }

  Utils.exec_cmd(cmd, function(output)
    local code_line = nil

    for _, raw_line in ipairs(output) do
      -- If the output line begins with a hash followed by a line number,
      -- extract the line number and use it to record the associated metadata.
      local hash, line_number = string.match(raw_line, metadata_patterns.hash_and_line_number)
      if hash and line_number then
        code_line = tonumber(line_number)
        if code_line then
          result[code_line] = {
            hash = string.sub(hash, 1, 6)
          }
        end
      elseif code_line then -- Record metadata for the specific code line
        local key, value = parseMetadata(raw_line)
        if key and value then
          result[code_line][key] = value
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
