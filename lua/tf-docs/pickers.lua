local M = {}

local view = require("tf-docs.view")
local config = require("tf-docs.config")
local docs = require("tf-docs.providers.docs")

---@param picker "telescope"|"fzf"|"snacks"
M.get = function(picker)
  -- Check if user defined a literal picker function in config
  if type(config.options.picker) == "function" then
    return config.options.picker
  end

  local p = {
    ["telescope"] = M.telescope,
    ["fzf"] = M.fzf_lua,
    ["snacks"] = M.snacks,
  }

  local name = picker or config.options.picker
  local selected = p[name]

  if not selected then
    error(string.format("tf-docs: Picker '%s' is not valid or not found.", tostring(name)))
  end

  return selected
end

M.telescope = function(provider)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  pickers
    .new({}, {
      prompt_title = "Telescope: " .. provider,
      finder = finders.new_table({
        results = docs.get_doc_table(provider),
        entry_maker = function(entry)
          return {
            value = entry,
            display = string.format("%s %-9s %-45s %s", entry.emoji, entry.type, entry.name, entry.subcategory or ""),
            ordinal = entry.text,
          }
        end,
      }),
      sorter = conf.generic_sorter(),
      attach_mappings = function(prompt_bufnr)
        local actions = require("telescope.actions")
        actions.select_default:replace(function()
          local selection = require("telescope.actions.state").get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            view.open(selection.value.file)
          end
        end)
        return true
      end,
    })
    :find()
end

M.fzf_lua = function(provider)
  local fzf = require("fzf-lua")
  local items = docs.get_doc_table(provider)

  local contents = vim.tbl_map(function(item)
    return string.format("%s %s | %s", item.emoji, item.type, item.name)
  end, items)

  fzf.fzf_exec(contents, {
    prompt = "fzf-lua> ",
    actions = {
      ["default"] = function(selected)
        local name = selected[1]:match("|%s*(.-)%s*$")
        for _, item in ipairs(items) do
          if item.name == name then
            view.open(item.file)
            break
          end
        end
      end,
    },
  })
end

M.snacks = function(provider)
  require("snacks").picker.pick({
    source = "Terraform Docs",
    items = docs.get_doc_table(provider),
    preview = "file",
    format = function(item)
      return {
        { item.emoji, "SnacksPickerEmoji" },
        { " " .. (item.type or ""), "SnacksPickerComment" },
        { " " .. (item.name or ""), "SnacksPickerLabel" },
        { " " .. (item.subcategory or ""), "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        view.open(item.file)
      end
    end,
  })
end

return M
