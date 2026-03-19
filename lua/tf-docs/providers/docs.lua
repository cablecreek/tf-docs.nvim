local M = {}

local config = require("tf-docs.config")
local registry = require("tf-docs.providers.registry")

local function get_basename(path)
  -- 1. Extract the filename from the path (handles / and \)
  local filename = path:match("^.*[/\\](.+)$") or path

  -- 2. Extract everything before the VERY FIRST dot
  -- %f[%.] is a frontier pattern, but simpler is matching non-dot characters
  local basename = filename:match("([^%.]+)")

  return basename or filename
end

-- Helper function to keep file I/O clean and separate
local function get_subcategory(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return "General"
  end

  local subcategory = "General"
  local line_count = 0

  for line in file:lines() do
    line_count = line_count + 1
    if line_count > 20 then
      break
    end

    local match = line:match("^subcategory:%s*[\"']?(.-)[\"']?$")
    if match then
      subcategory = match
      break
    end
  end

  file:close()
  return subcategory
end

-- create a table of the docs, used in a picker
M.get_doc_table = function(provider)
  local adaptor = registry.get(provider)
  if not adaptor then
    return {}
  end

  local base_dir = vim.fn.expand(config.options.provider_docs_install_location .. "/" .. provider)
  local cwd = base_dir .. "/" .. (adaptor.docs_root or "")
  local results = {}

  for doc_type, dir_name in pairs(adaptor.docs_layout) do
    local search_dir = cwd .. "/" .. dir_name
    local glob_pattern = "**/*" .. adaptor.file_extension
    local files = vim.fn.globpath(search_dir, glob_pattern, true, true)
    local type_emoji = adaptor.emoji_map[doc_type] or "📄"

    for _, full_path in ipairs(files) do
      local resource_name = get_basename(full_path)
      local subcategory = get_subcategory(full_path)
      local search_str = string.format("%s %s %s", doc_type, resource_name, subcategory)

      table.insert(results, {
        name = resource_name,
        type = doc_type,
        file = full_path,
        subcategory = subcategory,
        emoji = type_emoji,
        -- Using search_str allows fuzzy matching on EVERYTHING (type, name, subcat).
        text = search_str, -- 'text' key for Snacks.
        -- _search_index = search_str, -- for Telescope ordinal
      })
    end
  end

  -- Sorting logic remains the same...
  table.sort(results, function(a, b)
    if a.type ~= b.type then
      return a.type > b.type
    end
    if a.subcategory ~= b.subcategory then
      return a.subcategory < b.subcategory
    end
    return a.name < b.name
  end)

  return results
end

return M
