if vim.fn.executable('ibus') == 0 then
	return
end

function IbusGetCurrentEngine()
	return vim.system({ 'ibus', 'engine' }):wait().stdout
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
	vim.system({ 'ibus', 'engine', vim.trim(vim.g.ibus_prev_engine) }):wait()
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
