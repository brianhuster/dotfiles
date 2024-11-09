lua << EOF
	vim.keymap = {}
	vim.keymap.set = function(mode, key, action, opts)
		if type(action) ~= "string" then
			return
		end
		vim.command(string.format('%snoremap %s %s', mode, key, action))
	end

	if not vim.o then
		--- Credit : SongTianxiang
		vim.o = setmetatable({}, {
			__index = function(_, k)
				local ok, optv = pcall(vim.eval, "&" .. k) -- notice this like
				if not ok then
					return error("Unknown option " .. k)
				end
				return optv
			end,
			__newindex = function(o, k, v)
				local _ = vim.o[k]
				if type(v) == "boolean" then
					k = v and k or "no" .. k
					vim.command('set ' .. k)
					return
				end
				vim.command('set ' .. k .. '=' .. v)
			end,
		})
	end
EOF

luafile ~/.config/nvim/lua/keymaps.lua
luafile ~/.config/nvim/lua/settings.lua

if executable('ibus') == 0
  finish
endif

function! CurrentIbusEngine()
  let output = systemlist('ibus engine')
  return output[0]
endfunction

function! IBusOff()
  let g:ibus_prev_engine = CurrentIbusEngine()
  call system('ibus engine xkb:us::eng')
endfunction

function! IBusOn()
  let current_engine = CurrentIbusEngine()
  if current_engine !~ 'xkb:us::eng'
    let g:ibus_prev_engine = current_engine
  endif
  call system('ibus engine ' . trim(g:ibus_prev_engine))
endfunction

augroup IBusHandler
  autocmd!
  autocmd CmdlineEnter [/?] call IBusOn()
  autocmd CmdlineLeave [/?] call IBusOff()
  autocmd InsertEnter * call IBusOn()
  autocmd InsertLeave * call IBusOff()
  autocmd ExitPre * call IBusOn()
augroup END

call IBusOff()
