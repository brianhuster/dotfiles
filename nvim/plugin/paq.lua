vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

if vim.fn.isdirectory(vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim') == 0 then
	vim.system(
		{ 'git', 'clone', '--depth=1', '--branch=nightly', 'https://github.com/brianhuster/paq-nvim.git', vim.fn.stdpath(
			'data') ..
		'/site/pack/paqs/start/paq-nvim' }, {}, function(cmd)
			print(cmd.stderr)
			print(cmd.stdout)
		end)
end

require('paq') {
	{ 'brianhuster/paq-nvim',   branch = 'nightly' },
	{ 'echasnovski/mini.icons', config = function() require('mini.icons').setup() end }, -- Use by direx.nvim
	{
		"brianhuster/direx.nvim", config = function()
			local previewer ---@type string
			if vim.fn.executable('nvcat') == 1 then
				previewer = [[nvcat -clean {}]]
			elseif vim.fn.executable('bat') == 1 then
				previewer = [[bat --style=numbers --color=always --paging=always --wrap=never --theme=ansi --pager=never --decorations=never {}]]
			end
			require('direx.config').set {
				iconfunc = function(p)
					local get = require('mini.icons').get
					local icon, hl = get(p:sub(-1) == '/' and 'directory' or 'file', p)
					icon = icon .. ' '
					return { icon = icon, hl = hl }
				end,
				fzfprg = ("fzf --preview %s "):format(vim.fn.shellescape(previewer))
			}
		end
	},
	'neovim/nvim-lspconfig',
	'williamboman/mason.nvim',
	'echasnovski/mini.pick',
	{ 'williamboman/mason-lspconfig.nvim', config = function()
		local lang_servers = {
			"arduino_language_server",
			"dockerls",
			"bashls",
			"clangd",
			"cssls", "tailwindcss", "html", "ts_ls",
			"jsonls",
			'jdtls',
			"lua_ls",
			"marksman",
			"pylsp",
			"volar",
			"gopls",
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
	end },
	'tpope/vim-repeat', -- dependency of vim-surround
	'tpope/vim-surround',
	'mg979/vim-visual-multi',
	-- 'christoomey/vim-tmux-navigator',
	{
		'mfussenegger/nvim-jdtls', -- Java development
		config = function()
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
		end
	},
	{ 'echasnovski/mini.trailspace', config = function() require('mini.trailspace').setup {} end },
	{
		'nvimdev/indentmini.nvim',
		config = function()
			vim.cmd [[
				hi default link IndentLine Comment
				hi default link IndentLineCurrent Comment
			]]
			require('indentmini').setup {}
		end
	},
	'f-person/git-blame.nvim',
	'tpope/vim-fugitive',
	'nvim-lua/plenary.nvim', -- dependency of many plugins
	{ 'NeogitOrg/neogit',       opt = true },
	{
		'echasnovski/mini.diff',
		config = function()
			require('mini.diff').setup {
				view = {
					style = 'sign'
				}
			}
		end
	},
	{
		'mfussenegger/nvim-dap',
		config = function()
			vim.keymap.set('n', '<Leader>b', '<cmd>DapToggleBreakpoint<CR>')
			vim.keymap.set('n', ']D', '<cmd>DapContinue<CR>')
		end
	},
	{
		'theHamsta/nvim-dap-virtual-text',
		config = function()
			require('nvim-dap-virtual-text').setup()
		end
	},
	'leoluz/nvim-dap-go',
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate all',
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		config = function()
			require('treesitter-context').setup { max_lines = 3 }
			vim.keymap.set("n", "[c", function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end, { silent = true })
		end
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main',
		config = function()
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
	},
	'cohama/lexima.vim', -- Autopairs
	'brianhuster/nvim-treesitter-endwise',
	{ 'windwp/nvim-ts-autotag', config = function() require('nvim-ts-autotag').setup() end },
	'OXY2DEV/patterns.nvim',
	{ 'folke/ts-comments.nvim',        config = function() require('ts-comments').setup() end },
	'lambdalisue/vim-suda',
	'brianhuster/snipexec.nvim',
	'uga-rosa/ccc.nvim',
	{
		'glacambre/firenvim', build = ':call firenvim#install(0)',
		config = function()
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
		end
	},
	{ 'brianhuster/live-preview.nvim', opt = true },
	'equalsraf/neovim-gui-shim',
	{
		'folke/which-key.nvim',
		config = function()
			require('which-key').setup {
				preset = "helix",
				triggers = { "<auto>", 'nxso' }
			}
		end
	},
	{
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
				},
			})
		end
	},
	{
		'github/copilot.vim',
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
		'CopilotC-Nvim/CopilotChat.nvim',
		build = 'make tiktoken',
		config = function()
			require('CopilotChat').setup {
				model = "claude-3.5-sonnet",
			}
		end
	},
	'MunifTanjim/nui.nvim',
	'HakonHarnes/img-clip.nvim', -- avante dependencies
	{ 'yetone/avante.nvim', build = 'make', opt = true,
		config = function()
			require('avante').setup {
				provider = "copilot",
			}
		end
	},
	{
		'olimorris/codecompanion.nvim',
		config = function()
			require('codecompanion').setup {
				adapters = {
					copilot = require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "claude-3.5-sonnet",
							},
						},
					}),
				}
			}
		end
	},
	{ 'brianhuster/supermaven-nvim', },
	'tpope/vim-dadbod',
	{ 'kristijanhusak/vim-dadbod-ui', config = function() vim.g.db_ui_use_nerd_fonts = 1 end },
	'kristijanhusak/vim-dadbod-completion',
}

vim.cmd.PaqInstall()


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
		}
		pcall(require('supermaven-nvim.api').use_free_version)
	end,
	once = true
})

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
