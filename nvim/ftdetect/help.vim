au BufRead,BufNewFile */doc/*.txt if match(getline('$'), 'ft=help') > -1 | setl ft=help | endif
