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
	vim.validate('items', items, 'table')
	vim.validate('opts', opts, 'table')
  	vim.validate('on_choice', on_choice, 'function')

	local title = opts.prompt or "Select item"
	local width = 0
	local au = api.nvim_create_autocmd

	for i, item in ipairs(vim.list_extend({ title }, items)) do
		local item_text = tostring(i > 1 and opts.format_item and opts.format_item(item) or item)
		width = math.max(width, #item_text)
	end

	width = width + 4

	local buf = api.nvim_create_buf(false, true)

	local win = api.nvim_open_win(buf, true, {
		relative = 'editor',
		style = 'minimal',
		border = 'rounded',
		width = width,
		height = 1,
		row = math.floor((vim.o.lines - 1) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		title = title,
		title_pos = 'center',
		noautocmd = true
	})
	vim.cmd.startinsert()
	vim.wo[win].number = false

	local comp_items = {} ---@type { word: string, user_data: string }[]
	for i, _ in ipairs(items) do
		comp_items[i] = {
			word = opts.format_item and opts.format_item(items[i]) or tostring(items[i]),
			user_data = items[i]
		}
	end

	local function close_picker()
		vim.cmd.stopinsert()
		api.nvim_win_hide(win)
	end

	local function complete()
		local line = vim.fn.getline('.')
		if #vim.trim(line) == 0 then return vim.fn.complete(1, comp_items) end
		vim.fn.complete(1, vim.fn.matchfuzzy(comp_items, line, { key = 'word' }))
	end

	vim.bo[buf].completeopt = "menu,menuone,noinsert,noselect,popup,fuzzy"
	vim.bo[buf].buftype = 'nofile'

	vim.keymap.set({'n', 'i'}, '<Esc>', close_picker, { buffer = buf })

	au("InsertEnter", { buffer = buf, callback = vim.schedule_wrap(complete) })
	au("WinLeave", { buffer = buf, callback = close_picker })
	au({"TextChangedI"}, { buffer = buf, callback = vim.schedule_wrap(complete) })
	au("CompleteDonePre", { buffer = buf, callback = function()
		local selected = vim.fn.complete_info().selected
		if selected == -1 then return complete() end
		selected = selected + 1
		close_picker()
		on_choice(comp_items[selected].user_data, selected)
	end })
end

return M
