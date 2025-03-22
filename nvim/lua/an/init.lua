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
		height = 1,
		row = math.floor((vim.o.lines - 1) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		title = title,
		title_pos = 'center',
		noautocmd = true
	})
	vim.cmd.startinsert()
	vim.wo[win].number = false

	for i, _ in ipairs(items) do
		items[i] = {
			word = opts.format_item and opts.format_item(items[i]) or tostring(items[i]),
			user_data = {
				key = i,
				item = items[i]
			}
		}
	end

	---@param w integer
	---@param b integer
	local function close_picker(w, b)
		api.nvim_win_close(w, true)
		api.nvim_buf_delete(b, { force = true })
		vim.cmd.stopinsert()
	end

	M.select_omnifunc = function(find_start, base)
		if find_start == 1 then
			return 0
		end
		if not base or base == "" then
			return items
		end
		return vim.fn.matchfuzzy(items, base, { key = 'word' })
	end
	vim.bo[buf].omnifunc = "v:lua.require'an'.select_omnifunc"
	vim.bo[buf].completeopt = "menu,menuone,noinsert,noselect,popup"

	vim.keymap.set('i', '<Esc>', function()
		close_picker(win, buf)
	end, { buffer = buf })

	api.nvim_feedkeys(vim.keycode("<C-x><C-o>"), "n", false)

	au("WinLeave", { buffer = buf, callback = function()
		close_picker(win, buf)
	end })
	au("TextChangedI", { buffer = buf, callback = function()
		api.nvim_feedkeys(vim.keycode("<C-x><C-o>"), "n", false)
	end })
	au("CompleteDonePre", { buffer = buf, callback = function()
		if vim.v.completed_item == vim.empty_dict() then
			return
		end
		close_picker(win, buf)
		on_choice(vim.v.completed_item.user_data.item, vim.v.completed_item.user_data.key)
	end })
end

M.select_omnifunc = nil ---@type fun(find_start: number, base: string): number|table

return M
