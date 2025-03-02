if not pcall(require, 'paq') then
	local paqpath = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
	if not vim.uv.fs_stat(paqpath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/savq/paq-nvim.git",
			"--branch=nightly", -- latest stable release
			paqpath,
		})
	end
end

require 'paq' {
	-- {
	-- 	'savq/paq-nvim',
	-- 	branch = 'nightly',
	-- },
	"brianhuster/direx.nvim",
	'echasnovski/mini.icons', -- Use by direx.nvim
	'neovim/nvim-lspconfig',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'tpope/vim-repeat', -- dependency of vim-surround
	'tpope/vim-surround',
	'justinmk/vim-sneak',
	'mg979/vim-visual-multi',
	'christoomey/vim-tmux-navigator',
	'justinmk/vim-sneak',
	'mfussenegger/nvim-jdtls', -- Java development
	'echasnovski/mini.trailspace',
	'f-person/git-blame.nvim',
	'tpope/vim-fugitive',
	'nvim-lua/plenary.nvim', -- dependency of many plugins
	{ 'NeogitOrg/neogit',                            opt = true },
	'echasnovski/mini.diff',
	'mfussenegger/nvim-dap',
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdateAll',
	},
	'nvim-treesitter/nvim-treesitter-context',
	{ 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
	},
	'cohama/lexima.vim', -- Autopairs
	'brianhuster/nvim-treesitter-endwise',
	'windwp/nvim-ts-autotag',
	'OXY2DEV/patterns.nvim',
	'folke/ts-comments.nvim', -- Better comments for JSX, ...
	'lambdalisue/vim-suda',
	'brianhuster/snipexec.nvim',
	'uga-rosa/ccc.nvim',
	{ 'glacambre/firenvim', build = ':call firenvim#install(0)' },
	'brianhuster/live-preview.nvim',
	'equalsraf/neovim-gui-shim',
	'folke/which-key.nvim',
	'echasnovski/mini.clue',
	'github/copilot.vim',
	{
		'CopilotC-Nvim/CopilotChat.nvim',
		build = 'make tiktoken',
	},
	'MunifTanjim/nui.nvim',
	'HakonHarnes/img-clip.nvim', -- avante dependencies
	-- 'yetone/avante.nvim',
	'olimorris/codecompanion.nvim',
	'brianhuster/supermaven-nvim',
	'tpope/vim-dadbod',
	'kristijanhusak/vim-dadbod-ui',
	'kristijanhusak/vim-dadbod-completion',
}

vim.cmd.PaqInstall()

require('mini.icons').setup()

require('direx.config').set {
	iconfunc = function(p)
		local get = require('mini.icons').get
		local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
		icon = icon .. ' '
		return { icon = icon, hl = hl }
	end,
}

local lang_servers = {
	"arduino_language_server",
	"bashls",
	"clangd",
	"cssls",
	"tailwindcss",
	"dockerls",
	"html",
	"ts_ls",
	"jsonls",
	'jdtls',
	"lua_ls",
	"marksman",
	"pylsp",
	"volar",
	"gopls"
}
require('mason').setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})
require("mason-lspconfig").setup {
	ensure_installed = lang_servers,
}
require("mason-lspconfig").setup_handlers {
	function(server_name)
		if server_name ~= 'lua_ls' then
			require("lspconfig")[server_name].setup {}
		end
	end,
}


--- nvim-jdtls
vim.cmd [[
nnoremap <A-o> <Cmd>lua require'jdtls'.organize_imports()<CR>
nnoremap crv <Cmd>lua require('jdtls').extract_variable()<CR>
vnoremap crv <Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>
nnoremap crc <Cmd>lua require('jdtls').extract_constant()<CR>
vnoremap crc <Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>
vnoremap crm <Esc><Cmd>lua require('jdtls').extract_method(true)<CR>


" If using nvim-dap
" This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
nnoremap <leader>df <Cmd>lua require'jdtls'.test_class()<CR>
nnoremap <leader>dn <Cmd>lua require'jdtls'.test_nearest_method()<CR>
]]

-- echasnovski/mini.trailspace
require('mini.trailspace').setup {}

-- echasnovski/mini.diff
require('mini.diff').setup {
	view = {
		style = 'sign'
	}
}

-- vim-sneak
vim.cmd [[
let g:vm_mouse_mappings    = 1
let g:vm_theme             = 'iceblue'

let g:vm_maps = {}
let g:vm_maps["undo"]      = 'u'
let g:vm_maps["redo"]      = '<c-r>'
]]

-- nvim-treesitter-context

require('treesitter-context').setup { max_lines = 3 }
vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

-- nvim-treesitter-textobjects
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

-- nvim-ts-autotag
require('nvim-ts-autotag').setup()

-- nvim-ts-autotag
require('nvim-ts-autotag').setup()

-- folke/ts-comments.nvim
require('ts-comments').setup()

-- glacambre/firenvim
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

-- vim-dadbod-ui
vim.g.db_ui_use_nerd_fonts = 1

-- which-key.nvim
require('which-key').setup {
	preset = "helix",
	triggers = { "<auto>", 'nxso' }
}

-- mini.clue
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

-- img-clip.nvim
require('img-clip').setup {
	default = {
		embed_image_as_base64 = false,
		prompt_for_file_name = false,
		drag_and_drop = {
			insert_mode = true,
		},
		-- required for Windows users
		use_absolute_path = true,
	}
}

-- require('avante').setup {
-- 	provider = "copilot",
-- }

-- supermaven-nvim
vim.api.nvim_create_autocmd('InsertEnter', {
	callback = function()
		if _G.loaded_supermaven_nvim then
			return
		end
		_G.loaded_supermaven_nvim = true
		require('supermaven-nvim').setup {
			keymaps = {
				accept_suggestion = "<M-CR>",
				accept_word = "<M-w>",
			},
			require('supermaven-nvim.api').use_free_version()
		}
	end
})

-- codecompanion.nvim
require('codecompanion').setup()

-- CopilotChat.nvim
require('CopilotChat').setup()

-- -- codeium.nvim
-- 		require("codeium").setup({
-- 			-- Optionally disable cmp source if using virtual text only
-- 			enable_cmp_source = false,
-- 			virtual_text = {
-- 				enabled = true,
--
-- 				-- These are the defaults
--
-- 				-- Set to true if you never want completions to be shown automatically.
-- 				manual = false,
-- 				-- A mapping of filetype to true or false, to enable virtual text.
-- 				filetypes = {},
-- 				-- Whether to enable virtual text of not for filetypes not specifically listed above.
-- 				default_filetype_enabled = true,
-- 				-- How long to wait (in ms) before requesting completions after typing stops.
-- 				idle_delay = 75,
-- 				-- Priority of the virtual text. This usually ensures that the completions appear on top of
-- 				-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
-- 				-- desired.
-- 				virtual_text_priority = 65535,
-- 				-- Set to false to disable all key bindings for managing completions.
-- 				map_keys = true,
-- 				-- The key to press when hitting the accept keybinding but no completion is showing.
-- 				-- Defaults to \t normally or <c-n> when a popup is showing.
-- 				accept_fallback = nil,
-- 				-- Key bindings for managing completions in virtual text mode.
-- 				key_bindings = {
-- 					-- Accept the current completion.
-- 					accept = "<M-CR>",
-- 					-- Accept the next word.
-- 					accept_word = "<M-w>",
-- 					-- Accept the next line.
-- 					accept_line = "<M-l>",
-- 					-- Clear the virtual text.
-- 					clear = "<C-]>",
-- 					-- Cycle to the next completion.
-- 					next = "<M-]>",
-- 					-- Cycle to the previous completion.
-- 					prev = "<M-[>",
-- 				}
-- 			}
-- 		})
-- 		vim.cmd ":highlight link CodeiumSuggestion Comment"
-- 	end
