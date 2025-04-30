setl omnifunc=s:Complete
let &l:iskeyword = '!-~,^*,^|,^",192-255'
" @type string
let s:tags_files = globpath(&rtp, 'doc/tags', 0, 1, 1)
	\ ->extend(globpath(&packpath, '*/start/doc/tags', 0, 1, 1))
	\ ->map({ k, v -> escape(v, ', \') })
	\ ->join(',')
exe 'setl tags+=' .. s:tags_files

"setl tagfunc=s:Tagfunc

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
	\ . '\n setl ofu< isk< tags< tagfunc<'

if exists('*s:Tagfunc')
	finish
endif

func s:Tagfunc(pattern, flags, info) abort
	let [ pattern, flags, info ] = [ a:pattern, a:flags, a:info ]
	return taglist(pattern)
endfunc

func s:Complete(findstart, base) abort
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
	elseif type(a:base)
		return taglist('^' .. a:base)
			\ ->map({_, item -> #{word: item->get('name'), kind: item->get('kind')}})
			"\ ->extend(getcompletion(a:base, 'help'))
	endif
endfunc
