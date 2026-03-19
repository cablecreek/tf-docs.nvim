local M = {}

---@param opts tf-docs.Options
M.setup = function(opts)
  local config = require("tf-docs.config")
  local install = require("tf-docs.install")

  config.setup(opts)

  vim.schedule(function()
    install.lazy_installer()
  end)
end

return M
