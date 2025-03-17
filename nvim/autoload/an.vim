vim9script

# Forward declaration for functions used in OpenFloatingPreview
def MakeFloatingPopupSize(contents: list<string>, opts: dict<any>): list<number>
def MakeFloatingPopupOptions(width: number, height: number, opts: dict<any>): dict<any>
def NormalizeMarkdown(contents: list<string>, opts: dict<any>): list<string>
def ClosePreviewAutocmd(events: list<string>, winnr: number, bufnrs: list<number>)

export def OpenFloatingPreview(contents: list<string>, syntax: string = '', opts: dict<any> = {}): list<number>
  # Set defaults
  opts.wrap = get(opts, 'wrap', true)
  opts.focus = get(opts, 'focus', true)
  opts.close_events = get(opts, 'close_events', ['CursorMoved', 'CursorMovedI', 'InsertCharPre'])
  
  var bufnr = bufnr('%')
  var floating_winnr = get(opts, '_update_win', 0)
  
  # Create/get the buffer
  var floating_bufnr: number
  
  if floating_winnr != 0
    floating_bufnr = winbufnr(floating_winnr)
  else
    # Check if this popup is focusable and we need to focus
    if has_key(opts, 'focus_id') && get(opts, 'focusable', true) && opts.focus
      # Go back to previous window if we are in a focusable one
      var current_winnr = win_getid()
      if get(w:, opts.focus_id, 0)
        execute('wincmd p')
        return [bufnr, current_winnr]
      endif
      
      var win = FindWindowByVar(opts.focus_id, bufnr)
      if win != 0 && win_id2win(win) > 0 && pumvisible() == 0
        # Focus and return the existing buf, win
        win_gotoid(win)
        execute('stopinsert')
        return [winbufnr(win), win]
      endif
    endif
    
    # Check if another floating preview already exists for this buffer
    # and close it if needed
    var existing_float = get(b:, 'lsp_floating_preview', 0)
    if existing_float != 0 && win_id2win(existing_float) > 0
      win_close(existing_float, true)
    endif
    
    floating_bufnr = bufadd('')
    bufload(floating_bufnr)
    setbufvar(floating_bufnr, '&buftype', 'nofile')
    setbufvar(floating_bufnr, '&bufhidden', 'hide')
    setbufvar(floating_bufnr, '&swapfile', 0)
  endif

  # Set up the contents, using treesitter for markdown
  var do_stylize = syntax == 'markdown' && get(g:, 'syntax_on', '') != ''

  if do_stylize
    var width = MakeFloatingPopupSize(contents, opts)[0]
    contents = NormalizeMarkdown(contents, {width: width})
  else
    # Clean up input: trim empty lines
    var combined = join(contents, "\n")
    contents = filter(split(combined, "\n"), (_, v) => v !~ '^\s*$')

    if syntax != ''
      setbufvar(floating_bufnr, '&syntax', syntax)
    endif
  endif

  setbufvar(floating_bufnr, '&modifiable', 1)
  
  # Set buffer contents
  deletebufline(floating_bufnr, 1, '$')
  setbufline(floating_bufnr, 1, contents)

  if floating_winnr != 0
    # Update existing window config
    var config = {
      border: get(opts, 'border', 'none'),
      title: get(opts, 'title', '')
    }
    win_set_config(floating_winnr, config)
  else
    # Compute size of float needed to show (wrapped) lines
    if opts.wrap
      opts.wrap_at = get(opts, 'wrap_at', winwidth(0))
    else
      remove(opts, 'wrap_at')
    endif

    var dimensions = MakeFloatingPopupSize(contents, opts)
    var width = dimensions[0]
    var height = dimensions[1]
    var float_option = MakeFloatingPopupOptions(width, height, opts)

    floating_winnr = popup_create(floating_bufnr, float_option)

    # Add close key mapping
    bufmap(floating_bufnr, 'n', 'q', '<cmd>bdelete<cr>', {silent: true, noremap: true, nowait: true})
    
    # Set up auto-close events
    ClosePreviewAutocmd(opts.close_events, floating_winnr, [floating_bufnr, bufnr])

    # Save focus_id
    if has_key(opts, 'focus_id')
      win_execute(floating_winnr, $"let w:{opts.focus_id} = {bufnr}")
    endif
    
    setbufvar(bufnr, 'lsp_floating_preview', floating_winnr)
    call win_execute(floating_winnr, $"let w:lsp_floating_bufnr = {bufnr}")
  endif

  # Create autocmd for cleanup when window is closed
  augroup nvim_closing_floating_preview
    autocmd!
    autocmd WinClosed * if v:event.target->str2nr() == {floating_winnr} | 
      \ let preview_bufnr = getwinvar(v:event.target, 'lsp_floating_bufnr', 0) |
      \ if preview_bufnr != 0 && bufexists(preview_bufnr) && 
      \ getbufvar(preview_bufnr, 'lsp_floating_preview', 0) == {floating_winnr} |
      \ call setbufvar(preview_bufnr, 'lsp_floating_preview', 0) |
      \ endif |
      \ endif
  augroup END

  # Set window options
  call win_execute(floating_winnr, 'setlocal nofoldenable')  # Disable folding
  call win_execute(floating_winnr, $"setlocal wrap={opts.wrap ? 'on' : 'off'}")  # Soft wrapping
  call win_execute(floating_winnr, 'setlocal breakindent')  # Slightly better list presentation
  call win_execute(floating_winnr, 'setlocal smoothscroll')  # Scroll by screen-line

  # Set buffer options
  setbufvar(floating_bufnr, '&modifiable', 0)
  setbufvar(floating_bufnr, '&bufhidden', 'wipe')

  if do_stylize
    call win_execute(floating_winnr, 'setlocal conceallevel=2')
    call win_execute(floating_winnr, 'setlocal concealcursor=n')
    setbufvar(floating_bufnr, '&filetype', 'markdown')
    
    # Start treesitter if available
    if exists('*treesitter#start')
      treesitter#start(floating_bufnr)
    endif
    
    # Adjust window height if needed
    if !has_key(opts, 'height')
      # Implementation would depend on equivalent for nvim_win_text_height
      # This is a placeholder - actual implementation would need custom logic
      var conceal_height = GetConcealed TextHeight(floating_winnr)
      if conceal_height < winheight(win_id2win(floating_winnr))
        win_execute(floating_winnr, $"resize {conceal_height}")
      endif
    endif
  endif

  return [floating_bufnr, floating_winnr]
enddef

# Helper function implementations

def FindWindowByVar(name: string, bufnr: number): number
  for win in getwininfo()
    if win.bufnr == bufnr && get(getwinvar(win.winid, ''), name, 0)
      return win.winid
    endif
  endfor
  return 0
enddef

def MakeFloatingPopupSize(contents: list<string>, opts: dict<any>): list<number>
  # Calculate width and height based on contents
  var max_width = 0
  for line in contents
    var line_width = strdisplaywidth(line)
    if line_width > max_width
      max_width = line_width
    endif
  endfor
  
  var width = min([max_width, get(opts, 'wrap_at', winwidth(0) - 2)])
  
  # Calculate height based on width (accounting for wrapping)
  var height = 0
  for line in contents
    height += 1 + (strdisplaywidth(line) - 1) / width
  endfor
  
  # Apply user limits
  if has_key(opts, 'width') && opts.width > 0
    width = opts.width
  endif
  
  if has_key(opts, 'height') && opts.height > 0
    height = opts.height
  endif
  
  # Add padding for borders if present
  if has_key(opts, 'border') && opts.border != 'none'
    width += 2
    height += 2
  endif
  
  return [width, float2nr(height)]
enddef

def MakeFloatingPopupOptions(width: number, height: number, opts: dict<any>): dict<any>
  # Base popup options
  var options: dict<any> = {
    maxwidth: width,
    minwidth: width,
    maxheight: height,
    minheight: height,
    pos: 'botleft',
    line: 'cursor+1',
    col: 'cursor',
    moved: 'any',
    zindex: 50,
    wrap: opts.wrap,
    bufnr: get(opts, 'bufnr', 0)
  }
  
  # Add border
  if has_key(opts, 'border')
    options.border = opts.border
  endif
  
  # Add title
  if has_key(opts, 'title')
    options.title = opts.title
  endif
  
  # Add positioning overrides
  if has_key(opts, 'offset_x')
    options.col = $"cursor{opts.offset_x >= 0 ? '+' : ''}{opts.offset_x}"
  endif
  
  if has_key(opts, 'offset_y')
    options.line = $"cursor{opts.offset_y >= 0 ? '+' : ''}{opts.offset_y}"
  endif
  
  return options
enddef

def NormalizeMarkdown(contents: list<string>, opts: dict<any>): list<string>
  # Simple markdown normalization for display - this is a placeholder
  # Real implementation would need to handle code blocks, headers, etc.
  var result = []
  
  for line in contents
    # Example: handle code blocks and other markdown syntax as needed
    if stridx(line, '```') == 0
      # Handle code blocks
      add(result, line)
    else
      # Handle line wrapping for regular text
      var wrapped_line = ''
      var width = opts.width
      var chars = split(line, '\zs')
      var col = 0
      
      for char in chars
        if col >= width
          add(result, wrapped_line)
          wrapped_line = ''
          col = 0
        endif
        wrapped_line ..= char
        col += 1
      endfor
      
      if wrapped_line != ''
        add(result, wrapped_line)
      endif
    endif
  endfor
  
  return result
enddef

def ClosePreviewAutocmd(events: list<string>, winnr: number, bufnrs: list<number>)
  var win_str = winnr
  var bufnr_str = join(bufnrs, ',')
  
  augroup floating_windows
    for event in events
      execute('autocmd ' .. event .. ' <buffer=' .. bufnrs[1] .. '> ++nested ++once if &buftype != "prompt" && &filetype !~ "TelescopePrompt" && mode() !~ "c" | silent! execute "' .. win_str .. 'close" | endif')
    endfor
  augroup END
enddef

# Placeholder function for getting text height with concealed elements
def GetConcealed TextHeight(winnr: number): number
  # This would need custom implementation to match nvim_win_text_height functionality
  # Simple approximation:
  return winheight(win_id2win(winnr))
enddef

def bufmap(bufnr: number, mode: string, lhs: string, rhs: string, opts: dict<any>)
  var options = ''
  if get(opts, 'silent', false)
    options ..= '<silent>'
  endif
  if get(opts, 'noremap', false)
    options ..= '<noremap>'
  endif
  if get(opts, 'nowait', false)
    options ..= '<nowait>'
  endif
  
  execute('buffer ' .. bufnr .. ' ' .. mode .. 'map ' .. options .. ' ' .. lhs .. ' ' .. rhs)
enddef
