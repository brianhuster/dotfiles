return {
	{
		"github/copilot.vim",
		config = function()
			vim.keymap.set('i', '<M-CR>', 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false
			})
			vim.keymap.set('i', '<M-w>', '<Plug>(copilot-accept-word)', {
				expr = true,
				replace_keycodes = false
			})
			vim.keymap.set('i', '<M-l>', '<Plug>(copilot-accept-line)', {
				expr = true,
				replace_keycodes = false
			})
			vim.g.copilot_no_tab_map = true
			vim.cmd [[au BufEnter * let b:copilot_enabled = v:false]]
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		cmd = 'CopilotChat',
		opts = {}
	},
	{
		"Davidyz/VectorCode",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			n_query = 1, -- number of retrieved documents
			notify = true, -- enable notifications
			timeout_ms = 5000, -- timeout in milliseconds for the query operation.
			exclude_this = true, -- exclude the buffer from which the query is called.
			-- This avoids repetition when you change some code but
			-- the embedding has not been updated.
		},
		cond = function() return vim.fn.executable('vectorcode') == 1 end,
	},
	{
		"yetone/avante.nvim",
		version = false, -- set this if you want to always pull the latest change,
		opts = {
			provider = "copilot",
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		cmd = "Avante",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			-- "stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"github/copilot.vim", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
		},
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"github/copilot.vim"
		},
		opts = {}
	},
	{
		'Exafunction/codeium.nvim',
		event = 'InsertEnter',
		config = function()
			require("codeium").setup({
				-- Optionally disable cmp source if using virtual text only
				enable_cmp_source = false,
				virtual_text = {
					enabled = true,

					-- These are the defaults

					-- Set to true if you never want completions to be shown automatically.
					manual = false,
					-- A mapping of filetype to true or false, to enable virtual text.
					filetypes = {},
					-- Whether to enable virtual text of not for filetypes not specifically listed above.
					default_filetype_enabled = true,
					-- How long to wait (in ms) before requesting completions after typing stops.
					idle_delay = 75,
					-- Priority of the virtual text. This usually ensures that the completions appear on top of
					-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
					-- desired.
					virtual_text_priority = 65535,
					-- Set to false to disable all key bindings for managing completions.
					map_keys = true,
					-- The key to press when hitting the accept keybinding but no completion is showing.
					-- Defaults to \t normally or <c-n> when a popup is showing.
					accept_fallback = nil,
					-- Key bindings for managing completions in virtual text mode.
					key_bindings = {
						-- Accept the current completion.
						accept = "<M-CR>",
						-- Accept the next word.
						accept_word = "<M-w>",
						-- Accept the next line.
						accept_line = "<M-l>",
						-- Clear the virtual text.
						clear = "<C-]>",
						-- Cycle to the next completion.
						next = "<M-]>",
						-- Cycle to the previous completion.
						prev = "<M-[>",
					}
				}
			})
			vim.cmd ":highlight link CodeiumSuggestion Comment"
		end
	},
	-- {
	-- 	'brianhuster/supermaven-nvim',
	-- 	config = function()
	-- 		require 'supermaven-nvim'.setup {
	-- 			keymaps = {
	-- 				accept_suggestion = "<M-CR>",
	-- 				accept_word = "<M-w>",
	-- 			},
	-- 		}
	-- 		require("supermaven-nvim.api").use_free_version()
	-- 	end,
	-- 	event = 'InsertEnter',
	-- }
}
