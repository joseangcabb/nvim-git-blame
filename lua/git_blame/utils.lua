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

return M
