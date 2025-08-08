if not vim.pack then
	return
end

local pack = require 'an.pack'
local exec = pack.exec
local autocmd = vim.api.nvim_create_autocmd

---@param name string
---@return string
local github = function(name)
	return "https://github.com/" .. name
end

vim.g['sneak#label'] = 1

vim.g.firenvim_config = {
	globalSettings = { alt = "all" },
	localSettings = {
		[".*"] = {
			cmdline  = "neovim",
			content  = "text",
			priority = 0,
			selector = "textarea",
			takeover = "never"
		}
	}
}

vim.g.db_ui_use_nerd_fonts = 1 -- dadbod-db

vim.g.lexima_map_escape = ''
vim.g.lexima_enable_endwise_rules = 0
vim.g.lexima_enable_basic_rules = 0

pack.add {
	github 'b0o/SchemaStore.nvim',
	github 'tpope/vim-repeat', -- dep of vim-surround
	github 'tpope/vim-surround',
	github 'echasnovski/mini.jump2d',
	github 'justinmk/vim-sneak',
	github 'brianhuster/direx.nvim',
	github 'echasnovski/mini.icons',
	github 'brianhuster/unnest.nvim',
	{
		src = github 'nvim-treesitter/nvim-treesitter',
		version = 'main',
		build = ':TSUpdate all'
	},
	github 'nvim-treesitter/nvim-treesitter-context',
	{
		src = github 'nvim-treesitter/nvim-treesitter-textobjects',
		version = 'main',
	},
	{
		src = github 'glacambre/firenvim',
		build = ':call firenvim#install(0)'
	},
	github 'brianhuster/live-preview.nvim',
	github 'folke/which-key.nvim',
	github 'echasnovski/mini.clue',
	github 'vim-jp/vimdoc-ja',
	github 'neovim/nvim-lspconfig',
	github 'williamboman/mason.nvim',
	github 'rafamadriz/friendly-snippets',
	github 'kristijanhusak/vim-dadbod-completion',
	github 'mfussenegger/nvim-jdtls',
	github 'nvim-lua/plenary.nvim', -- dep of many plugins
	github 'echasnovski/mini.diff',
	github 'brianhuster/qfpeek.nvim',
	github 'mfussenegger/nvim-dap',
	github 'leoluz/nvim-dap-go',
	github 'brianhuster/treesitter-endwise.nvim',
	github 'windwp/nvim-ts-autotag',
	github 'cohama/lexima.vim',
	github 'uga-rosa/ccc.nvim',
	github 'github/copilot.vim',
	{
		src = github 'CopilotC-Nvim/CopilotChat.nvim',
		build = 'make tiktoken'
	},
	github 'brianhuster/supermaven-nvim',
	github 'HakonHarnes/img-clip.nvim', -- avante.nvim dep
	github 'MunifTanjim/nui.nvim',   -- avante.nvim dep
	{
		src = github 'yetone/avante.nvim',
		build = 'make'
	},
	{
		src = github 'ravitemer/mcphub.nvim',
		build = 'npm i -g mcp-hub@latest'
	},
	github 'j-hui/fidget.nvim', -- codecompanion dep
	github 'olimorris/codecompanion.nvim',
	github 'seandewar/actually-doom.nvim',
}

exec(require 'mini.jump2d'.setup, {
	mappings = {
		start_jumping = '<Leader>j',
	}
})

exec(require 'nvim-treesitter'.install, 'stable')
exec(require 'nvim-treesitter'.install, 'unstable')

exec(require 'treesitter-context'.setup, {
	max_lines = 3
})
vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

exec(function()
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
		},  move = {
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
	vim.keymap.set({ "x", "o" }, "as", function()
		require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
	end)

	vim.keymap.set({ "n", "x", "o" }, "]m", function()
		require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]]", function()
		require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
	end)
	-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
	vim.keymap.set({ "n", "x", "o" }, "]s", function()
		require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]z", function()
		require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
	end)

	vim.keymap.set({ "n", "x", "o" }, "]M", function()
		require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "][", function()
		require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
	end)

	vim.keymap.set({ "n", "x", "o" }, "[m", function()
		require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[[", function()
		require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
	end)

	vim.keymap.set({ "n", "x", "o" }, "[M", function()
		require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[]", function()
		require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
	end)
end)

exec(require('which-key').setup, {
	preset = 'helix',
	triggers = { '<auto>', 'nxso' }
})

exec(require 'mini.clue'.setup, {
	triggers = {
		{ mode = 'i', keys = '<C-x>' },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		require 'mini.clue'.gen_clues.builtin_completion(),
	},
})

exec(require 'mini.icons'.setup)

do
	exec(require 'direx.config'.set, {
		iconfunc = function(p)
			local get = require('mini.icons').get
			local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
			icon = icon .. ' '
			return { icon = icon, hl = hl }
		end,
	})
end

vim.keymap.set('n', '<C-p>', function()
	vim.cmd.UnnestEdit [[nvim $(fzf --preview "nvcat -clean {}")]]
end)

exec(require 'mason'.setup, {})

exec(require('mini.diff').setup, {
	view = {
		style = 'sign'
	}
})

exec(function()
	require('dap.ext.vscode').json_decode = vim.fn.Json5Decode
end)

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

exec(require 'CopilotChat'.setup, {
	model = 'claude-3.5-sonnet'
})

exec(require 'supermaven-nvim'.setup, {
	keymaps = {
		accept_suggestion = "<M-CR>",
		accept_word = "<M-w>",
	},
})
exec(require 'supermaven-nvim.api'.use_free_version)

exec(require 'avante'.setup, {
	provider = "copilot",
	providers = {
		copilot = {
			model = 'claude-3.5-sonnet'
		}
	},
	system_prompt = function()
		local hub = require("mcphub").get_hub_instance()
		return hub:get_active_servers_prompt()
	end,
	-- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
	custom_tools = function()
		return {
			require("mcphub.extensions.avante").mcp_tool(),
		}
	end,
})

exec(require 'mcphub'.setup, {
	extensions = {
		avante = {
			make_slash_commands = true, -- make /slash commands from MCP server prompts
		},
		config = vim.fn.expand("~/.config/mcphub/servers.json"),
		codecompanion = {
			show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
			make_vars = true,  -- make chat #variables from MCP server resources
		}
	}
}
)

exec(require('codecompanion').setup, {
	adapters = {
		copilot = require("codecompanion.adapters").extend("copilot", {
			schema = {
				model = {
					default = "claude-3.5-sonnet",
				},
			},
		}),
	},
	strategies = {
		chat = {
			tools = {
				mcp = {
					callback = function()
						return require("mcphub.extensions.codecompanion")
					end,
					description = "Call tools and resources from the MCP Servers",
					opts = {
						requires_approval = true,
					}
				}
			}
		}
	}
})

autocmd('FileType', {
	pattern = 'java', once = true,
	callback = function()
		local fs = vim.fs
		local config = {
			cmd = { fs.joinpath(vim.fn.stdpath('data'), 'mason/bin/jdtls') },
			root_dir = fs.dirname(fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
		}
		require('jdtls').start_or_attach(config)
	end
})

autocmd('FileType', {
	pattern = 'go', once = true,
	callback = function()
		require('dap-go').setup()
	end
})

autocmd('FileType', {
	pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
	once = true,
	callback = function()
		local dap = require('dap')
		dap.configurations.javascript = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				cwd = "${workspaceFolder}",
			},
		}
		dap.adapters['pwa-node'] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				-- 💀 Make sure to update this path to point to your installation
				args = { vim.fn.stdpath('data') .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
			}
		}
	end
})
