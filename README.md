# tf-docs.nvim

Terraform provider documentation *inside* nvim - simple & fast

## ✨ Features
1. Lazy install, update, and removal of provider docs
2. Search terraform provider docs inside nvim
3. Extensible provider layout & custom providers
4. Multi-picker options (`telescope.nvim`, `snacks`, `fzf-lua`, or BYO)
5. Cofigurable docs display

## ⚡️ Requirements
- `nvim`
- `git`
- nvim file picker (`snacks`, `telescope`, `fzf-lua`)

## 📦 Installation
`lazy.nvim` minimal install with defaults
```lua
return {
  'cablecreek/tf-docs.nvim',
  dependencies = {
    'folke/snacks.nvim', -- snacks is the default picker

    -- optional - renders md view 
    -- 'MeanderingProgrammer/render-markdown.nvim',

  },
  opts = {
    providers = {
      -- add named providers here
      -- 'aws', 'gcp', 'k8s',
      --
      -- or add a custom provider
    },
  },
}
```

## Usage
```lua
TFDocs <provider> -- opens picker and browsing docs
TFDocsSearch <provider> <type> <resource> -- opens doc in view
```

## ⚙️ Configuration/Options 
`tf-docs` comes with defaults however, the following can be customised
1. providers 
2. docs window  
3. picker 

### default options
```lua
opts = {
  providers = {},
  picker = "snacks", -- "telescope", "fzf", "snacks", or BYO <function>
  provider_docs_install_location = vim.fn.stdpath("data") .. "/tf-docs", -- ~/.local/share/nvim/
  win_config = {
    -- either a `split` or `float`
    split = "right", -- "right"|"left"|"above"|"below" The direction to split the current window.
    float = nil, -- is a `vim.api.keyset.win_config` type i.e. width, height, border, etc. 
  },
}
```

### 1. providers
- take a look at the `/providers/` structure
- as a rule of thumb for the provider config
  - it is legacy if the repo contains `website/docs/`
  - legacy also tends to use `.html.markdown`
  - `aws` and `gcp` are examples of legacy, `k8s` is current
```lua
opts = {
  providers = {
    -- current doc structure
    {
      name = 'my_k8s', -- becomes the dir name and registry key, i.e. :TFDocs my_k8s
      repo_url = "https://github.com/hashicorp/terraform-provider-kubernetes.git",
      search_title = "Terraform Kubernetes Docs",
      file_extension = ".md",
    },

    -- legacy structure
    {
      name = 'my_aws', -- becomes the dir name and registry key, i.e. :TFDocs my_aws
      repo_url = "https://github.com/hashicorp/terraform-provider-aws.git",
      is_legacy_docs = true,
      search_title = "Terraform AWS Docs",
      file_extension = ".html.markdown",
    },
  },
}
```

### 2. docs window
```lua
-- split below
opts = {
  win_config = {
    split = "below",
  },
}

```

```lua
-- floating window
opts = {
  win_config = {
    float = {
      relative = "editor",
      width = math.floor(vim.o.columns * 0.7),
      height = math.floor(vim.o.lines * 0.7),
      row = math.floor((vim.o.lines - (vim.o.lines * 0.7)) / 2),
      col = math.floor((vim.o.columns - (vim.o.columns * 0.7)) / 2),
      border = "rounded",
    },
  },
}

-- etc. 
```

### 3. picker
There are 2 functions that allow you to create a custom picker
1. `get_doc_table` - returns a table with document items
2. `open` - opens the selected file in the view 

Example of a minimal `snacks` picker:
```lua
local custom_snacks_picker = function(provider)
  -- ensure you load the plugin inside the function
  local tf_docs = require 'tf-docs'

  require('snacks').picker.pick {
    source = 'Terraform Docs',
    -- Accessing the exposed doc table function
    items = tf_docs.get_doc_table(provider),
    preview = 'file',
    format = function(item)
      return {
        { item.emoji, 'SnacksPickerEmoji' },
        { ' ' .. (item.name or ''), 'SnacksPickerLabel' },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        -- Accessing the exposed view function
        tf_docs.open(item.file)
      end
    end,
  }
end
```

and then assign the picker
```lua
opts = {
  providers = {},
  picker = custom_snacks_picker, -- assign your picker  
}

``` 

## Supported Providers
| provider | repo | 
| :--------------- |  ---------------: |
|`aws`| https://github.com/hashicorp/terraform-provider-aws |
| `gcp` | https://github.com/hashicorp/terraform-provider-google |
| `k8s` | https://github.com/hashicorp/terraform-provider-kubernetes | 

- PR's for providers are always welcome! see [CONTRIBUTING.md]
