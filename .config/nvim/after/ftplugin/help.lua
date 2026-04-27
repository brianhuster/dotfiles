vim.cmd [[
	let s:tags_files = globpath(&rtp, 'doc/tags', 0, 1, 1)
		\ ->extend(globpath(&packpath, '*/start/doc/tags', 0, 1, 1))
		\ ->map({ k, v -> escape(v, ', \') })
		\ ->join(',')
	exe 'setl tags+=' .. s:tags_files

func s:HelpComplete(findstart, base)
	if a:findstart
		let colnr = col('.') - 1 " Get the column number before the cursor
		let line = getline('.')
		for i in range(colnr - 1, 0, -1)
			if line[i] ==# '|'
				return i + 1 " Don't include the `|` in base
			elseif line[i] ==# "'"
				return i " Include the `'` in base
			endif
		endfor
	else
		return taglist('^' .. a:base)
				\ ->map({_, item -> #{word: item->get('name'), kind: item->get('kind')}})
				\ ->extend(getcompletion(a:base, 'help'))
	endif
endfunc

setl omnifunc=s:HelpComplete
]]

vim.bo.comments = ''
vim.bo.formatexpr = "v:lua.require'an.help'.formatexpr(v:lnum, v:count)"

vim.b.undo_ftplugin = table.concat({
	vim.b.undo_ftplugin or '',
	'setl keywordprg< comments<',
	'delcommand -buffer HelpKeywordPrg',
	'setl tags< tagfunc<'
}, '\n')
