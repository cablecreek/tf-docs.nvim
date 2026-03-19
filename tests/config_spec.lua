require("plenary.busted")
local config = require("tf-docs.config")

describe("tf-docs config", function()
  local original_options = vim.deepcopy(config.options)

  after_each(function()
    config.options = vim.deepcopy(original_options)
  end)

  it("expands and creates the install directory", function()
    local tmp_path = vim.fn.tempname()

    config.setup({
      provider_docs_install_location = tmp_path,
    })

    assert.is_true(vim.fn.isdirectory(tmp_path) == 1)

    vim.fn.delete(tmp_path, "rf")
  end)

  it("defaults are as expected", function()
    assert.is_table(config.options.providers)
    assert.not_nil(config.options.picker)
    assert.not_nil(config.options.win_config)
  end)
end)
