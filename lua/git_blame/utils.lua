local Utils = {}

-- Executes a shell command asynchronously and captures its output
-- @param cmd table: The command to execute as a table of strings
-- @param callback function: The function to call with the command's output
-- @return nil: This function does not return a value
Utils.exec_cmd = function(cmd, callback)
  local result = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          table.insert(result, line)
        end
      end
    end,

    on_exit = function(_, exit_code)
      if exit_code == 0 then -- Success
        callback(result)
      end
    end,
  })
end

-- Function to convert a timestamp to a human-readable "time ago" format
-- @param timestamp number: The timestamp to convert
-- @return string: A string representing the time elapsed since the give timestamp
Utils.time_ago = function(timestamp)
  local now = os.time()
  local seconds = now - timestamp

  -- Define time intervals in secods (approximations for months and years)
  local intervals = {
    year = 31536000,
    month = 2592000,
    day = 86400,
    hour = 3600,
    minute = 60,
  }

  -- Calculate the time difference in the largest possible unit
  for unit, seconds_in_unit in pairs(intervals) do
    local interval = math.floor(seconds / seconds_in_unit)
    if interval >= 1 then
      return interval .. " " .. unit .. (interval == 1 and "" or "s") .. " ago"
    end
  end

  return "Just now"
end

return Utils
