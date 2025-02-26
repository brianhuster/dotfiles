"silent language vi_vn.utf-8

set mouse=nvc
set number
set noexpandtab
set autoindent
set smartindent
set nocursorline
set shiftwidth=4
set tabstop=4
set clipboard=unnamedplus
set autowriteall
set nomodeline
set backspace=indent,eol,start
set backupcopy=yes
let g:mapleader=" "
set messagesopt=hit-enter,wait:5000,history:10000
set completeopt=menuone,noinsert,fuzzy,noselect,preview,popup
set dictionary=/usr/share/dict/words
set noswapfile
set foldmethod=expr
set nofoldenable

let g:python3_host_prog = 'python3'

au! InsertLeavePre,TextChanged,TextChangedP * if &modifiable && !&readonly | silent! write | endif
autocmd! FocusGained,BufEnter * checktime

" Key mappings
nnoremap t <cmd>call an#Terminal()<CR>
xnoremap t <cmd>call an#Terminal()<CR>
tnoremap <Esc> <C-\><C-n>

nnoremap <BS> "_d
xnoremap <BS> "_d
nnoremap <BS><BS> "_dd
xnoremap <BS><BS> "_dd
nnoremap <Del> "_D
xnoremap <Del> "_D

map <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>

exe 'cnoremap' '<C-v>' '<C-r>'.v:register
nnoremap <Leader>g :<C-u>grep<Space>
nnoremap <C-k> K

let did_install_default_menus = 1
let did_install_syntax_menu = 1

function! IbusOff()
	let g:ibus_prev_engine = trim(system('ibus engine'))
	execute 'silent !ibus engine xkb:us::eng'
endfunction

function! IbusOn()
	let l:current_engine = trim(system('ibus engine'))
	if l:current_engine !~? 'xkb:us::eng'
		let g:ibus_prev_engine = l:current_engine
	endif
	execute 'silent !' . 'ibus engine ' . g:ibus_prev_engine
endfunction

if executable('ibus')
	augroup IBusHandler
		autocmd CmdLineEnter [/?],[s/],[%s/] call IbusOn()
		autocmd CmdLineLeave [/?],[:s/?],[:%s/?] call IbusOff()
		autocmd InsertEnter * call IbusOn()
		autocmd InsertLeave * call IbusOff()
		autocmd FocusGained * call IbusOn()
		autocmd FocusLost * call IbusOff()
		autocmd ExitPre * call IbusOn()
	augroup END
	call IbusOff()
else
	echoerr "ibus is not installed. Switch to keymap vietnamese-telex_utf-8."
	set keymap=vietnamese-telex_utf-8
endif

if has('nvim')
	call execute('set rtp^=' . stdpath('config'))
	set foldexpr=v:lua.vim.treesitter.foldexpr()
	set exrc
	let g:loaded_perl_provider = 1
endif
