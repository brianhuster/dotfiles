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
			candidate = completer.complete(text, i)
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
	echomsg a:CmdLine
	return py3eval('ex_python_complete()')
endfunction

function! s:ExPy(src) abort
	let src = a:src
	if src[0] == '='
		let src = 'print(' . src[1:] . ')'
	endif
	exe 'python3' src
endfunction

if !has("nvim")
	command! -nargs=1 -complete=custom,s:ExPyComplete Py :call s:ExPy(<q-args>)
else
	lua << EOF
	vim.api.nvim_create_user_command('Py', function(opts)
		if opts.line1 and opts.line2 then
			local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
			opts.args = vim.text.indent(table.concat(lines, "\n"), 0)
		end
		vim.call('s:ExPy', opts.args)
	end, { nargs = 1, complete = "custom,s:ExPyComplete", range = true })
EOF
endif
