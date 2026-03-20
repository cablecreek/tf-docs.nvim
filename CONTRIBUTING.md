# Contributing
- PRs for welcome providers are welcome
- if you want a new feature or to change core functionality, start a discussion first!

---
## TODO
- [ ] nvim docs
- [ ] finish tests
  - [x] config
  - [ ] docs <- get install working first
  - [ ] install <- how to handle async install?
  - [ ] pickers 
  - [ ] registry
  - [ ] search
  - [ ] view
- [ ] check custom opts examples are working
- [ ] add other providers

### future direction and features
- [ ] doc construction could be cached and not generated each time. doesnt seem super slow at the moment 
- [ ] search for under cursor (like gd, gr, etc.), need to also account for the "resource" or "data" resource
- [ ] refine install tests (i.e. actually pull the repo and wait until done)
- [ ] command for listing available providers to install, some auto complete would be nice
- [ ] uninstall tidy up

### known issues
- install mechanism is lazy and greedy, running the git commands in the background every time nvim opens
- yaml frontmatter is optional but often used, may hit an issue here...

---
## General notes
### Terraform provider doc structure
- https://developer.hashicorp.com/terraform/registry/providers/docs#directory-structure
- Prefixes: For resources, ephemeral-resources, actions, and list-resources, ensure you do not include the <PROVIDER NAME>_ prefix in the filename.
- Legacy Support: `website/docs/` using `.html.markdown` or `.html.md` extensions.
- `file_extensions = { ".md", ".html.md", ".html.markdown" }`

```sh
docs/
├── index.md                      # Provider index page
├── guides/
│   └── <guide>.md                # Additional guides
├── resources/
│   └── <resource>.md             # Resource info (no provider prefix)
├── data-sources/
│   └── <data_source>.md          # Data source info
├── functions/
│   └── <function>.md             # Provider functions
├── ephemeral-resources/
│   └── <ephemeral-resource>.md   # Ephemeral resources (no provider prefix)
├── actions/
│   └── <action>.md               # Action info (no provider prefix)
└── list-resources/
    └── <list-resource>.md        # List resource info (no provider prefix)
```

