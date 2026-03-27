local M = {}

local registry = require("tf-docs.registry")
local search = require("tf-docs.search")
local logging = require("tf-docs.logging")

--- Parse a Terraform resource identifier to extract provider and resource name.
--- Iterates over configured providers and checks if word starts with '<provider>_'.
---
--- @param word string e.g., "github_repository", "aws_s3_bucket"
--- @return string|nil provider The matched provider name
--- @return string|nil resource The resource name (everything after provider_)
local function parse_resource_identifier(word)
  if not word or word == "" then
    return nil, nil
  end

  for provider_name, _ in pairs(registry.adaptors) do
    local prefix = provider_name .. "_"
    if word:sub(1, #prefix) == prefix then
      local resource = word:sub(#prefix + 1)
      return provider_name, resource
    end
  end

  return nil, nil
end

--- Detect the block type (resource/data) by searching backwards from cursor.
---
--- @return string|nil block_type "resource", "data", or nil if not found
local function detect_block_type()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local max_lines_to_search = 100

  for i = cursor_line, math.max(1, cursor_line - max_lines_to_search), -1 do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if line then
      local block_type = line:match('^%s*(resource)%s+"') or line:match('^%s*(data)%s+"')
      if block_type then
        return block_type
      end
    end
  end

  return nil
end

--- Main function: look up docs for the Terraform resource under cursor.
M.lookup = function()
  local word = vim.fn.expand("<cword>")

  if not word or word == "" then
    logging.err("No word under cursor")
    return
  end

  local provider, resource = parse_resource_identifier(word)

  if not provider then
    logging.err("Could not determine provider from: " .. word)
    return
  end

  local block_type = detect_block_type()

  if not block_type then
    logging.err("Could not determine block type (resource/data)")
    return
  end

  search.search(provider, block_type, resource)
end

return M
