function! s:Help(args)
	let syn_name = synIDattr(synID(line('.'), col('.'), 1), 'name')

	if syn_name =~# 'vimCommand'
		execute 'help' a:args..':'
	elseif syn_name =~# 'vimOption'
		execute 'help' "'"..a:args.."'"
	elseif syn_name =~# 'vimFunc'
		execute 'help' a:args..'()'
	else
		execute 'help' a:args
	endif
endfunction

if maparg('K', 'n') == ''
	nnoremap K <cmd>call <sid>Help(expand('<cword>'))<CR>
endif
