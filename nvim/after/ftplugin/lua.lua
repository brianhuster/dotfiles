vim.bo.path = nil
if not vim.fn.has('nvim-0.11') then
	vim.bo.omnifunc = "v:lua.vim.lua_omnifunc"
	vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr(v:fname)"
	vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
end
vim.bo.keywordprg = ':LuaKeywordPrg'
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })

vim.api.nvim_buf_create_user_command(0, 'LuaKeywordPrg', function()
	require('an.lua').keywordprg()
end, { nargs = '*' })

if not vim.b.root_dir then
	vim.b.root_dir = require('an.lua').find_root(vim.api.nvim_buf_get_name(0))
end

vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/completion') then
			vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
		end
		if client:supports_method('textDocument/Hover') then
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })
		end
	end,
})

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl omnifunc< includeexpr< keywordprg< path< include<',
	'delcommand -buffer LuaKeywordPrg',
	'unmap <buffer> K'
}, '\n')
