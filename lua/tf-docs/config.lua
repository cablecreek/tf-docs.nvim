local M = {}

--- @class tf-docs.WindowConfig
--- @field split? "right"|"left"|"above"|"below" The direction to split the current window.
--- @field float? vim.api.keyset.win_config Standard Neovim floating window options.

--- @class tf-docs.Options
--- @field providers string[] List of providers to use (e.g., {"aws", "gcp", "azure"})
--- @field provider_docs_install_location? string (default: "~/.local/share/tf-docs")
--- @field win_config tf-docs.WindowConfig Window configuration for doc viewer
--- @field picker string|function builtin pickers ("snacks", "fzf", "telescope") or parse custom function

--- @type tf-docs.Options
local defaults = {
  providers = {},
  picker = "snacks",
  provider_docs_install_location = vim.fn.stdpath("data") .. "/tf-docs",
  win_config = {
    split = "right",
    float = nil,
  },
}

--- @type tf-docs.Options
M.options = vim.deepcopy(defaults)

--- @param opts tf-docs.Options|nil
M.setup = function(opts)
  -- Merge user opts into defaults
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  local install_dir = M.options.provider_docs_install_location

  if install_dir then
    install_dir = vim.fn.expand(install_dir)
    if vim.fn.isdirectory(install_dir) == 0 then
      vim.fn.mkdir(install_dir, "p")
    end
  end
end

return M
