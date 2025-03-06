if $SHELL ==# exepath('fish')
	setl keywordprg=help
	let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) ==# v:t_string ? b:undo_ftplugin : ''
		\ . '\n setl keywordprg<'
endif
