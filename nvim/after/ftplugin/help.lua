vim.bo.keywordprg = ':HelpKeywordPrg'

vim.api.nvim_buf_create_user_command(0, 'HelpKeywordPrg', function()
	require('an.help').keywordprg()
end, { nargs = '*' })

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl keywordprg<',
	'delcommand -buffer HelpKeywordPrg',
}, '\n')
