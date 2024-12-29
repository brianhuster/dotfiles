if vim.fn.has('win32') == 1 then
	return
end

local M = {}

---Retrieve the tty name used by the editor.
---
---E.g. /dev/ttys008
---@return string|nil
local function get_tty_name()
	-- Leverage tty, which reads the terminal name
	local handle = io.popen("tty 2>/dev/null")
	if not handle then return nil end
	local result = handle:read("*a")
	handle:close()
	result = vim.trim(result)
	if result == "" then return nil end
	return result
end

local function base64_encode_file(file_path)
	local file = io.open(file_path, "r")
	if not file then return nil end
	local content = file:read("*a")
	file:close()
	return vim.base64.encode(content)
end

local TTY_NAME = assert(get_tty_name(), "failed to read editor tty name")

---Writes data to the editor tty.
---@param ... string
local function write(...)
	local handle = io.open(TTY_NAME, "w")
	if not handle then
		error("failed to open " .. TTY_NAME)
	end
	handle:write(...)
	handle:close()
end

local CODES = {
	BEL = "\x07", -- aka ^G
	ESC = "\x1B", -- aka ^[
}

local function move_cursor(col, row, save)
	-- if is_SSH and utils.tmux.is_tmux then
	--     -- When tmux is running over ssh, set-cursor sometimes doesn't actually get sent
	--     -- I don't know why this fixes the issue...
	--     utils.tmux.get_cursor_x()
	--     utils.tmux.get_cursor_y()
	-- end
	if save then write(CODES.ESC .. "[s") end
	write(CODES.ESC .. "[" .. row .. ";" .. col .. "H")
	vim.uv.sleep(1)
end

local function restore_cursor()
	write(CODES.ESC .. "[u")
end

---@class Img
local Img = {}
Img.__index = Img

---@param opts {row:number, col:number, protocol?:string, width?:number, height?:number}
---@return Img
function Img:new(opts)
	self.row = opts.row
	self.col = opts.col
	self.protocol = opts.protocol or vim.g.img_protocol or 'iterm2'
	self.width = opts.width
	self.height = opts.height
	return self
end

---@param opts? {data?:string, filename?:string}
function Img:show(opts)
	opts = opts or {}

	local data = opts.data
	if opts.filename then
		data = base64_encode_file(opts.filename)
	end

	-- Exit early if nothing to show
	if not data or string.len(data) == 0 then
		print("NO DATA")
		return
	end

	local pixelation = self.protocol or "iterm2"
	local col = self.col
	local row = self.row
	move_cursor(col, row, true)

	if pixelation == "iterm2" then
		-- NOTE: We MUST mark as inline otherwise not rendered and put in a
		--       downloads folder
		write(CODES.ESC .. "]1337")                      -- Begin sequence
		write(";File=inline=1")                          -- Display image inline
		write(self.width and ";width=" .. self.width or "") -- Set width
		write(self.height and ";height=" .. self.height or "") -- Set height
		write(";preserveAspectRatio=1")                  -- Preserve aspect ratio
		write(":" .. data)                               -- Transmit base64 data
		write(CODES.BEL)                                 -- End sequence
	elseif pixelation == "kitty" then
		local CHUNK_SIZE = 4096
		local pos = 1
		local DATA_LEN = string.len(data)

		-- For kitty, we need to write an image in chunks
		--
		--     Graphics codes are in this form:
		--
		--         <ESC>_G<control data>;<payload><ESC>\
		--
		--     To stream data for a PNG, we specify the format `f=100`.
		--
		--     To simultaneously transmit and display an image, we use `a=T`.
		--
		--     Chunking data (such as from over a network) requires the
		--     specification of `m=0|1`, where all chunks must have a
		--     value of `1` except the very last chunk.
		while pos <= DATA_LEN do
			write(CODES.ESC .. "_G") -- Begin sequence

			-- If at the beginning of our image, mark as a PNG to be
			-- transmitted and displayed immediately
			if pos == 1 then
				write("a=T,f=100,")
			end

			-- Get our specific chunk of data and increment position
			local chunk = data:sub(pos, pos + CHUNK_SIZE)
			pos = pos + CHUNK_SIZE

			-- If we are still sending chunks and not at the end
			if pos <= DATA_LEN then
				write("m=1")
			end

			-- If we have a chunk available, write it
			if string.len(chunk) > 0 then
				write(";")
				write(chunk)
			end

			write(CODES.ESC .. "\\") -- End sequence
		end
	end

	restore_cursor()
end

function Img:hide()
	local proto = self.protocol
	move_cursor(self.col, self.row, true)

	if proto == 'iterm2' then
		local bg = vim.o.bg
		vim.o.bg = bg == 'dark' and 'light' or 'dark'
		vim.o.bg = bg
	elseif proto == 'kitty' then
		-- Graphics codes are in this form:
		--
		--    <ESC>_G<control data>;<payload><ESC>\
		--
		-- a=d without other params means 'delete all'.
		write(CODES.ESC .. '_Ga=d;' .. CODES.ESC .. '\\')
	end

	restore_cursor()
end

M.Img = Img
return M
