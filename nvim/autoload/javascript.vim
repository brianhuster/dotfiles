func! javascript#IncludeExpr(module_name)
	let l:dir = expand('%:p:h')
	" @See https://bun.sh/docs/runtime/modules
	let l:extensions = ['', '.tsx', '.jsx', '.ts', '.mjs', '.js', '.cjs', '.json', '/index.tsx', '/index.jsx', '/index.ts', '/index.mjs', '/index.js', '/index.cjs', '/index.json']
	if isabsolutepath(a:module_name) && filereadable(a:module_name)
		return a:module_name
	endif
	if a:module_name[:1] == './' || a:module_name[:2] == '../'
		let l:fname = dist#nvim#JoinPath(l:dir, a:module_name)
		for l:ext in l:extensions
			let l:result = l:fname . l:ext
			if filereadable(l:result)
				return l:result
			endif
		endfor
	endif

	if exists('g:javascript_node_modules') && g:javascript_node_modules
		let l:node_module = dist#nvim#JoinPath('node_modules', a:module_name)
		while l:dir !=# fnamemodify(l:dir, ':h')
			let l:fname = dist#nvim#JoinPath(l:dir, l:node_module)
			for l:ext in l:extensions
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
