local vim = vim

if vim.loader then
    vim.loader.enable()
end

vim.cmd [[
	if exists("g:vscode")
		let g:clipboard = g:vscode_clipboard
	endif

	"set rtp+=/media/brianhuster/D/Projects/agent-chat.nvim

	if &grepprg[:2] == 'rg '
		"let &grepprg .= '--max-columns=100 '
		let &grepprg .= '-j1 '
	endif
	set exrc

	let g:loaded_netrw = 1
	let g:loaded_netrwPlugin = 1

	au UIEnter * set clipboard=unnamedplus
	au TermOpen * setl nonumber norelativenumber | startinsert
	if getfsize($NVIM_LOG_FILE) > pow(1024, 3)
		call delete($NVIM_LOG_FILE)
	endif

	"" Prompt buffer acp.nvim
	"au FileType acpchat inoremap <buffer> <CR> <S-CR>
	"au FileType acpchat nnoremap <buffer> <C-c> i<C-c><Esc>

	packadd nvim.difftool
	packadd nvim.undotree
]]

local api = vim.api
local map = vim.keymap.set

vim.lsp.config.lua_ls = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { 'lua' },
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = {
					'lua/?.lua',
					'lua/?/init.lua'
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				}
			}
		}
	},
}

vim.lsp.enable("lua_ls")

map('i', '<M-CR>', function()
	vim.lsp.inline_completion.get()
end)

map('i', '<M-s>', function()
	vim.lsp.inline_completion.select()
end)

vim.keymap.set('i', '<M-n>', '<Plug>(nomplete)')

api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
		if vim.lsp.document_color and client:supports_method('textDocument/documentColor') then
			vim.lsp.document_color.enable(true, args.buf, { style = 'virtual' })
		end
	end,
})

vim.keymap.set('n', 'grs', function() vim.lsp.buf.workspace_symbol() end, { desc = 'Select LSP workspace symbol' })

vim.cmd "au LspProgress * redrawstatus"

vim.diagnostic.config {
	virtual_lines = {
		current_line = true
	},
	underline = true
}

vim.lsp.inlay_hint.enable()
vim.lsp.inline_completion.enable()
vim.lsp.linked_editing_range.enable()
vim.lsp.on_type_formatting.enable()

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

vim.g.acp = {
    agents = {
        gemini = {
            cmd = { 'gemini', '--experimental-acp' },
            mcp = true
		},
        opencode = {
            cmd = { 'opencode', 'acp' },
            mcp = true
        },
        goose = {
            cmd = { 'goose', 'acp' },
            mcp = true
		}
    },
    mcp = {
        nvim = {
			cmd = { 'nvim-mcp' },
            env = {
				NVIM = vim.v.servername
			}
		}
	}
}

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
	github 'brianhuster/nomplete.vim',
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
		build = function() vim.cmd.TSUpdate("all") end,
	},
	github 'nvim-treesitter/nvim-treesitter-context',
	{
		src = github 'nvim-treesitter/nvim-treesitter-textobjects',
		version = 'main',
	},
	{
		src = github 'glacambre/firenvim',
		build = function() vim.fn["firenvim#install"](0) end,
	},
	github 'brianhuster/live-preview.nvim',
	github 'folke/which-key.nvim',
	github 'echasnovski/mini.clue',
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
	github 'olimorris/codecompanion.nvim',
    github 'seandewar/actually-doom.nvim',
}

vim.lsp.config.basics_ls = {
	cmd = { "basics-language-server" },
	settings = {
		buffer = {
			enable = false
		},
		path = {
			enable = true
		},
		snippet = {
			enable = true,
			sources = { vim.fs.joinpath(vim.fn.stdpath('data'),  'site/pack/core/opt/friendly-snippets/package.json') }
		}
	}
}

vim.lsp.config.yaml_ls = {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
	root_markers = { '.git' },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = "",
			},
			schemas = require('schemastore').yaml.schemas(),
		},
	},
}

vim.lsp.config.json_ls = {
	cmd = { 'vscode-json-language-server', '--stdio' },
	filetypes = { 'json', 'jsonc' },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { '.git' },
	settings = {
		json = {
			schemas = require('schemastore').json.schemas(),
			validate = { enable = true },
		},
	},
}

vim.lsp.enable {
	"basics_ls",
	"jsonls",
	'yamlls',
	"dockerls",
	"bashls",
	"clangd",
	"cssls", "tailwindcss", "html", "ts_ls",
	'jdtls',
	"marksman",
	"pylsp",
	"vue_ls",
	"vimls",
	"gopls",
	"copilot"
}

exec(require 'mini.jump2d'.setup, {
	mappings = {
		start_jumping = '<Leader>j',
	}
})

exec(require 'nvim-treesitter'.install, 'stable')
exec(require 'nvim-treesitter'.install, 'unstable')

exec(require 'codecompanion'.setup)

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
	require('dap.ext.vscode').json_decode = require('an.jsonc').decode
end)

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

local dap = require("dap")
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
local dap = require("dap")
dap.configurations.c = {
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args = {}, -- provide arguments if needed
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Select and attach to process",
    type = "gdb",
    request = "attach",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    pid = function()
      local name = vim.fn.input('Executable name (filter): ')
      return require("dap.utils").pick_process({ filter = name })
    end,
    cwd = '${workspaceFolder}'
  },
  {
    name = 'Attach to gdbserver :1234',
    type = 'gdb',
    request = 'attach',
    target = 'localhost:1234',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}'
  }
}
