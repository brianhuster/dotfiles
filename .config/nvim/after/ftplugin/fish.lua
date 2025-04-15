local browser
local saved_browser = vim.env.BROWSER
local tui_browsers = { 'w3m', 'lynx' }

if vim.env.SHELL == vim.fn.exepath('fish') then
	if not browser and not vim.tbl_contains(tui_browsers, saved_browser) then
		for _, browser in ipairs(tui_browsers) do
			if vim.fn.executable(browser) == 1 then
				vim.env.BROWSER = browser
				break
			end
		end
	end
	vim.bo.keywordprg = 'help'
	vim.b.undo_ftplugin = table.concat({
		type(vim.b.undo_ftplugin) == 'string' and vim.b.undo_ftplugin or '',
		'setl keywordprg<',
		'let $BROWSER = ' .. vim.fn.shellescape(saved_browser)
	})
end
