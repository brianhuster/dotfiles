return {
	'echasnovski/mini.clue',
	config = function()
		local miniclue = require('mini.clue')
		miniclue.setup({
			triggers = {
				-- Built-in completion
				{ mode = 'i', keys = '<C-x>' },
			},

			clues = {
				-- Enhance this by adding descriptions for <Leader> mapping groups
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.marks(),
				miniclue.gen_clues.registers(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.z(),
			},
		})
	end
}
