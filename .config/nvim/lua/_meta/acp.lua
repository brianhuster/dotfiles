---@meta

---@return string # the session id
function vim.fn.AcpNewSession() end

---@class acp.Prompt
---@field type string
---@field annotations? { audience?: ("assistant" | "user")[], lastModified?: string, priority?: number }

---@class acp.TextPrompt : acp.Prompt
---@field type "text"
---@field text string

---@class acp.BinaryPrompt : acp.Prompt
---@field type "image"|"audio"
---@field mimeType string
---@field uri? string
---@field data string

---@class acp.ResourceLinkPrompt : acp.Prompt
---@field type "resource_link"
---@field uri string
---@field name string
---@field mimeType? string

---@class acp.ResourcePrompt : acp.Prompt
---@field type "resource"
---@field resource { text: string, uri: string, mimeType?: string } | { uri: string, blob: string, mimeType?: string }

---@class acp.PromptRequest : acp.Prompt
---@field sessionId string
---@field prompt table

---@param request acp.TextPrompt|acp.BinaryPrompt|acp.ResourceLinkPrompt|acp.ResourcePrompt|acp.PromptRequest
---@return { stopReason: "cancelled" | "end_turn" | "max_tokens" | "max_turn_requests" | "refusal"}
function vim.fn.AcpPrompt(request) end
