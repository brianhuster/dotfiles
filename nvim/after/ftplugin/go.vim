setl keywordprg=:GoKeywordPrg
setl formatprg=gofmt

command! -buffer -nargs=* GoKeywordPrg call s:GoKeywordPrg()

nnoremap K <cmd>lua vim.lsp.buf.hover()<CR>

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) ==# v:t_string ? b:undo_ftplugin : ''
	\ .. '\n setl isk< fp< kp<'
	\ .. '\n delcommand -buffer GoKeywordPrg'

if !exists('*' .. expand('<SID>') .. 'GoKeywordPrg')
	func! s:GoKeywordPrg()
		let temp_isk = &l:iskeyword
		setl iskeyword+=.
		try
			let cmd = 'go doc -C ' . shellescape(expand('%:h')) . ' ' . shellescape(expand('<cword>'))
			if has('gui_running') || has('nvim')
				exe 'Sh' cmd
			else
				exe '!'..cmd
			endif
		finally
			let &l:iskeyword = temp_isk
		endtry
	endfunc
endif
