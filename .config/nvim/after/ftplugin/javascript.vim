set isfname+=@-@
let g:javascript_node_modules = 1

" @see https://bun.sh/docs/runtime/modules
" I removed `.jsm`, `.es`, `.es6` because they are not popular, not
" standardized, no JS runtime can automatically find them, they also have no
" build tools. If users want to use those filetypes, they should write module
" name with those extensions (for example `import './foo.jsm';`).
let s:suffixes = [ '.tsx', '.jsx', '.ts', '.d.ts', '.vue', '.mjs', '.js', '.cjs', '.json']
let s:indexsuffixes = map(copy(s:suffixes), { i, v -> "/index"..v })
let s:suffixes = extend(s:suffixes, s:indexsuffixes)

let &l:suffixesadd = join(s:suffixes, ',')

setlocal include=\v<(require\([''"]|import\s+[''"]|from\s+[''"])\zs[^''"]+
setlocal includeexpr=s:IncludeExpr(v:fname)
setl path=

if !exists('g:javascript_node_modules')
	let g:javascript_node_modules = v:false
endif

" Get path to main file of a directory, based on package.json
" @param dir string
" @return string
func! s:package_json_main(dir)
	let package_json = a:dir . '/package.json'
	echo package_json
    if filereadable(package_json)
        let package = json_decode(join(readfile(package_json), ''))
        if has_key(package, 'main')
            return a:dir . '/' . package.main
        endif
    endif
    return a:dir
endfunc

" @param module_name string
" @return string
func! s:IncludeExpr(module_name) abort
	for suf in s:suffixes
		let result = a:module_name . suf
		if filereadable(result)
			return result
		endif
	endfor
	if !exists('g:javascript_node_modules') || !g:javascript_node_modules
		return a:module_name
	endif

	if a:module_name[:1] ==# './' || a:module_name[:2] ==# '../'
		let dir = resolve(expand('%:p:h') . '/' . a:module_name)
		return s:package_json_main(dir)
	endif
	" If module file is in `node_modules`
	let path = resolve(expand('%:p'))
	while path !=# fnamemodify(path, ':h')
		let node_module = 'node_modules/' . a:module_name
		let path = fnamemodify(path, ':h')
		let fname = resolve(s:package_json_main(path . '/' . node_module))
		if filereadable(fname)
			return fname
		endif
		for suf in s:suffixes
			let result = fname . suf
			if filereadable(result)
				return result
			endif
		endfor
	endwhile
	return a:module_name
endfunc
