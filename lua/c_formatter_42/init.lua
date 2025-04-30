local M = {}

-- Format le buffer courant avec `c_formatter_42`
function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(buf)

	if filepath == "" or vim.bo[buf].filetype ~= "c" then
		vim.notify("Not a C file", vim.log.levels.WARN)
		return
	end

	local cmd = string.format("c_formatter_42 %s", vim.fn.shellescape(filepath))
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.cmd("edit!") -- Reload the file
				vim.notify("Formatted with c_formatter_42", vim.log.levels.INFO)
			else
				vim.notify("Formatting failed", vim.log.levels.ERROR)
			end
		end,
	})
end

return M
