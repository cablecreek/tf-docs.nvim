-- HACK: might need updating with as gh actions may not pull a new repo
require("plenary.busted")

local install = require("tf-docs.install")
local config = require("tf-docs.config")

describe("tf-docs install", function()
  local test_dir

  before_each(function()
    -- 1. Create a safe, temporary directory for this specific test
    test_dir = vim.fn.tempname()
    vim.fn.mkdir(test_dir, "p")

    config.setup({
      provider_docs_install_location = test_dir,
    })
  end)

  after_each(function()
    vim.cmd("silent! only")
    vim.fn.delete(test_dir, "rf")
  end)

  it("returns nil for unknown provider", function()
    -- Fixed: passed an actual unknown provider instead of "aws"
    local result = install.install_provider("some_fake_unknown_provider")
    assert.is_nil(result)
  end)

  it("installs a provider", function()
    install.install_provider("tf-docs")

    local success = vim.wait(5000, function()
      return vim.fn.isdirectory(test_dir .. "/tf-docs") == 1
    end, 100)

    assert.is_true(success, "Provider installation timed out or failed to create directory")
  end)

  it("removes a provider", function()
    -- Setup: Manually create a dummy directory to test the removal logic
    local path = test_dir .. "/tf-docs"
    vim.fn.mkdir(path, "p")

    install.remove_provider("tf-docs")

    -- This is synchronous, so no vim.wait is needed
    assert.is_false(vim.fn.isdirectory(path) == 1, "Directory was not removed")
  end)

  -- TODO:
  it("updates a provider", function()
    --   install.update_provider("tf-docs")
  end)
  -- TODO:
  it("lazy installer syncs state", function()
    -- install.lazy_installer()
  end)
end)
