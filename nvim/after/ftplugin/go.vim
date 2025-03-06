setl iskeyword+=.
setl keywordprg=go\ doc
setl formatprg=gofmt

nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) ==# v:t_string ? b:undo_ftplugin : ''
	\ .. '\n setl isk< fp< kp<'
