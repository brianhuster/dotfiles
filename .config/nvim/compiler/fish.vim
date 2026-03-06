" This is not very useful right now because fish doesn't document its error
" format. In fact the errorformat used in this script is no longer true
if exists('current_compiler')
    finish
endif
let current_compiler = 'fish'

CompilerSet makeprg=fish\ --no-execute\ %
exe 'CompilerSet errorformat='..escape('%Afish: %m,%-G%*\\ ^,%-Z%f (line %l):%s', ' ')
