local M = {}

_G.enable_format_on_save = false

local function ensure_c_formatter_42_installed()
	local home = vim.fn.expand("~")
	local install_dir = home .. "/.local/src/c_formatter_42"
	local venv_path = install_dir .. "/venv"
	local bin_path = venv_path .. "/bin"
	local formatter_path = bin_path .. "/c_formatter_42"

	if vim.fn.executable(formatter_path) == 1 then
		return formatter_path
	end

	vim.notify("Installing c_formatter_42 in virtualenv...", vim.log.levels.INFO)

	if vim.fn.isdirectory(install_dir) == 0 then
		vim.fn.mkdir(install_dir, "p")
	end

	local cmds = {
		string.format("git clone https://github.com/cacharle/c_formatter_42 %s", install_dir),
		string.format("python -m venv %s", venv_path),
		string.format("%s/pip install -e %s", bin_path, install_dir),
	}

	for _, cmd in ipairs(cmds) do
		local result = vim.fn.system(cmd)
		if vim.v.shell_error ~= 0 then
			vim.notify("Installation step failed:\n" .. result, vim.log.levels.ERROR)
			return nil
		end
	end

	vim.notify("Successfully installed c_formatter_42 in virtualenv", vim.log.levels.INFO)
	return formatter_path
end

function M.format()
	local buf = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(buf)

	if filepath == "" or vim.bo[buf].filetype ~= "c" then
		vim.notify("Not a .c file", vim.log.levels.WARN)
		return
	end

	local formatter = ensure_c_formatter_42_installed()
	if not formatter then
		return
	end

	local cmd = string.format("%s %s", formatter, vim.fn.shellescape(filepath))
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
