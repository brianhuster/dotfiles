vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		local ft = vim.bo.ft
		if vim.tbl_contains({ 'vim', 'editorconfig' }, ft) then
			return
		end
		pcall(function() vim.treesitter.start() end)
	end
})
