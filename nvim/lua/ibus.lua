if vim.fn.executable('ibus') == 0 then
	vim.notify_once('ibus is not installed, \nChuyển sang bộ gõ tiếng Việt tích hợp sẵn trong Vim', vim.log.levels.WARN)
	vim.o.keymap = 'vietnamese-telex_utf-8'
	return
end

function IbusGetCurrentEngine()
	local result = vim.system({ 'ibus', 'engine' }):wait()
	return vim.fn.trim(result.stdout)
end

function IbusOff()
	vim.g.ibus_prev_engine = IbusGetCurrentEngine()
	vim.system({ 'ibus', 'engine', 'xkb:us::eng' }):wait()
end

function IbusOn()
	local current_engine = IbusGetCurrentEngine()
	if not current_engine:match('xkb:us::eng') then
		vim.g.ibus_prev_engine = current_engine
	end
	vim.system({ 'ibus', 'engine', vim.g.ibus_prev_engine }):wait()
end

vim.api.nvim_create_augroup('IBusHandler', { clear = true })
vim.api.nvim_create_autocmd('CmdLineEnter', {
	pattern = { '[/?]', '[:s/?]', '[:%s/?]' },
	callback = IbusOn,
	group = 'IBusHandler',
})
vim.api.nvim_create_autocmd('CmdLineLeave', {
	pattern = { '[/?]', '[:s/?]', '[:%s/?]' },
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

IbusOff()
