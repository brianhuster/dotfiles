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

let g:python3_host_prog = 'python3'

if has('nvim')
	call execute('set rtp^=' . stdpath('config'))
	set foldexpr=v:lua.vim.treesitter.foldexpr()
	set omnifunc=v:lua.vim.treesitter.query.omnifunc
endif

" au InsertLeavePre,TextChanged,TextChangedP * if &modifiable | silent! write | endif
autocmd! FocusGained,BufEnter * checktime

" Key mappings
nnoremap t :call Terminal()<CR>
xnoremap t :call Terminal()<CR>
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

cnoremap <C-v> <C-r>+

let did_install_default_menus = 1
let did_install_syntax_menu = 1

" IBus handler
function! IBusOff()
	let g:ibus_prev_engine = trim(system('ibus engine'))
	execute 'silent !ibus engine xkb:us::eng'
endfunction

function! IBusOn()
	let l:current_engine = trim(system('ibus engine'))
	if l:current_engine !~? 'xkb:us::eng'
		let g:ibus_prev_engine = l:current_engine
	endif
	execute 'silent !' . 'ibus engine ' . g:ibus_prev_engine
endfunction

if executable('ibus')
	augroup IBusHandler
		autocmd CmdLineEnter [/?],[s/],[%s/] call IBusOn()
		autocmd CmdLineLeave [/?],[:s/?],[:%s/?] call IBusOff()
		autocmd InsertEnter * call IBusOn()
		autocmd InsertLeave * call IBusOff()
		autocmd FocusGained * call IBusOn()
		autocmd FocusLost * call IBusOff()
		autocmd ExitPre * call IBusOn()
	augroup END
	call IBusOff()
else
	echoerr "ibus is not installed. Switch to keymap vietnamese-telex_utf-8."
	set keymap=vietnamese-telex_utf-8
endif

function! Terminal()
	if &buftype == 'terminal'
		startinsert
		return
	endif
	let term_win = -1
	for win in range(1, winnr('$'))
		execute win . 'wincmd w'
		if &buftype == 'terminal'
			let term_win = win
			break
		endif
	endfor
	if term_win == -1
		belowright split | terminal
		setlocal nonumber
		set winheight=12
	else
		execute term_win . 'wincmd w'
	endif
	startinsert
endfunction

" Auto completion in insert mode
function! InsAutocomplete() abort
	if pumvisible() || state("m") == "m" || &l:omnifunc == 'v:lua.vim.lsp.omnifunc'
		return
	endif
	let l:completion_keymap = &omnifunc != '' ? "\<C-x>\<C-o>" : "\<C-x>\<C-n>"
	if exists('b:completion_keymap')
		let l:completion_keymap = b:completion_keymap
	end
	if exists('b:completion_triggers')
		if index(b:completion_triggers, v:char) == -1
			return
		end
	endif
	call feedkeys(l:completion_keymap, "m")
endfunction

if !has('nvim-0.11')
	autocmd! InsertCharPre <buffer> call InsAutocomplete()
endif

if has('nvim')
	set exrc
	au BufRead */doc/*.txt setlocal ft=help
	source <script>:p:h/nvim.lua
endif
