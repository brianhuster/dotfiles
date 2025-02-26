if vim.loader then
	vim.loader.enable()
end
vim.g.loaded_perl_provider = 1

local function ins_autocomplete(shortcut, triggers)
	if vim.fn.pumvisible() == 1 or vim.fn.state('m') == 'm' then
		return
	end
	local char = vim.v.char
	if vim.list_contains(triggers, char) then
		shortcut = vim.keycode(shortcut)
		vim.api.nvim_feedkeys(shortcut, 'm', false)
	end
end

vim.api.nvim_create_autocmd('InsertCharPre', {
	callback = function()
		ins_autocomplete('<C-x><C-f>', { '/' })
		if vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
			ins_autocomplete('<C-x><C-n>', { ' ', '(', '\n' })
		end
	end
})
