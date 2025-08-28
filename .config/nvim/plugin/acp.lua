local chat_buf = -1
local api = vim.api

vim.api.nvim_create_user_command("AgentChat", function()
	if api.nvim_buf_is_valid(chat_buf) then
		 vim.cmd("vsplit | buffer " .. chat_buf)
	else
		vim.cmd("vsplit | enew")
		chat_buf = api.nvim_get_current_buf()
		vim.bo[chat_buf].buftype = "prompt"
		vim.bo[chat_buf].filetype = "markdown"
		vim.fn.AcpInit()
		vim.b.agent_session = vim.fn.AcpNewSession()
		vim.fn.prompt_setcallback(chat_buf, function(input)
			vim.fn.append(vim.fn.line("$"), "> " .. input)
			vim.fn.AcpPrompt { sessionId = vim.b.agent_session, text = input, type = "text" }
		end)
	end
end, { nargs = 0, desc = "Open AI chat buffer" })
