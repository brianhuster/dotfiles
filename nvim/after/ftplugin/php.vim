let l:&commentstring='// %s'

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) ==# v:tstring ? b:undo_ftplugin : ''
	\ .. '\n setl commentstring<'
