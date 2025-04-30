vim.keymap.set("n", "<leader>uf", function()
	_G.enable_format_on_save = not _G.enable_format_on_save

	if _G.enable_format_on_save then
		vim.notify("Format on save: ENABLED", vim.log.levels.INFO)
	else
		vim.notify("Format on save: DISABLED", vim.log.levels.WARN)
	end
end, { desc = "Toggle format on save" })

local M = {}

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(buf)

	if filepath == "" or vim.bo[buf].filetype ~= "c" then
		return
	end

	local cmd = string.format("c_formatter_42 %s", vim.fn.shellescape(filepath))
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.cmd("edit!") -- Reload the file
				vim.notify("Formatted with c_formatter_42", vim.log.levels.INFO)
			else
				vim.notify("c_formatter_42 failed", vim.log.levels.ERROR)
			end
		end,
	})
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.c",
	callback = function()
		if _G.enable_format_on_save then
			M.format()
		end
	end,
})

return M
