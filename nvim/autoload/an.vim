function! an#Terminal()
	if &buftype == 'terminal'
		startinsert
		return
	endif
	let term_win = -1
	for win in range(1, winnr('$'))
		execute win . 'wincmd w'
		if &buftype == 'terminal'
			let term_win = win
			break
		endif
	endfor
	if term_win == -1
		belowright split | terminal
		setlocal nonumber
		set winheight=12
	else
		execute term_win . 'wincmd w'
	endif
	startinsert
endfunction

" Auto completion in insert mode
" Can be use in `InsertCharPre` autocmd
" @param shortcut string
" @trigger_chars char[]
function! an#InsAutocomplete(shorcut, trigger_chars) abort
	if pumvisible() || state("m") == "m" || &l:omnifunc == 'v:lua.vim.lsp.omnifunc'
		return
	endif
	if index(a:trigger_chars, v:char) == -1
		return
	end
	call feedkeys(l:completion_keymap, "m")
endfunction
