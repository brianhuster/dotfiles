"silent language vi_vn.utf-8
set mouse=nvc
set number
set noexpandtab
set autoindent
set cindent
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
set completeopt=menuone,noselect,fuzzy,preview,popup
set dictionary=/usr/share/dict/words
set noswapfile
set foldmethod=expr
set nofoldenable
set smoothscroll
set wildmode=noselect:full
set confirm
set spelloptions=camel
set spelllang=en
set spell

au InsertLeavePre,TextChanged,TextChangedP * if &modifiable && !&readonly | silent! write | endif
au FocusGained,BufEnter * checktime

au BufEnter * if &buftype == 'terminal' | startinsert | setl winheight=12 | setl nospell |else | setl winheight=100 | endif
au BufEnter *.png,*.jpg,*.jpeg,*.gif,*.webp call s:OpenImgBuf(expand('<amatch>'))

" Key mappings
nnoremap t <cmd>call Terminal()<CR>
xnoremap t <cmd>call Terminal()<CR>
tnoremap <Esc> <C-\><C-n>

nnoremap <BS> "_d
xnoremap <BS> "_d
nnoremap <BS><BS> "_dd
xnoremap <BS><BS> "_dd
nnoremap <Del> "_D
xnoremap <Del> "_D

inoremap <C-b> <cmd>normal! ^<CR>
inoremap <C-e> <cmd>normal! $<CR>

map <MiddleMouse> <Nop>
map <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>
imap <2-MiddleMouse> <Nop>
imap <3-MiddleMouse> <Nop>
imap <4-MiddleMouse> <Nop>

tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

tnoremap <A-Up> <C-\><C-N><C-w>k
tnoremap <A-Down> <C-\><C-N><C-w>j
tnoremap <A-Left> <C-\><C-N><C-w>h
tnoremap <A-Right> <C-\><C-N><C-w>l
inoremap <A-Up> <C-\><C-N><C-w>k
inoremap <A-Down> <C-\><C-N><C-w>j
inoremap <A-Left> <C-\><C-N><C-w>h
inoremap <A-Right> <C-\><C-N><C-w>l
nnoremap <A-Up> <C-w>k
nnoremap <A-Down> <C-w>j
nnoremap <A-Left> <C-w>h
nnoremap <A-Right> <C-w>l

tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

nnoremap <C-k> K

cnoremap <expr> <Left> pumvisible() ? '<C-e><Left>' : '<Left>'
cnoremap <expr> <Right> pumvisible() ? '<C-e><Right>' : '<Right>'
cnoremap <expr> <Up> pumvisible() ? '<C-b><Up>' : '<Up>'
cnoremap <expr> <Down> pumvisible() ? '<C-b><Down>' : '<Down>'

let did_install_default_menus = 1
let did_install_syntax_menu = 1
let g:loaded_perl_provider = 1

autocmd QuickFixCmdPost [^l]* cwindow
autocmd QuickFixCmdPost l* lwindow

func! s:OpenImgBuf(file) abort
	term imgcat %
	exe 'bwipeout!' a:file
	exe 'file' a:file
endfunc

function! Terminal()
	if &buftype == 'terminal'
		startinsert
		return
	endif
	let term_win = -1
	for win in range(1, winnr('$'))
		let buftype = getbufvar(winbufnr(win), '&buftype')
		if buftype == 'terminal'
			let term_win = win
			break
		endif
	endfor
	if term_win == -1
		belowright split | terminal
	else
		execute term_win . 'wincmd w'
		if has('nvim')
			call nvim_win_set_height(win_getid(term_win), 12)
		endif
	endif
endfunction

function! s:IbusOff()
	let g:ibus_prev_engine = trim(system('ibus engine'))
	execute 'silent !ibus engine xkb:us::eng'
endfunction

function! s:IbusOn()
	let l:current_engine = trim(system('ibus engine'))
	if l:current_engine !~? 'xkb:us::eng'
		let g:ibus_prev_engine = l:current_engine
	endif
	execute 'silent !' . 'ibus engine ' . g:ibus_prev_engine
endfunction

if executable('ibus')
	augroup IBusHandler
		autocmd InsertEnter * call s:IbusOn()
		autocmd InsertLeave * call s:IbusOff()
		autocmd FocusGained * call s:IbusOn()
		autocmd FocusLost * call s:IbusOff()
		autocmd ExitPre * call s:IbusOn()
	augroup END
	call s:IbusOff()
else
	echoerr "ibus is not installed. Switch to keymap vietnamese-telex_utf-8."
	set keymap=vietnamese-telex_utf-8
endif

if has('nvim')
	if &grepprg[:2] == 'rg '
		"let &grepprg .= '--max-columns=100 '
		let &grepprg .= '-j1 '
	endif
	set foldexpr=v:lua.vim.treesitter.foldexpr()
	set exrc

	au TermOpen * setl nonumber norelativenumber | startinsert

	lua if vim.loader then vim.loader.enable() end
	au FileType * lua pcall(vim.treesitter.start)
endif
