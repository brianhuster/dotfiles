vim.cmd [[
	let s:tags_files = globpath(&rtp, 'doc/tags', 0, 1, 1)
		\ ->extend(globpath(&packpath, '*/start/doc/tags', 0, 1, 1))
		\ ->map({ k, v -> escape(v, ', \') })
		\ ->join(',')
	exe 'setl tags+=' .. s:tags_files
]]

vim.bo.comments = ''
vim.bo.keywordprg = [[:lua require'an.help'.keywordprg() --]]
vim.bo.formatexpr = "v:lua.require'an.help'.formatexpr(v:lnum, v:count)"

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl keywordprg< comments<',
	'delcommand -buffer HelpKeywordPrg',
	'setl tags< tagfunc<'
}, '\n')
