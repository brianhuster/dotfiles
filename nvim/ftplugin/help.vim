setlocal ts=8
if has('vim9script')
	import "./markdown.vim"
elseif has('nvim')
	call execute('source ' . stdpath('config') . '/ftplugin/markdown.vim')
end
