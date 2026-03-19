# Contributing
- PRs for welcome providers are welcome
- if you want a new feature or to change core functionality, start a discussion first!

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

