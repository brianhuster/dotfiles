"silent language vi_vn.utf-8
set mouse=nvc
set number relativenumber
set autoindent cindent
set shiftwidth=4 tabstop=4 noexpandtab
set autowriteall
set cursorline
set backspace=indent,eol,start
set backupcopy=yes
set ignorecase smartcase
let g:mapleader=" "
let g:vim_indent_cont = shiftwidth() " Continuational line indentation in Vimscript file
set messagesopt=hit-enter,wait:5000,history:10000
set completeopt=menuone,noselect,preview,popup
set noswapfile
set foldmethod=expr nofoldenable
set smoothscroll
set wildmode=noselect:full
set confirm
set scrolloff=10
set spell spelllang=en spelloptions+=camel
let &spellfile = fnamemodify($MYVIMRC, ':p:h') . '/spell/en.utf-8.add'
let &statusline = "%<%f %h%w%m%r " .
	\ "%=%{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}" .
	\ "%{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}" .
	\ "%{% &ruler ? ( &rulerformat == '' ? '%-15.(%l,%c%V%) %P' : &rulerformat ) : '' %}"

if has('nvim')
	let &statusline .= '%{%v:lua.vim.lsp.status()%}'
endif

au InsertLeavePre,TextChanged,TextChangedP * if &modifiable && !&readonly | silent! write | endif
au FocusGained,BufEnter * checktime

au BufEnter * if &buftype == 'terminal' | startinsert | setl nospell | endif
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
inoremap <C-e> <End>
inoremap <C-Space> <C-x><C-o>

for num in [ '', '2-', '3-', '4-' ]
	exe $"map <{num}MiddleMouse> <Nop>"
	exe $"imap <{num}MiddleMouse> <Nop>"
endfor

for mode in [ 'n', 't', 'i' ]
	for direction in [ 'h', 'j', 'k', 'l' ]
		exe $"{mode}noremap <A-{direction}> <C-\\><C-n><C-w>{direction}"
		exe $"{mode}noremap <A-{direction}> <C-\\><C-n><C-w>{direction}"
	endfor
endfor

tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

nnoremap <C-k> K

cnoremap <expr> <Left> pumvisible() ? '<C-e><Left>' : '<Left>'
cnoremap <expr> <Right> pumvisible() ? '<C-e><Right>' : '<Right>'
cnoremap <expr> <Up> pumvisible() ? '<C-b><Up>' : '<Up>'
cnoremap <expr> <Down> pumvisible() ? '<C-b><Down>' : '<Down>'

let did_install_default_menus = 1
let did_install_syntax_menu = 1
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0

autocmd QuickFixCmdPost [^l]* cwindow
autocmd QuickFixCmdPost l* lwindow

" Make sure that yank operations are also saved to register 1 - 9 instead of
" just 0 like default.
function! s:YankShift()
  for i in range(9, 1, -1)
    call setreg(i, getreg(i - 1))
  endfor
endfunction

au TextYankPost * if v:event.operator == 'y' | call s:YankShift() | endif

let s:scripts_dir = expand('<sfile>:p:h') .. '/scripts'
let $PATH = $"{s:scripts_dir}:{$PATH}"
let $SUDO_ASKPASS = s:scripts_dir .. '/askpass'
command! SudoWrite :silent! w !sudo tee %
command! SudoRead :silent! r !sudo cat %

command! GitBlameLine echo system($"git blame -L {line('.')},+1 {shellescape(expand('%'))}")

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


function! s:ImeOff()
	let s:ibus_prev_engine = trim(system('ibus engine'))
	silent !ibus engine xkb:us::eng
endfunction

function! s:ImeOn()
	let l:current_engine = trim(system('ibus engine'))
	if l:current_engine !~? 'xkb:us::eng'
		let s:ibus_prev_engine = l:current_engine
	endif
	execute 'silent !ibus engine' s:ibus_prev_engine
endfunction

if executable('ibus')
	augroup ibusHandler
		autocmd InsertEnter,ExitPre * call s:ImeOn()
		autocmd InsertLeave * call s:ImeOff()
	augroup END
	call s:ImeOff()
else
	set keymap=vietnamese-telex-user
endif

if has('nvim')
	if &grepprg[:2] == 'rg '
		"let &grepprg .= '--max-columns=100 '
		let &grepprg .= '-j1 '
	endif
	set foldexpr=v:lua.vim.treesitter.foldexpr()
	set exrc
	lua if vim.loader then vim.loader.enable() end

	au UIEnter * set clipboard=unnamedplus
	au TermOpen * setl nonumber norelativenumber | startinsert
	if getfsize($NVIM_LOG_FILE) > pow(1024, 3)
		call delete($NVIM_LOG_FILE)
	endif
endif

packadd! nohlsearch
