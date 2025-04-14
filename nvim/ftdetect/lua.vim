au BufRead,BufNewFile * if getline(1) =~ '^#!.*nvim -l' | setfiletype lua | endif
