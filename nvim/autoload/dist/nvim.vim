" This function only accept paths that use '/' as separator
func! dist#nvim#JoinPath(...)
	let l:paths = a:000
	let l:result = l:paths[0]

	for l:path in l:paths[1:]
		for v in split(l:path, '/')
			if v == '..'
                let l:result = fnamemodify(l:result, ':h')
			elseif v != '.'
				let l:result .= '/' . v
			endif
		endfor
	endfor

	return l:result
endf
