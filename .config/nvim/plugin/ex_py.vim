let s:SetupDone = 0

if !has('python3')
	finish
endif

function! s:Setup() abort
	python3 << EOF
try:
	import jedi

	def ex_python_complete(arg=None):
		if arg is None:
			arg = vim.eval('a:ArgLead')
		text = arg
		if text.startswith('='):
			text = "print(" + text[1:]

		script = jedi.Interpreter(text, [globals()])
		completions = script.complete()
		return "\n".join(arg + c.complete for c in completions)

except ImportError:
	import rlcompleter

	def ex_python_complete(text=None):
		prefix = ''
		if text is None:
			text = vim.eval('a:ArgLead')
		if text.startswith('='):
			text = text[1:]
			prefix = "="

		completer = rlcompleter.Completer(globals())
		i = 0
		completion = ""
		while True:
			try:
				candidate = completer.complete(text, i)
			except Exception:
				break
			if candidate is None:
				break
			completion += '\n' + prefix + candidate
			i += 1
		return completion.lstrip('\n')
EOF
endfunction

function! s:ExPyComplete(ArgLead, CmdLine, CursorPos) abort
	if !s:SetupDone
		call s:Setup()
		let s:SetupDone = 1
	endif
	return py3eval('ex_python_complete()')
endfunction

function! s:ExPy(src, range, line1, line2) abort
	let src = a:src
	if has("nvim-0.12") && a:range > 0
		let src = getline(a:line1, a:line2)->join("\n")
		let src = v:lua.vim.text.indent(0, lines)
	endif
	if src[0] == '='
		let src = 'print(' . src[1:] . ')'
	endif
	exe 'python3' src
endfunction

command! -nargs=1 -range -complete=custom,s:ExPyComplete Py :call s:ExPy(<q-args>, <range>, <line1>, <line2>)
