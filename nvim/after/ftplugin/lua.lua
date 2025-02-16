if vim.fn.maparg('K', 'n') == '' then
	vim.keymap.set('n', 'K', function() require('an.lua').keywordprg() end,
		{ buffer = true, desc = 'Open help docs for term under cursor' })
end

-- vim.bo.keywordprg = ":call v:lua.require'an.lua'.keywordprg()"

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client:supports_method('textDocument/hover') then
			vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = true, desc = 'vim.lsp.buf.hover()' })
		end
	end,
})

vim.bo.omnifunc = "v:lua.require'an.lua'.omnifunc"
vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr(v:fname)"
