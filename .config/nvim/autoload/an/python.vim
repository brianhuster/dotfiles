python3 << EOF
is_nvim = int(vim.eval('has("nvim")'))

try:
	import jedi

	def ex_python_complete(arg=None):
		if arg is None:
			arg = vim.eval('a:ArgLead')
		text = arg
		if is_nvim and text.startswith('='):
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
		if is_nvim and text.startswith('='):
			text = text[1:]
			prefix = "="

		completer = rlcompleter.Completer(globals())
		i = 0
		completion = ""
		while True:
			candidate = completer.complete(text, i)
			if candidate is None:
				break
			completion += '\n' + candidate
			i += 1
			return completion.lstrip('\n')
EOF

function! an#python#ExComplete(ArgLead, CmdLine, CursorPos)
	return py3eval('ex_python_complete()')
endfunction
