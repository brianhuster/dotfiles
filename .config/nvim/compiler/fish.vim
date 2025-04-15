if exists('current_compiler')
    finish
endif
let current_compiler = 'fish'

CompilerSet makeprg=fish\ --no-execute\ %
exe 'CompilerSet errorformat='..escape('%Afish: %m,%-G%*\\ ^,%-Z%f (line %l):%s', ' ')
