setl omnifunc=s:Complete


let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
			\ . '\n setl omnifunc<'

if !exists('*s:Complete')
	func s:Complete(findstart, base)
		if a:findstart
			let colnr = col('.') - 1 " Get the column number before the cursor
			let line = getline('.')
			for i in range(colnr - 1, 0, -1)
				if line[i] ==# '|'
					return i + 1 " Don't include the '|' in the completion
				elseif line[i] ==# "'"
					return i " Include the ' in the completion
				endif
			endfor
		elseif type(a:base) == v:t_string
			return taglist('^' .. a:base)
				\ ->map({_, item -> #{word: item->get('name'), kind: item->get('kind')}})
				\ ->extend(getcompletion(a:base, 'help'))
		endif
	endfunc
endif
