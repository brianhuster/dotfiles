vim.bo.path = nil
vim.bo.omnifunc = "v:lua.vim.lua_omnifunc"
vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr(v:fname)"
vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
if not vim.b.root_dir then
	vim.b.root_dir = require('an.lua').find_root(vim.api.nvim_buf_get_name(0))
end

vim.keymap.set('n', '<C-k>', function()
	require 'an.lua'.keywordexpr()
end, { buffer = true })

vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/completion') then
			vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
		end
	end,
})

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl omnifunc< includeexpr<',
	'nunmap <buffer> <C-k>',
}, '\n')
