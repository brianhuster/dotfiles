if not vim.g.vscode then
	return
end


vim.g.clipboard = vim.g.vscode_clipboard

local keymap = vim.keymap.set
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

keymap('n', '-', call('workbench.files.action.showActiveFileInExplore'), { silent = true })
keymap('n', '<Leader>xr', call 'references-view.findReferences', { silent = true })  -- language references
keymap('n', '<Leader>xd', call 'workbench.actions.view.problems', { silent = true }) -- language diagnostics
keymap('n', 'grr', call 'editor.action.goToReferences', { silent = true })
keymap('n', 'grn', call 'editor.action.rename', { silent = true })
keymap('n', '<Leader>ca', call 'editor.action.refactor', { silent = true })              -- language code actions

keymap('n', '<Leader>fg', call 'workbench.action.findInFiles', { silent = true })        -- use ripgrep to search files
keymap('n', '<Leader>ts', call 'workbench.action.toggleSidebarVisibility', { silent = true })
keymap('n', '<Leader>th', call 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
keymap('n', '<Leader>tp', call 'workbench.action.togglePanel', { silent = true })
keymap('n', '<Leader>fc', call 'workbench.action.showCommands', { silent = true })       -- find commands
keymap('n', '<Leader>ff', call 'workbench.action.quickOpen', { silent = true })          -- find files
keymap('n', 't', call 'workbench.action.terminal.toggleTerminal', { silent = true })     -- terminal window

keymap('v', 'gq', action 'editor.action.formatSelection', { silent = true })
keymap('v', '<Leader>ca', call 'editor.action.refactor', { silent = true })
keymap('v', '<Leader>fc', call 'workbench.action.showCommands', { silent = true })

autocmd('BufWritePre', {
	pattern = '*',
	callback = function()
		action('editor.action.formatDocument')
	end,
})
