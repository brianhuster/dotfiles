local triggers = { "." }
vim.api.nvim_create_autocmd("InsertCharPre", {
	buffer = vim.api.nvim_get_current_buf(),
	callback = function()
		if vim.fn.pumvisible() == 1 or vim.fn.state("m") == "m" then
			return
		end
		local char = vim.v.char
		if vim.list_contains(triggers, char) then
			local key = vim.keycode("<C-x><C-n>")
			vim.api.nvim_feedkeys(key, "m", false)
		end
	end
})
