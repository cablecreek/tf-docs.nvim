-- specific search of resource <provider> <type> <resource>
vim.api.nvim_create_user_command("TFDocsSearch", function(opts)
  if #opts.fargs ~= 3 then
    require("tf-docs.logging").err("3 args required: TFDocs <provider> <type> <resource>")
    return
  end
  local provider = opts.fargs[1]
  local type = opts.fargs[2]
  local resource = opts.fargs[3]

  local search = require("tf-docs.search")
  search.search(provider, type, resource)
end, {
  nargs = "+",
  desc = "Open Terraform documentation for a provider + type + resource",
})

-- browse with a picker
vim.api.nvim_create_user_command("TFDocs", function(opts)
  if #opts.fargs ~= 1 then
    require("tf-docs.logging").err("1 arg required: TFDocs <provider>")
    return
  end

  local config = require("tf-docs.config")
  local provider = opts.fargs[1]
  local picker = require("tf-docs.pickers").get(config.picker)
  picker(provider)
end, {
  nargs = "+",
  desc = "Open Terraform documentation for a provider",
})

-- lookup docs for resource under cursor
vim.api.nvim_create_user_command("TFDocsUnderCursor", function()
  require("tf-docs.cursor").lookup()
end, {
  desc = "Open Terraform documentation for the resource under cursor",
})
