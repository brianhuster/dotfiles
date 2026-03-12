setl iskeyword+=.,-
let &l:define = '\v^\s*function>'
setl suffixesadd+=.fish

let b:match_words =
	\ '\<\%(else\s\+\)\@<!if\>:\<else\%(\s\+if\)\?\>:\<end\>,' .
	\ '\<switch\>:\<case\>:\<end\>,' .
	\ '\<\(begin\|function\|while\|for\)\>:\<end\>'

if !exists('s:UndoFtplugin')
	function! s:UndoFtplugin() abort
		setl define< include< iskeyword< suffixesadd< formatprg< omnifunc< path< keywordprg< suffixesadd<
	endfunction
endif

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
	\ . $'| call {expand("<sid>")}UndoFtplugin()'

if !executable('fish')
	finish
endif

setl formatprg=fish_indent
setl omnifunc=s:Complete

" https://github.com/dag/vim-fish just split by space, but a path could
" contains space
for path in systemlist("fish", 'string join \n $fish_function_path')
	exe 'setl path+=' . path->escape(' \')
endfor

setl keywordprg=:FishMan

command! -buffer -nargs=1 FishMan :execute '!fish -c' shellescape("man " .. <q-args>)

if !exists('s:Complete')
	func s:Complete(findstart, base)
		if a:findstart
			return getline('.') =~# '\v^\s*$' ? -1 : 0
		endif
		if empty(a:base)
			return []
		endif
		let cmd = substitute(a:base, '\v\S+$', '', '')
		return an#fish#Complete(a:base)->map({ _, item -> #{word: cmd..item.word, abbr: item.word, menu: item.desc} })
	endfunc
endif
