local M = {}

-- Hàm trợ giúp escape chuỗi cho JSON
local function escape_str(s)
	return s:gsub([[\]], [[\\]]):gsub('"', [[\"]])
end

-- Hàm định dạng giá trị (sử dụng đệ quy)
local function format_value(v, indent, current_indent)
	local t = type(v)
	if t == "table" then
		local is_arr = vim.islist(v)
		local items = {}
		if is_arr then
			for _, item in ipairs(v) do
				table.insert(items, format_value(item, indent, current_indent .. indent))
			end
			return "[\n" .. current_indent .. indent
				.. table.concat(items, ",\n" .. current_indent .. indent) .. "\n"
				.. current_indent .. "]"
		else
			local keys = {}
			for k, _ in pairs(v) do
				table.insert(keys, k)
			end
			table.sort(keys)
			for _, k in ipairs(keys) do
				local key_str = '"' .. escape_str(tostring(k)) .. '"'
				local val_str = format_value(v[k], indent, current_indent .. indent)
				table.insert(items, current_indent .. indent .. key_str .. ": " .. val_str)
			end
			return "{\n" .. table.concat(items, ",\n") .. "\n" .. current_indent .. "}"
		end
	elseif t == "string" then
		return '"' .. escape_str(v) .. '"'
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif v == nil then
		return "null"
	else
		return '"' .. escape_str(tostring(v)) .. '"'
	end
end

--- Hàm định dạng JSON (chuỗi hoặc table) theo tham số
--- @param obj string|table
--- @param params table bảng tham số với các key:
--               use_tabs (boolean): sử dụng tab nếu true, mặc định false
--               indent (number): số khoảng trắng cho thụt lề, mặc định 2
--               indent_base (string): chuỗi thụt lề ban đầu (prefix)
--- @return string Chuỗi JSON đã được format
function M.format(obj, params)
	params = params or {}
	local use_tabs = params.use_tabs or false
	local indent = use_tabs and "\t" or string.rep(" ", params.indent or 2)
	local indent_base = params.indent_base or ""

	local decoded
	if type(obj) == "string" then
		local status, res = pcall(vim.fn.json_decode, obj)
		if status then
			decoded = res
		else
			decoded = obj
		end
	else
		decoded = obj
	end

	return format_value(decoded, indent, indent_base)
end

--- Hàm định dạng JSON trong buffer theo khoảng dòng đã chọn
--- @param line1 number Số dòng bắt đầu (1-indexed)
--- @param line2 number Số dòng kết thúc (1-indexed)
function M.format_range(line1, line2)
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
	local json_src = table.concat(lines, "")
	-- Lấy chuỗi thụt dòng đầu tiên của dòng đầu (để giữ lại indent ban đầu)
	local indent_base = lines[1]:match("^(%s*)") or ""
	local params = {
		use_tabs = not vim.o.expandtab,
		indent = vim.o.shiftwidth,
		indent_base = indent_base,
	}
	local formatted = M.format(json_src, params)
	local formatted_lines = {}
	for line in formatted:gmatch("[^\n]+") do
		table.insert(formatted_lines, line)
	end
	vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, formatted_lines)
end

--- Hàm dùng cho 'formatexpr'
-- Gọi từ chế độ format (ví dụ với gq) sẽ định dạng vùng hiện tại
function M.formatexpr()
	local line = vim.v.lnum
	local count = vim.v.count
	M.format_range(line, line + count - 1)
	return 0
end

return M
