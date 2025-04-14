au BufRead,BufNewFile **/doc/*.txt if getline(1) =~ '^#!.*nvim -l' | setfiletype help | endif
