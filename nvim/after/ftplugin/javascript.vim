set isfname+=@-@

" @see https://bun.sh/docs/runtime/modules
" I removed `.jsm`, `.es`, `.es6` because they are not popular, not
" standardized, no JS runtime can automatically find them, they also have no
" build tools. If users want to use those filetypes, they should write module
" name with those extensions (for example `import './foo.jsm';`).

let s:suffixes = [ '.tsx', '.jsx', '.ts', '.d.ts', '.vue', '.mjs', '.js', '.cjs', '.json', '/index.tsx', '/index.jsx', '/index.ts', '/index.d.ts', '/index.vue', '/index.mjs', '/index.js', '/index.cjs', '/index.json' ]
let &l:suffixesadd = join(s:suffixes, ',')

setlocal include=\v<(require\([''"]|import\s+[''"]|from\s+[''"])\zs[^''"]+
setlocal includeexpr=s:IncludeExpr(v:fname)

if !exists('g:javascript_node_modules')
	let g:javascript_node_modules = v:false
endif

func! s:IncludeExpr(module_name) abort
	if !exists('g:javascript_node_modules') || !g:javascript_node_modules
		return a:module_name
	endif
	let path = resolve(expand('%:p'))
	while path !=# fnamemodify(path, ':h')
		let node_module = 'node_modules/' . a:module_name
		let path = fnamemodify(path, ':h')
		let package_json = path . '/package.json'
		if filereadable(package_json)
			let package = json_decode(join(readfile(package_json), ''))
			if has_key(package, 'main')
				let node_module ..= '/' . package.main
			endif
		endif
		let fname = resolve(path . '/' . node_module)
		for suf in s:suffixes
			let result = fname . suf
			if filereadable(result)
				return result
			endif
		endfor
	endwhile
	return a:module_name
endfunc

let g:javascript_node_modules = 1
