if vim.loader then
	vim.loader.enable()
end

vim.api.nvim_create_autocmd('InsertCharPre', {
	callback = function()
		require 'an'.ins_autocomplete('<C-x><C-f>', { '/' })
		if vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
			require 'an'.ins_autocomplete('<C-x><C-n>', { ' ', '(', '\n' })
		end
	end
})
