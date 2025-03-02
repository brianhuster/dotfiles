let l:&commentstring='// %s'

let b:undo_ftplugin = join([ exists(b:undo_ftplugin) && type(b:undo_ftplugin) ==# v:tstring ? b:undo_ftplugin : '',
			\ 'setl commentstring'], '\n')
