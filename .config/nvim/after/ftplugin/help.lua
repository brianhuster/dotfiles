vim.cmd [[
	let s:tags_files = globpath(&rtp, 'doc/tags', 0, 1, 1)
		\ ->extend(globpath(&packpath, '*/start/doc/tags', 0, 1, 1))
		\ ->map({ k, v -> escape(v, ', \') })
		\ ->join(',')
	exe 'setl tags+=' .. s:tags_files
]]

vim.bo.keywordprg = ':HelpKeywordPrg'

vim.api.nvim_buf_create_user_command(0, 'HelpKeywordPrg', function()
	require('an.help').keywordprg()
end, { nargs = '*' })

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl keywordprg<',
	'delcommand -buffer HelpKeywordPrg',
	'setl tags< tagfunc<'
}, '\n')
