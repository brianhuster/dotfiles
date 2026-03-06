setl iskeyword+=.,-,/
setl formatprg=fish_indent
setl omnifunc=s:Complete
setl define=\\v^\\s*function>
setl suffixesadd+=.fish

for path in system("fish", "echo $fish_function_path")->split()
	exe 'setl path+=' . path
endfor

let b:match_words = escape('<%(begin|function|if|switch|while|for)>:<end>', '<>%|)')

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
			\ . '\n setl define< include< iskeyword< suffixesadd< formatprg< omnifunc< path< keywordprg< suffixesadd<'

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
		let results = []
		let completions = systemlist('fish 2> /dev/null', 'complete -C ' . shellescape(a:base))
		let cmd = substitute(a:base, '\v\S+$', '', '')
		for line in completions
			let tokens = split(line, '\t')
			call add(results, #{word: cmd..tokens[0], abbr: tokens[0], menu: get(tokens, 1, '')})
		endfor
		return results
	endfunc
endif
