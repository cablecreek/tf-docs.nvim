require("plenary.busted")

local search = require("tf-docs.search")
local config = require("tf-docs.config")
local view = require("tf-docs.view")

describe("tf-docs search", function()
  local test_dir
  local opened_path = nil

  before_each(function()
    test_dir = vim.fn.tempname()
    vim.fn.mkdir(test_dir, "p")

    config.setup({
      provider_docs_install_location = test_dir,
    })

    -- Mock the view function to capture the path it tries to open
    opened_path = nil
    view.open = function(path)
      opened_path = path
    end
  end)

  after_each(function()
    vim.fn.delete(test_dir, "rf")
  end)

  it("constructs correct path and opens window for modern providers", function()
    -- 1. Setup mock directory structure for: aws/docs/resources/mock.md
    local provider_path = test_dir .. "/tf-docs/docs/resources"
    vim.fn.mkdir(provider_path, "p")
    local file_path = provider_path .. "/mock.md"
    vim.fn.writefile({}, file_path)

    -- 2. Execute search
    search.search("tf-docs", "resource", "mock")

    -- 3. Assert the constructed path is exactly what we expected
    assert.are.equal(vim.fs.normalize(file_path), opened_path)
  end)

  it("constructs correct path for legacy providers (website/docs)", function()
    -- 1. Setup mock directory structure for legacy: tf-docs-legacy/website/docs/r/mock.html.markdown
    local provider_path = test_dir .. "/tf-docs-legacy/website/docs/r"
    vim.fn.mkdir(provider_path, "p")
    local file_path = provider_path .. "/mock.html.markdown"
    vim.fn.writefile({}, file_path)

    -- 2. Execute search
    search.search("tf-docs-legacy", "resource", "mock")

    -- 3. Assert
    assert.are.equal(vim.fs.normalize(file_path), opened_path)
  end)

  it("returns nil and does not open window if file is missing", function()
    -- Call search for a file we haven't created
    local result = search.search("aws", "resource", "non_existent")

    assert.is_nil(result)
    assert.is_nil(opened_path)
  end)
end)
