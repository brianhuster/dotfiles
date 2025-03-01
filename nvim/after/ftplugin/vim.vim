if !exists("*" .. expand("<SID>") .. "Help")
	function s:Help(topic) abort
		let topic = a:topic

		if get(g:, 'syntax_on', 0)
			let syn = synIDattr(synID(line('.'), col('.'), 1), 'name')
			if syn ==# 'vimFuncName'
				return topic.'()'
			elseif syn ==# 'vimOption'
				return "'".topic."'"
			elseif syn ==# 'vimUserAttrbKey'
				return ':command-'.topic
			elseif syn =~# 'vimCommand'
				return ':'.topic
			endif
		endif

		let col = col('.') - 1
		while col && getline('.')[col] =~# '\k'
			let col -= 1
		endwhile
		let pre = col == 0 ? '' : getline('.')[0 : col]

		let col = col('.') - 1
		while col && getline('.')[col] =~# '\k'
			let col += 1
		endwhile
		let post = getline('.')[col : -1]

		if pre =~# '^\s*:\=$'
			return ':'.topic
		elseif pre =~# '\<v:$'
			return 'v:'.topic
		elseif pre =~# '\\$'
			return '/\'.topic
		elseif topic ==# 'v' && post =~# ':\w\+'
			return 'v'.matchstr(post, ':\w\+')
		else
			return topic
		endif
	endfunction
endif
command! -buffer -nargs=1 VimKeywordPrg :exe 'help' s:Help(<q-args>)
setlocal keywordprg=:VimKeywordPrg
