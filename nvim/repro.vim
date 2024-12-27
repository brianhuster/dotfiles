" repro.vim
let s:triggers = [ "." ]

function! s:insAutocomplete() abort
	if pumvisible() == 1 || state("m") == "m"
		return
	endif
	let char = v:char
	if index(s:triggers, char) != -1
		call nvim_feedkeys(v:lua.vim.keycode('<C-x><C-n>'), "m", v:false)
	endif
endfunction

call nvim_create_autocmd('InsertCharPre', {
      \ 'buffer': nvim_get_current_buf(),
      \ 'callback': 'Autocomplete',
      \ })

