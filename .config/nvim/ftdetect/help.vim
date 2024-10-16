au BufRead,BufNewFile **/doc/*.txt if getline('$') =~ 'ft=help' | setfiletype help | endif
