local M = {}

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(buf)

	if filepath == "" or vim.bo[buf].filetype ~= "c" then
		vim.notify("Not a .c file", vim.log.levels.WARN)
		return
	end

	local cmd = string.format("c_formatter_42 %s", vim.fn.shellescape(filepath))
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.api.nvim_command("edit!")
				vim.notify("Formatted with c_formatter_42", vim.log.levels.INFO)
			else
				vim.notify("Formatting failed", vim.log.levels.ERROR)
			end
		end,
		stderr_buffered = true,
		stdout_buffered = true,
	})
end

function M.setup(opts)
	opts = opts or {}
	local auto_format = opts.auto_format or false

	vim.api.nvim_create_user_command("FormatC42", function()
		M.format()
	end, {})

	if auto_format then
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.c",
			callback = function()
				M.format()
			end,
		})
	end
end

return M
