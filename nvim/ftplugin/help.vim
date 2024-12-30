setlocal ts=8
if has('vim9script')
	import "./txt.vim"
elseif has('nvim')
	call execute('source ' . stdpath('config') . '/ftplugin/txt.vim')
end
