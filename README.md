# tf-docs.nvim
> [!WARNING] 
> tf-docs is relativley experimental, specifically around the the install mechanism
> feel free to try it out, but note that `~.local/shares/nvim/tf-docs` will be a mess...

Terraform provider documentation *inside* nvim  

## ✨ Features
1. Lazy install, update, and removal of provider docs
2. Search terraform provider docs inside nvim
3. Multi-picker options (`telescope.nvim`, `snacks`, `fzf-lua`, or BYO)
4. Cofigurable display
5. Extensible provider structure 

## ⚡️ Requirements
- `nvim`
- `git`
- nvim file picker (`snacks`, `telescope`, `fzf-lua`)

## 📦 Installation
`lazy.nvim` minimal install with defaults
```lua
{
  'cablecreek/tf-docs',
  dependencies = {
    'folke/snacks.nvim',
  },
  opts = {
    providers = {
      -- add providers to install here
      -- 'aws', 'gcp', 'k8s',
    },
  },
}

```

## ⚙️ Configuration/Options 
`tf-docs` comes with defaults however, you are able to customise: 
1. picker
2. window config

```lua
-- default options
opts = {
  providers = {},
  picker = "snacks", -- "telescope", "fzf", "snacks", or BYO <function>
  provider_docs_install_location = vim.fn.stdpath("data") .. "/tf-docs", -- ~/.local/share/nvim/
  -- either a `split` or `float`
  win_config = {
    split = "right", -- "right"|"left"|"above"|"below" The direction to split the current window.
    float = nil, -- is a `vim.api.keyset.win_config` type i.e. width, height, border, etc. 
  },
}

-- Telescope + floating window
opts = {
  providers = {},
  picker = "telescope", 
  win_config = {
    float = {
      relative = "editor",
      width = 80,
      height = 20,
      row = 10,
      col = 10,
      border = "rounded",
    },
  },
}

-- fzf + split below
opts = {
  providers = {},
  picker = "fzf", 
  win_config = {
    split = "below",
  },
}

```

## functions
```lua
TFDocs <provider> -- opens picker and browsing docs
TFDocsLazy -- lazy install + update + remove providers
TFDocsSearch <provider> <type> <resource> -- opens doc in view
TFDocsAll <provider> -- table of all docs for a given provider (helpful for custom pickers)
```

## Custom picker
- inside the `setup.opts` assign `picker = my_picker`
- where `local my_picker = function(provider)`
- `TFDocsAll <provider>` returns a table with details on the docs

```lua
-- custom picker 
local view = require("tf-docs.view")
local config = require("tf-docs.config")
local docs = require("tf-docs.providers.docs")

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

opts = {
  providers = {},
  picker = "fzf", 
}

`
``` 
## Supported Providers
| provider | repo | 
| :--- |  ---: |
|`aws`| https://github.com/hashicorp/terraform-provider-aws |
| `gcp` | https://github.com/hashicorp/terraform-provider-google |
| `k8s` | https://github.com/hashicorp/terraform-provider-kubernetes | 

- PR's for providers are always welcome!

## TODO
- [ ] update mechanism fails
- [ ] nvim docs
- [ ] uninstall tidy up
- [ ] add a few other providers:
  - [ ] https://github.com/hashicorp/terraform-provider-azurerm
  - [ ] https://github.com/hashicorp/terraform-provider-helm
- [ ] finish tests
  - [x] config
  - [ ] view
  - [ ] install <- how to handle async install?
  - [x] pickers 
  - [ ] providers_docs <- get install working first
  - [x] providers_registry
  - [x] search
- [ ] check custom opts examples are working
- [ ] ensure `update` has a long term stability

## ideas
- [ ] search for under cursor (like gd, gr, etc.), need to also account for the "resource" or "data" resource 
- [ ] refine install tests (i.e. actually pull the repo and wait until done)
- [ ] parse a custom + private repo from the `opts.provider`
- [ ] command for listing available providers to install?
- [ ] yaml frontmatter is optional but often used, may hit an issue here...

