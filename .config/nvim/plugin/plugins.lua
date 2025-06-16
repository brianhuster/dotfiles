vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

local plugins_list = {
	{
		'tpope/vim-surround',
		dependencies = { 'tpope/vim-repeat' },
	},
	{
		'echasnovski/mini.jump2d',
		config = function()
			require 'mini.jump2d'.setup {
				mappings = {
					start_jumping = '<Leader>j',
				}
			}
		end
	},
	{
		'justinmk/vim-sneak',
		config = function()
			vim.g['sneak#label'] = 1
		end
	},
	"mg979/vim-visual-multi",
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
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
		config = function()
			require("nvim-treesitter-textobjects").setup {
				select = {
					lookahead = true,
					selection_modes = {
						['@parameter.outer'] = 'v', -- charwise
						['@function.outer'] = 'V', -- linewise
						['@class.outer'] = '<c-v>', -- blockwise
					},
					include_surrounding_whitespace = false,
				},
				move = {
					set_jumps = true,
				},
				keymaps = {
					as = "@function.outer",
					is = "@function.inner",
					ac = "@class.outer",
					ic = "@class.inner",
					al = "@local.scope",
				},
				textobjects = {
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = { query = "@class.outer", desc = "Next class start" },
							--
							-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
							["]o"] = "@loop.*",
							-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
							--
							-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
							-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
							["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
						-- Below will go to either the start or the end, whichever is closer.
						-- Use if you want more granular movements
						-- Make it even more gradual by adding multiple queries and regex.
						goto_next = {
							["]d"] = "@conditional.outer",
						},
						goto_previous = {
							["[d"] = "@conditional.outer",
						}
					},
				},
			}

			local ts_repeat_move = "nvim-treesitter-textobjects.repeatable_move"

			vim.keymap.set({ "n", "x", "o" }, ";", function()
				require(ts_repeat_move).repeat_last_move_next()
			end)
			vim.keymap.set({ "n", "x", "o" }, ",", function()
				require(ts_repeat_move).repeat_last_move_previous()
			end)
		end
	},
	{
		'glacambre/firenvim',
		build = ':call firenvim#install(0)',
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
	{ 'brianhuster/live-preview.nvim', optional = true },
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
}

if not vim.g.vscode then
	vim.list_extend(plugins_list, {
		{
			"brianhuster/direx.nvim",
			dependencies = {
				{ 'echasnovski/mini.icons', config = function() require('mini.icons').setup() end }
			},
			config = function()
				local previewer ---@type string
				if vim.fn.executable('nvcat') == 1 then
					previewer = [[nvcat -clean {}]]
				elseif vim.fn.executable('bat') == 1 then
					previewer =
					[[bat --style=numbers --color=always --paging=always --wrap=never --theme=ansi --pager=never --decorations=never {}]]
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
		'vim-jp/vimdoc-ja',
		'neovim/nvim-lspconfig',
		'b0o/SchemaStore.nvim', -- schema for Json_ls and yaml_ls
		{
			'williamboman/mason.nvim',
			config = function()
				require 'mason'.setup {}
			end
		},
		{
			'brianhuster/supermaven-nvim',
			config = function()
				require('supermaven-nvim').setup {
					keymaps = {
						accept_suggestion = "<M-CR>",
						accept_word = "<M-w>",
					},
				}
				pcall(require('supermaven-nvim.api').use_free_version)
			end
		},
		"rafamadriz/friendly-snippets",
		'tpope/vim-dadbod',
		{
			'kristijanhusak/vim-dadbod-ui',
			config = function() vim.g.db_ui_use_nerd_fonts = 1 end
		},
		'kristijanhusak/vim-dadbod-completion',
		{ 'glacambre/firenvim',          build = ":call firenvim#install(0)" },
		'mfussenegger/nvim-jdtls', -- Java development
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
		'nvim-lua/plenary.nvim', -- dependency of many plugins
		'NeogitOrg/neogit',
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
				require('dap.ext.vscode').json_decode = vim.fn.JsoncDecode
			end
		},
		{
			'igorlfs/nvim-dap-view',
			dependencies = {
				'mfussenegger/nvim-dap',
			}
		},
		{
			'theHamsta/nvim-dap-virtual-text',
			dependencies = { 'mfussenegger/nvim-dap' },
			config = function()
				require('nvim-dap-virtual-text').setup()
			end
		},
		{
			'leoluz/nvim-dap-go',
			dependencies = {
				'mfussenegger/nvim-dap',
			}
		},
		'brianhuster/treesitter-endwise.nvim',
		{ 'windwp/nvim-ts-autotag', config = function() require('nvim-ts-autotag').setup() end },
		'OXY2DEV/patterns.nvim',
		{
			'cohama/lexima.vim',
			config = function()
				vim.g.lexima_map_escape = ''
				vim.g.lexima_enable_endwise_rules = 0
				vim.g.lexima_enable_basic_rules = 0
			end
		},
		'uga-rosa/ccc.nvim',
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
			optional = true
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
		{
			'yetone/avante.nvim',
			build = 'make',
			dependencies = {
				'HakonHarnes/img-clip.nvim',
				'MunifTanjim/nui.nvim',
			},
			config = function()
				require('avante').setup {
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
				}
			end
		},
		{
			'ravitemer/mcphub.nvim',
			build = 'npm install -g mcp-hub@latest',
			config = function()
				require 'mcphub'.setup {
					extensions = {
						avante = {
							make_slash_commands = true, -- make /slash commands from MCP server prompts
						},
						config = vim.fn.expand("~/.config/mcphub/servers.json"),
						codecompanion = {
							show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
							make_vars = true, -- make chat #variables from MCP server resources
						}
					}
				}
			end
		},
		{
			'olimorris/codecompanion.nvim',
			dependencies = {
				{
					'ravitemer/mcphub.nvim',
				},
				"j-hui/fidget.nvim"
			},
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
				}
			end
		},
		"seandewar/actually-doom.nvim"
	})
end

require 'plug'.config {
	url_format = "https://github.com/%s.git",
}

require 'plug' (plugins_list)

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
