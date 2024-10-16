let &l:iskeyword = '!-~,^*,^|,^",192-255'
" @type string
let s:tags_files = globpath(&rtp, 'doc/tags', 0, 1, 1)
	\ ->extend(globpath(&packpath, '*/start/doc/tags', 0, 1, 1))
	\ ->map({ k, v -> escape(v, ', \') })
	\ ->join(',')
exe 'setl tags+=' .. s:tags_files

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
	\ . '\n setl ofu< isk< tags< tagfunc<'
