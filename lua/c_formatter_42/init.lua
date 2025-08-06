local M = {}

_G.enable_format_on_save = false

local function ensure_c_formatter_42_installed()
	if vim.fn.executable("c_formatter_42") == 1 then
		return true
	end

	vim.notify("Installing c_formatter_42...", vim.log.levels.INFO)

	local install_dir = vim.fn.expand("~/.local/src/c_formatter_42")
	if vim.fn.isdirectory(install_dir) == 0 then
		vim.fn.mkdir(install_dir, "p")
	end

	local install_cmd = string.format(
		[[
		git clone https://github.com/cacharle/c_formatter_42 %s && \
		pip3 install --user -e %s
	]],
		install_dir,
		install_dir
	)

	local result = vim.fn.system(install_cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to install c_formatter_42:\n" .. result, vim.log.levels.ERROR)
		return false
	end

	local local_bin = vim.fn.expand("~/.local/bin")
	if not string.find(vim.env.PATH, local_bin, 1, true) then
		vim.env.PATH = vim.env.PATH .. ":" .. local_bin
	end

	vim.notify("Successfully installed c_formatter_42", vim.log.levels.INFO)
	return true
end

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
				vim.cmd("edit!") -- Reload the file after formatting
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
	if not ensure_c_formatter_42_installed() then
		return
	end

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
