local M = {}

M.exec_cmd = function(cmd, callback)
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

M.time_ago = function(time)
  local now = os.time()
  local seconds = now - time

  local intervals = {
    year = 31536000,
    month = 2592000,
    day = 86400,
    hour = 3600,
    minute = 60,
  }

  for unit, seconds_in_unit in pairs(intervals) do
    local interval = math.floor(seconds / seconds_in_unit)
    if interval >= 1 then
      return interval .. " " .. unit .. (interval == 1 and "" or "s") .. " ago"
    end
  end

  return "Just now"
end

return M
