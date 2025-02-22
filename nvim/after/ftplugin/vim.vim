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

lua << EOF
vim.api.nvim_create_autocmd('LspAttach', {
	buffer = 0,
	callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        if client:supports_method('textDocument/hover') then
            vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, {buffer = 0})
        end
	end
})
EOF
