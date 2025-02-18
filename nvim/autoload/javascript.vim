func! javascript#IncludeExpr(module_name)
	let l:dir = expand('%:p:h')

	if exists('g:javascript_node_modules') && g:javascript_node_modules
		let l:node_module = dist#nvim#JoinPath('node_modules', a:module_name)
		while l:dir !=# fnamemodify(l:dir, ':h')
			let l:fname = dist#nvim#JoinPath(l:dir, l:node_module)
			for l:ext in split(&suffixesadd, ',')
				let l:result = l:fname . l:ext
	               if filereadable(l:result)
	               	return l:result
	               endif
			endfor
			let l:dir = fnamemodify(l:dir, ':h')
		endwhile
	endif
	return a:module_name
endfunc
