function! ibus#Off()
	let g:ibus_prev_engine = trim(system('ibus engine'))
	execute 'silent !ibus engine xkb:us::eng'
endfunction

function! ibus#On()
	let l:current_engine = trim(system('ibus engine'))
	if l:current_engine !~? 'xkb:us::eng'
		let g:ibus_prev_engine = l:current_engine
	endif
	execute 'silent !' . 'ibus engine ' . g:ibus_prev_engine
endfunction
