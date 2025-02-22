return {
	{
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		lazy = false,
		build = function()
			vim.cmd.TSInstall 'all'
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		event = 'BufRead',
		config = function()
			require 'treesitter-context'.setup {
				max_lines = 3
			}
			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true })
		end
	},
	{
		'nvim-treesitter/nvim-treesitter-refactor',
		dependencies = {
			{ 'nvim-treesitter/nvim-treesitter' },
		},
		event = 'BufRead',
		config = function()
			require 'nvim-treesitter.configs'.setup({
				refactor = {
					highlight_definitions = { enable = true },
					highlight_current_scope = { enable = false },
					smart_rename = {
						enable = true,
						keymaps = {
							smart_rename = "<leader>rn",
						},
					},
					navigation = {
						enable = true,
						keymaps = {
							goto_definition = "gd",
							list_definitions = "gnD",
							list_definitions_toc = "gO",
							goto_next_usage = "<a-*>",
							goto_previous_usage = "<a-#>",
						},
					},
				},
			})
		end
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
		event = 'BufRead',
		config = function()
			-- configuration
			require("nvim-treesitter-textobjects").setup {
				select = {
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,
					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-v>') or a table
					-- mapping query_strings to modes.
					selection_modes = {
						['@parameter.outer'] = 'v', -- charwise
						['@function.outer'] = 'V', -- linewise
						['@class.outer'] = '<c-v>', -- blockwise
					},
					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true of false
					include_surrounding_whitespace = false,
				},
				move = {
					-- whether to set jumps in the jumplist
					set_jumps = true,
				},
			}

			-- keymaps
			-- You can use the capture groups defined in `textobjects.scm`
			vim.keymap.set({ "x", "o" }, "af", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
			end)
			-- You can also use captures from other query groups like `locals.scm`
			vim.keymap.set({ "x", "o" }, "al", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@comment.inner", 'textobjects')
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require "nvim-treesitter-textobjects.select".select_textobject("@comment.outer", 'textobjects')
			end)

			local ts_repeat_move = "nvim-treesitter-textobjects.repeatable_move"

			vim.keymap.set({ "n", "x", "o" }, ";", function()
				require(ts_repeat_move).repeat_last_move_next()
			end)
			vim.keymap.set({ "n", "x", "o" }, ",", function()
				require(ts_repeat_move).repeat_last_move_previous()
			end)
		end
	}
}
