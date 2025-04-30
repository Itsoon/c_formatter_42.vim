local M = {}

-- Flag global pour activer/désactiver le format-on-save
_G.cfe42_auto_format = true

-- Fonction principale de formatage
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

-- Autocommand pour format-on-save si activé
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.c",
	callback = function()
		if _G.cfe42_auto_format then
			M.format()
		end
	end,
})

-- Commande pour toggle
vim.api.nvim_create_user_command("ToggleCFormat", function()
	_G.cfe42_auto_format = not _G.cfe42_auto_format
	vim.notify("Auto format: " .. (_G.cfe42_auto_format and "ON" or "OFF"))
end, {})

return M
