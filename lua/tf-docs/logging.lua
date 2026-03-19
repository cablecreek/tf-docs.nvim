local M = {}

-- Helper to wrap notifications safely for background tasks
local function safe_notify(msg, level)
  vim.schedule(function()
    vim.notify("tf-docs: " .. msg, level)
  end)
end

M.info = function(msg)
  safe_notify(msg, vim.log.levels.INFO)
end

M.warn = function(msg)
  safe_notify(msg, vim.log.levels.WARN)
end

M.err = function(msg)
  safe_notify(msg, vim.log.levels.ERROR)
end

return M
