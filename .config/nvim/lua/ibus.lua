if vim.fn.executable('ibus') == 0 then
	return
end

local function current_ibus_engine()
	local output = vim.system({ 'ibus', 'engine' }, { text = true }):wait()
	return output.stdout
end

local function IBusOff()
	-- Lưu lại engine hiện tại
	vim.g.ibus_prev_engine = current_ibus_engine()
	-- Chuyển sang engine tiếng Anh
	vim.system({ 'ibus', 'engine', 'xkb:us::eng' })
end

local function IBusOn()
	local current_engine = current_ibus_engine()
	if not current_engine:match('xkb:us::eng') then
		vim.g.ibus_prev_engine = current_engine
	end
	vim.system({ 'ibus', 'engine', vim.trim(vim.g.ibus_prev_engine) }):wait()
end

vim.api.nvim_create_augroup('IBusHandler', { clear = true })
vim.api.nvim_create_autocmd('CmdLineEnter', {
	pattern = '[/?]',
	callback = IBusOn,
	group = 'IBusHandler',
})
vim.api.nvim_create_autocmd('CmdLineLeave', {
	pattern = '[/?]',
	callback = IBusOff,
	group = 'IBusHandler',
})
vim.api.nvim_create_autocmd('InsertEnter', {
	pattern = '*',
	callback = IBusOn,
	group = 'IBusHandler',
})
vim.api.nvim_create_autocmd('InsertLeave', {
	pattern = '*',
	callback = IBusOff,
	group = 'IBusHandler',
})
vim.api.nvim_create_autocmd('ExitPre', {
	callback = IBusOn,
	group = 'IBusHandler',
})

IBusOff()
