syn match Directory "\%(\S\+ \)*\S\+/\ze\%(\s\{2,}\|$\)"
exe "syntax match BufName" '"^'.fnameescape(expand('%')).'"' 'conceal'

hi link Directory Directory
hi link BufName Conceal
