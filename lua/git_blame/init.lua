local Git = require("git_blame.git")

local M = {}
local api = vim.api

M.show_blame = function()
	local file = api.nvim_buf_get_name(0)
	local git = Git:new()
	git:blame(file, function(result)
    -- TODO: Retrieve git blame result
	end)
end

return M
