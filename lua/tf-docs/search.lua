local config = require("tf-docs.config")
local registry = require("tf-docs.providers.registry")
local logging = require("tf-docs.logging")
local view = require("tf-docs.view")

M = {}

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

---@param provider string as per providor adaptor (aws, gcp, etc.)
---@param doc_type "resource"|"data"|"guide"|"actions"|"ephemeral-resources"|"guides"|"list-resources"|"functions"
---@param resource string the name of the tf arg
--
--
M.search = function(provider, doc_type, resource)
  local adaptor = registry.get(provider)
  if not adaptor then
    return nil
  end

  local cwd = vim.fn.expand(config.options.provider_docs_install_location .. "/" .. provider)
  if adaptor.docs_root then
    cwd = cwd .. "/" .. adaptor.docs_root
  end

  local type_path = adaptor["docs_layout"][doc_type]
  if not type_path then
    logging.warn("type not found: " .. doc_type)
    return nil
  end

  local path = vim.fs.normalize(cwd .. "/" .. type_path .. "/" .. resource .. adaptor.file_extension)

  if file_exists(path) then
    view.open(path)
  else
    logging.err("file does not exist or does not have permissions to open. " .. path)
    return nil
  end
end

return M
