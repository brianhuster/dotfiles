setl iskeyword+=.,-,/
setl formatprg=fish_indent
setl omnifunc=s:Complete
for path in split(system("fish -c 'echo $fish_function_path'"))
	exe 'setl path+=' . path
endfor

let b:match_words = escape('<%(begin|function|if|switch|while|for)>:<end>', '<>%|)')

let b:undo_ftplugin = exists('b:undo_ftplugin') && type(b:undo_ftplugin) == v:t_string ? b:undo_ftplugin : ''
			\ . '\n setl iskeyword< suffixesadd< formatprg< omnifunc< path<'

if !exists('s:Complete')
	func s:Complete(findstart, base)
		if a:findstart
			return getline('.') =~# '\v^\s*$' ? -1 : 0
		else
			if empty(a:base)
				return []
			endif
			let results = []
			let completions = system(['fish', '--no-config', '-c', 'complete -C '.shellescape(a:base)])
			let cmd = substitute(a:base, '\v\S+$', '', '')
			for line in split(completions, '\n')
				let tokens = split(line, '\t')
				call add(results, #{word: cmd..tokens[0], abbr: tokens[0], menu: get(tokens, 1, '')})
			endfor
			return results
		endif
	endfunc
endif
