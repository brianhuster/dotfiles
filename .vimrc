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

" Terminal keybindings
nnoremap t :call Terminal()<CR>
xnoremap t :call Terminal()<CR>
tnoremap <Esc> <C-\><C-n>

" Delete selected text without copying it
nnoremap <BS> "_d
xnoremap <BS> "_d

" Delete a line without copying it
nnoremap <BS><BS> "_dd
xnoremap <BS><BS> "_dd

" Delete until the end of the line without copying it
nnoremap <Del> "_D

luafile ~/.config/nvim/lua/settings.lua

augroup BufEnterHandler
  autocmd!
  autocmd BufEnter * call s:BufEnterHandler()
augroup END

function! s:BufEnterHandler()
  if &buftype == 'terminal'
    setlocal nonumber
    set winheight=12
  elseif &buftype == 'nofile'
    call feedkeys(escape('<Esc>', '\'), 'n')
  else
    set winheight=100
  endif
endfunction

if executable('ibus') == 0
  finish
endif

function! CurrentIbusEngine()
  let output = systemlist('ibus engine')
  return output[0]
endfunction

function! IBusOff()
  let g:ibus_prev_engine = CurrentIbusEngine()
  call system('ibus engine xkb:us::eng')
endfunction

function! IBusOn()
  let current_engine = CurrentIbusEngine()
  if current_engine !~ 'xkb:us::eng'
    let g:ibus_prev_engine = current_engine
  endif
  call system('ibus engine ' . trim(g:ibus_prev_engine))
endfunction

augroup IBusHandler
  autocmd!
  autocmd CmdlineEnter [/?] call IBusOn()
  autocmd CmdlineLeave [/?] call IBusOff()
  autocmd InsertEnter * call IBusOn()
  autocmd InsertLeave * call IBusOff()
  autocmd ExitPre * call IBusOn()
augroup END

call IBusOff()
