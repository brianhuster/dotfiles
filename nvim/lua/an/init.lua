local M = {}

local api = vim.api

---@param shortcut string
---@param triggers string[]
function M.ins_autocomplete(shortcut, triggers)
	if vim.fn.pumvisible() == 1 or vim.fn.state('m') == 'm' then
		return
	end
	local char = vim.v.char
	if vim.list_contains(triggers, char) then
		shortcut = vim.keycode(shortcut)
		api.nvim_feedkeys(shortcut, 'm', false)
	end
end

---Prompts the user to pick from a list of items, allowing arbitrary
---(potentially asynchronous) work until `on_choice`.
---
---@generic T
---@param items T[] Arbitrary items
---@param opts { prompt: string?, format_item: function?, kind: string? } Additional options
---     - prompt (string|nil)
---               Text of the prompt. Defaults to `Select one of:`
---     - format_item (function item -> text)
---               Function to format an
---               individual item from `items`. Defaults to `tostring`.
---     - kind (string|nil)
---               Arbitrary hint string indicating the item shape.
---               Plugins reimplementing `vim.ui.select` may wish to
---               use this to infer the structure or semantics of
---               `items`, or the context in which select() was called.
---@param on_choice fun(item: T|nil, idx: integer|nil)
---               Called once the user made a choice.
---               `idx` is the 1-based index of `item` within `items`.
---               `nil` if the user aborted the dialog.
function M.select(items, opts, on_choice)
	opts = opts or {}
	local title = opts.prompt or "Select item"
	local width = 0
	local height = #items

	for _, item in ipairs(items) do
		local item_text = tostring(opts.format_item and opts.format_item(item) or item)
		width = math.max(width, #item_text)
	end

	width = width + 4

	local buf = api.nvim_create_buf(false, true)

	local win = api.nvim_open_win(buf, true, {
		relative = 'editor',
		style = 'minimal',
		border = 'rounded',
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		title = title,
		title_pos = 'center',
		noautocmd = true
	})

	local content = {}
	for i, item in ipairs(items) do
		local item_text = tostring(opts.format_item and opts.format_item(item) or item)
		content[i] = " " .. item_text
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, content)
	local ns_id = api.nvim_create_namespace('popup_select')

	local function nmap(lhs, rhs)
		vim.keymap.set('n', lhs, rhs, { buffer = buf })
	end

	local function highlight_selected()
		api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
		api.nvim_buf_set_extmark(buf, ns_id, vim.api.nvim_win_get_cursor(win)[1] - 1, 0, {
			line_hl_group = 'PmenuSel',
			priority = 100
		})
	end

	nmap('<CR>', function()
		local selected_index = api.nvim_win_get_cursor(win)[1]
		local selected_item = items[selected_index]
		api.nvim_win_close(win, true)
		on_choice(selected_item, selected_index)
	end)
	nmap('<Esc>', function()
		api.nvim_win_close(win, true)
		on_choice(nil, nil)
	end)

	highlight_selected()
	api.nvim_create_autocmd("CursorMoved", { buffer = buf, callback = highlight_selected })
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].readonly = true
	vim.bo[buf].modifiable = false
end

return M
