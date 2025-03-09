if not vim.g.vscode then
	return
end

vim.g.clipboard = vim.g.vscode_clipboard

local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd

vim.filetype.add {
	pattern = {
		['.*%.ipynb.*'] = 'python',
		-- uses lua pattern matching
		-- rathen than native matching
	},
}

local call = require('vscode').call     -- Synchrnous call to vscode
local action = require('vscode').action -- Asynchronous call to vscode

map('n', '-', call('workbench.files.action.showActiveFileInExplore'), { silent = true })
map('n', '<Leader>xr', call 'references-view.findReferences', { silent = true })  -- language references
map('n', '<Leader>xd', call 'workbench.actions.view.problems', { silent = true }) -- language diagnostics
map('n', 'grr', call 'editor.action.goToReferences', { silent = true })
map('n', 'grn', call 'editor.action.rename', { silent = true })
map('n', '<Leader>ca', call 'editor.action.refactor', { silent = true })              -- language code actions

map('n', '<Leader>fg', call 'workbench.action.findInFiles', { silent = true })        -- use ripgrep to search files
map('n', '<Leader>ts', call 'workbench.action.toggleSidebarVisibility', { silent = true })
map('n', '<Leader>th', call 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
map('n', '<Leader>tp', call 'workbench.action.togglePanel', { silent = true })
map('n', '<Leader>fc', call 'workbench.action.showCommands', { silent = true })       -- find commands
map('n', '<Leader>ff', call 'workbench.action.quickOpen', { silent = true })          -- find files
map('n', 't', call 'workbench.action.terminal.toggleTerminal', { silent = true })     -- terminal window

map('v', 'gq', action 'editor.action.formatSelection', { silent = true })
map('v', '<Leader>ca', call 'editor.action.refactor', { silent = true })
map('v', '<Leader>fc', call 'workbench.action.showCommands', { silent = true })

autocmd('BufWritePre', {
	pattern = '*',
	callback = function()
		action('editor.action.formatDocument')
	end,
})
