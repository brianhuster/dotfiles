if !has("python3")
	finish
endif

command! -nargs=1 -complete=custom,an#python#ExComplete Py :py3 <args>
