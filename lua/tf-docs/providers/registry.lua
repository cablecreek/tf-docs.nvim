local M = {}

local logging = require("tf-docs.logging")

---@class tf-docs.Adaptor
---@field repo_url string provider remote repo url
---@field search_title string telescope title
---@field is_legacy_docs  boolean? does the provider use 1.legacy = "website/docs/" with "r" and "d" or 2. current structure "docs/" with "resource" and "data"
---@field docs_layout table
---@field docs_root string
---@field file_extension string
---@field emoji_map table

local default_emojis = {
  ["resource"] = "📦",
  ["data"] = "🔍",
  ["guides"] = "📖",
}

M.providers = {
  --- mock provider repos for testing
  ["tf-docs"] = "tf-docs.providers.tfdocs_current",
  ["tf-docs-legacy"] = "tf-docs.providers.tfdocs_legacy",

  -- providers
  ["aws"] = "tf-docs.providers.hashicorp_aws",
  ["k8s"] = "tf-docs.providers.hashicorp_k8s",
  ["gcp"] = "tf-docs.providers.hashicorp_gcp",
}

local function get_doc_layout()
  local doc_layout = {
    ["current"] = {
      ["resource"] = "resources",
      ["data"] = "data-sources",
    },
    ["legacy"] = {
      ["resource"] = "r",
      ["data"] = "d",
    },
  }

  local shared = { "actions", "ephemeral-resources", "guides", "list-resources", "functions" }

  for _, layout in pairs(doc_layout) do
    for _, item in ipairs(shared) do
      layout[item] = item
    end
  end

  return doc_layout
end

---@param provider string
---@return tf-docs.Adaptor|nil
M.get = function(provider)
  local path = M.providers[provider]

  if path then
    local adaptor = require(path)
    local docs_layout = get_doc_layout()

    -- Set layout and root
    if adaptor.is_legacy_docs then
      adaptor.docs_root = "website/docs" -- legacy tf provider doc path
      adaptor.docs_layout = docs_layout["legacy"]
    else
      adaptor.docs_root = "docs" -- current tf provider doc path
      adaptor.docs_layout = docs_layout["current"]
    end

    -- Set defaults to simplify downstream logic
    adaptor.file_extension = adaptor.file_extension or ".html.markdown"
    adaptor.emoji_map = default_emojis

    return adaptor
  end

  logging.warn("provider not found: " .. tostring(provider))
  return nil
end

return M
