local M = {}

local logging = require("tf-docs.logging")

local default_emojis = {
  ["resource"] = "📦",
  ["data"] = "🔍",
  ["guides"] = "📖",
}

-- register new providers here
M.providers = {
  ["aap"] = "tf-docs.providers.hashicorp_aap",
  ["ad"] = "tf-docs.providers.hashicorp_ad",
  ["archive"] = "tf-docs.providers.hashicorp_archive",
  ["aws"] = "tf-docs.providers.hashicorp_aws",
  ["awscc"] = "tf-docs.providers.hashicorp_awscc",
  ["azuread"] = "tf-docs.providers.hashicorp_azuread",
  ["azurerm"] = "tf-docs.providers.hashicorp_azurerm",
  ["azurestack"] = "tf-docs.providers.hashicorp_azurestack",
  ["boundary"] = "tf-docs.providers.hashicorp_boundary",
  ["cloudinit"] = "tf-docs.providers.hashicorp_cloudinit",
  ["consul"] = "tf-docs.providers.hashicorp_consul",
  ["dns"] = "tf-docs.providers.hashicorp_dns",
  ["external"] = "tf-docs.providers.hashicorp_external",
  ["google"] = "tf-docs.providers.hashicorp_google",
  ["google-beta"] = "tf-docs.providers.hashicorp_google_beta",
  ["helm"] = "tf-docs.providers.hashicorp_helm",
  ["hcs"] = "tf-docs.providers.hashicorp_hcs",
  ["hcp"] = "tf-docs.providers.hashicorp_hcp",
  ["http"] = "tf-docs.providers.hashicorp_http",
  ["ibm"] = "tf-docs.providers.ibm_ibm",
  ["instana"] = "tf-docs.providers.instana_instana",
  ["kubernetes"] = "tf-docs.providers.hashicorp_kubernetes",
  ["local"] = "tf-docs.providers.hashicorp_local",
  ["nomad"] = "tf-docs.providers.hashicorp_nomad",
  ["null"] = "tf-docs.providers.hashicorp_null",
  ["ode"] = "tf-docs.providers.ibm_ode",
  ["random"] = "tf-docs.providers.hashicorp_random",
  ["scalr"] = "tf-docs.providers.scalr_scalr",
  ["template"] = "tf-docs.providers.hashicorp_template",
  ["tfe"] = "tf-docs.providers.hashicorp_tfe",
  ["tfmigrate"] = "tf-docs.providers.hashicorp_tfmigrate",
  ["time"] = "tf-docs.providers.hashicorp_time",
  ["tls"] = "tf-docs.providers.hashicorp_tls",
  ["turbonomic"] = "tf-docs.providers.ibm_turbonomic",
  ["vault"] = "tf-docs.providers.hashicorp_vault",
  ["oci"] = "tf-docs.providers.oracle_oci",
  ["alicloud"] = "tf-docs.providers.aliyun_alicloud",
}

-- Cache of constructed provider adaptors keyed by adaptor name.
M.adaptors = {}

-- construct the standard layouts for current and legacy docs
local doc_layout = (function()
  local layout = {
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

  for _, l in pairs(layout) do
    for _, item in ipairs(shared) do
      l[item] = item
    end
  end

  return layout
end)()

local function apply_defaults(adaptor)
  if adaptor.is_legacy_docs then
    adaptor._docs_root = "website/docs"
    adaptor._docs_layout = doc_layout["legacy"]
  else
    adaptor._docs_root = "docs"
    adaptor._docs_layout = doc_layout["current"]
  end

  adaptor.file_extension = adaptor.file_extension or ".html.markdown"
  adaptor._emoji_map = default_emojis

  return adaptor
end

-- Run on setup to prebuild adaptor tables from user configuration.
-- `spec` may be either:
-- - built-in provider name (string), e.g. "aws"
-- - custom provider adaptor table, which must include `name`
---@param provider_specs (string|tf-docs.ProviderAdaptor)[]
M.setup_adaptors = function(provider_specs)
  M.adaptors = {}

  for _, spec in ipairs(provider_specs or {}) do
    local name
    local raw

    if type(spec) == "string" then
      name = spec -- required so we can key the adaptor
      local provider_module_path = M.providers[name]

      if type(provider_module_path) ~= "string" then
        logging.warn("provider not found: " .. tostring(name))
      else
        raw = require(provider_module_path)
      end
    elseif type(spec) == "table" then
      name = spec.name

      if type(name) ~= "string" or name == "" then
        logging.warn("custom provider adaptor is missing required field 'name'")
      else
        raw = spec
      end
    else
      logging.warn("invalid provider - expected string or table")
    end

    if name and type(raw) == "table" then
      local adaptor = apply_defaults(vim.tbl_extend("force", {}, raw))
      adaptor.name = name
      M.adaptors[name] = adaptor
    end
  end
end

---@param name string Built-in provider key or custom provider adaptor name
---@return tf-docs.ProviderAdaptor|nil
M.get = function(name)
  if type(name) ~= "string" then
    logging.warn("provider name must be a string, got: " .. tostring(name))
    return nil
  elseif M.adaptors[name] then
    return M.adaptors[name]
  else
    logging.warn("provider not found: " .. tostring(name))
    return nil
  end
end

return M
