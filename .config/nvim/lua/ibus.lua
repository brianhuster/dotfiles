if vim.fn.executable('ibus') == 0 then
	return
end

function IbusGetCurrentEngine()
	local handle = io.popen('ibus engine')
	local result
	if handle then
		result = handle:read("*a")
		handle:close()
	end
	return result
end

function IbusOff()
	vim.g.ibus_prev_engine = IbusGetCurrentEngine()
	vim.system({ 'ibus', 'engine', 'xkb:us::eng' })
end

function IbusOn()
	local current_engine = IbusGetCurrentEngine()
	if not current_engine:match('xkb:us::eng') then
		vim.g.ibus_prev_engine = current_engine
	end
	vim.system({ 'ibus', 'engine', vim.trim(vim.g.ibus_prev_engine) })
end

IbusOff()

if vim.fn.has('nvim') == 1 then
	vim.api.nvim_create_augroup('IBusHandler', { clear = true })
	vim.api.nvim_create_autocmd('CmdLineEnter', {
		pattern = '[/?]',
		callback = IbusOn,
		group = 'IBusHandler',
	})
	vim.api.nvim_create_autocmd('CmdLineLeave', {
		pattern = '[/?]',
		callback = IbusOff,
		group = 'IBusHandler',
	})
	vim.api.nvim_create_autocmd('InsertEnter', {
		pattern = '*',
		callback = IbusOn,
		group = 'IBusHandler',
	})
	vim.api.nvim_create_autocmd('InsertLeave', {
		pattern = '*',
		callback = IbusOff,
		group = 'IBusHandler',
	})
	vim.api.nvim_create_autocmd('ExitPre', {
		callback = IbusOn,
		group = 'IBusHandler',
	})
end
