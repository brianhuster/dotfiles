function! s:GetPassword() abort
    let l:pswd = inputsecret($"[sudo.vim] password for {$USER}: ")

    let l:result = system('sudo -S -k -v', l:pswd)
    let l:code = v:shell_error

    if l:code == 0
        return l:pswd
    else
        return v:null
    endif
endfunction

function! s:Exec(line1, line2, range, args) abort
    let l:pswd = v:null
    for l:_ in range(3)
        let l:pswd = s:GetPassword()
        if l:pswd isnot v:null
            break
        else
            echoerr 'Sorry, try again.'
        endif
    endfor

    if l:pswd is v:null
        echo "sudo.vim: 3 incorrect password attempts"
        return
    endif

    " Build stdin: password first, then selected lines (if range given)
    let l:stdin = l:pswd . "\n"
    if a:range > 0
        let l:lines = getline(a:line1, a:line2)
        let l:stdin .= join(l:lines, "\n") . "\n"
    endif

	let l:output = system('sudo -S -k -p "" ' .. expandcmd(a:args), l:stdin)

	if v:shell_error == 0
		echo l:output
	else
		echoerr l:output
	endif

    checktime
	return l:output
endfunction

command! -nargs=+ -complete=shellcmdline -range Sudo call s:Exec(<line1>, <line2>, <range>, <q-args>)
