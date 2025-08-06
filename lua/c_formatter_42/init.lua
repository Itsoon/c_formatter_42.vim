local M = {}

_G.enable_format_on_save = false

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(buf)

	if filepath == "" or vim.bo[buf].filetype ~= "c" then
		vim.notify("Not a .c file", vim.log.levels.WARN)
		return
	end

	if vim.fn.executable("c_formatter_42") == 0 then
		vim.notify("[c_formatter_42] Not found in PATH. Please install it.", vim.log.levels.ERROR)
		return
	end

	local cmd = string.format("c_formatter_42 %s", vim.fn.shellescape(filepath))
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.cmd("edit!")
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
	local toggle_key = opts.toggle_key or "<leader>uf"

	vim.api.nvim_create_user_command("FormatC42", function()
		M.format()
	end, {
		desc = "Format current C file with c_formatter_42",
	})

	if auto_format then
		M.enable_format_on_save()
	end

	vim.keymap.set("n", toggle_key, function()
		M.toggle_format_on_save()
	end, { desc = "Toggle format on save" })
end

function M.enable_format_on_save()
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*.c",
		callback = function()
			if _G.enable_format_on_save then
				M.format()
			end
		end,
	})
end

function M.toggle_format_on_save()
	_G.enable_format_on_save = not _G.enable_format_on_save

	if _G.enable_format_on_save then
		vim.notify("Format on save: ENABLED", vim.log.levels.INFO)
	else
		vim.notify("Format on save: DISABLED", vim.log.levels.WARN)
	end
end

return M
