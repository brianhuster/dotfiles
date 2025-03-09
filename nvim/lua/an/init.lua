local M = {}

function M.ins_autocomplete(shortcut, triggers)
	if vim.fn.pumvisible() == 1 or vim.fn.state('m') == 'm' then
		return
	end
	local char = vim.v.char
	if vim.list_contains(triggers, char) then
		shortcut = vim.keycode(shortcut)
		vim.api.nvim_feedkeys(shortcut, 'm', false)
	end
end

return M
