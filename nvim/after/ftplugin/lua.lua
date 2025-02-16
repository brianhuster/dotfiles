vim.bo.omnifunc = "v:lua.vim.lua_omnifunc"
vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr(v:fname)"
if not vim.b.root_dir then
	vim.b.root_dir = require('an.lua').find_root(vim.api.nvim_buf_get_name(0))
end

if vim.fn.maparg('K', 'n') == '' then
	vim.keymap.set('n', 'K', function() require('an.lua').keywordexpr() end,
		{ buffer = true, desc = 'Open help docs for term under cursor' })
end

vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/hover') then
			vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { buffer = true, desc = 'vim.lsp.buf.hover()' })
		end
		if client:supports_method('textDocument/completion') then
			vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
		end
	end,
})
