function! an#fish#Complete(string) abort
	return systemlist('fish 2> /dev/null', 'complete -C ' . shellescape(a:string))
		\ ->map({ _, line -> split(line, '\t') })
		\ ->map({ _, tokens -> #{word: tokens[0], desc: get(tokens, 1, '')} })
endfunction
