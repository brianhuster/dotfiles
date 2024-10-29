return {
	"Exafunction/codeium.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		enable_chat = true,
		enable_cmp_source = false,
		virtual_text = {
			enabled = true,
			manual = false,
			key_bindings = {
				accept = "<M-CR>",
			}
		}
	}
}
