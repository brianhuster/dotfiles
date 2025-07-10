if vim.fn.has('nvim-0.11') == 0 then
	vim.bo.includeexpr = "v:lua.require'an.lua'.includeexpr(v:fname)"
end
vim.bo.keywordprg = ':LuaKeywordPrg'
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0 })

local buf = vim.api.nvim_get_current_buf()

vim.cmd.setlocal "path-=."

if pcall(require, 'nvim-treesitter') then
	vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_buf_create_user_command(0, 'LuaKeywordPrg', function()
	require('an.lua').keywordprg()
end, { nargs = '*' })

vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/hover') then
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf })
		end
	end,
})

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl omnifunc< includeexpr< keywordprg< path< indentexpr<',
	'delcommand -buffer LuaKeywordPrg',
	'unmap <buffer> K'
}, '\n')
