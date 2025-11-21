local M = {}

---@param jsonc_string string The JSONC string to decode
---@return table|nil Decoded table or nil on error
function M.decode(jsonc_string)
	local ts = vim.treesitter
	local parser = ts.get_string_parser(jsonc_string, "jsonc")
	local tree = parser:parse()[1]
	local root = tree:root()

	local query = ts.query.parse("jsonc", [[
		(comment) @comment
		(ERROR) @error
	]])

	local ranges_to_remove = {}
	for _, node, _ in query:iter_captures(root, jsonc_string) do
		local start_row, start_col, end_row, end_col = node:range()
		table.insert(ranges_to_remove, {
			start_row = start_row,
			start_col = start_col,
			end_row = end_row,
			end_col = end_col,
		})
	end
	
	table.sort(ranges_to_remove, function(a, b)
		if a.start_row == b.start_row then
			return a.start_col > b.start_col
		end
		return a.start_row > b.start_row
	end)
	
	local lines = vim.split(jsonc_string, "\n", { plain = true })
	
	for _, range in ipairs(ranges_to_remove) do
		local start_row = range.start_row + 1  -- Convert to 1-indexed
		local start_col = range.start_col + 1
		local end_row = range.end_row + 1
		local end_col = range.end_col
		
		if start_row == end_row then
			local line = lines[start_row]
			lines[start_row] = line:sub(1, start_col - 1) .. line:sub(end_col + 1)
		else
			local first_line = lines[start_row]:sub(1, start_col - 1)
			local last_line = lines[end_row]:sub(end_col + 1)
			lines[start_row] = first_line .. last_line
			
			for i = end_row, start_row + 1, -1 do
				table.remove(lines, i)
			end
		end
	end
	
    local json_string = table.concat(lines, "\n")

	return vim.json.decode(json_string)
end

return M
