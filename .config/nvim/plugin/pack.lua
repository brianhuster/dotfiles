if not vim.pack then
	return
end

local pack = require 'an.pack'
local exec = pack.exec

---@param name string
---@return string
local github = function(name)
	return "https://github.com/" .. name
end

pack.add {
	github 'tpope/vim-repeat', -- dep of vim-surround
	github 'tpope/vim-surround',
	github 'echasnovski/mini.jump2d',
	github 'justinmk/vim-sneak',
	github 'echasnovski/mini.icons',
	github 'brianhuster/direx.nvim',
	{
		src = github 'nvim-treesitter/nvim-treesitter',
		version = 'main',
		build = ':TSUpdate all'
	},
	github 'nvim-treesitter/nvim-treesitter-context',
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
	github 'NeogitOrg/neogit',
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
	github 'seandewar/actually-doom.nvim'
}

exec(require 'mini.jump2d'.setup, {
	mappings = {
		start_jumping = '<Leader>j',
	}
})

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

exec(require 'nvim-treesitter'.install, 'stable')
exec(require 'nvim-treesitter'.install, 'unstable')

exec(require 'treesitter-context'.setup, {
	max_lines = 3
})
vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

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
	local previewer ---@type string
	if vim.fn.executable('nvcat') == 1 then
		previewer = [[nvcat -clean {}]]
	elseif vim.fn.executable('bat') == 1 then
		previewer =
		[[bat --style=numbers --color=always --paging=always --wrap=never --theme=ansi --pager=never --decorations=never {}]]
	end
	exec(require 'direx.config'.set, {
		iconfunc = function(p)
			local get = require('mini.icons').get
			local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
			icon = icon .. ' '
			return { icon = icon, hl = hl }
		end,
		fzfprg = ("fzf --preview %s "):format(vim.fn.shellescape(previewer))
	})
	vim.keymap.set('n', '<C-p>', '<cmd>DirexFzf<CR>')
end

exec(require 'mason'.setup, {})

exec(require('mini.diff').setup, {
	view = {
		style = 'sign'
	}
})

exec(function()
	require('dap.ext.vscode').json_decode = vim.fn.JsoncDecode
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
