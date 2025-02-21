let &l:include = '\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+'
setlocal includeexpr=LuaInclude(v:fname)

func! LuaInclude(fname) abort
	let lua_ver = str2float(printf("%d.%02d", g:lua_version, g:lua_subversion))
	let fname = tr(a:fname, '.', '/')
	let paths = lua_ver >= 5.03 ?  [ fname.'.lua', fname.'/init.lua' ] : [ fname.'.lua' ]
	for path in paths
		if filereadable(path)
			return path
		endif
	endfor
	return fname
endfunc
