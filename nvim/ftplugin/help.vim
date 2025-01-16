setlocal ts=8
if has('vim9script')
	import "./txt.vim"
elseif has('nvim')
	exe 'so' stdpath('config') .. '/ftplugin/txt.vim'
end
