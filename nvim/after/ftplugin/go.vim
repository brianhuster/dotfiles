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
			if has('nvim')
				let prev_buf = bufnr('%')
				let buf = nvim_create_buf(v:false, v:false)
				exe 'buffer' buf | exe "term" cmd | startinsert | normal! gg
				tmap <buffer> <Esc> <Cmd>call jobstop(&channel) <Bar> exe 'buffer' buf <Bar> exe 'bdelete' buf<CR>
			else
				exe '!'..cmd
			endif
		finally
			let &l:iskeyword = temp_isk
		endtry
	endfunc
endif
