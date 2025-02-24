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
