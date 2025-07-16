vim.bo.omnifunc = 'syntaxcomplete#Complete'

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl omnifunc<'
}, '\n')
