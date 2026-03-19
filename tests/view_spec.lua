require("plenary.busted")

local config = require("tf-docs.config")
local view = require("tf-docs.view")

describe("tf-docs view", function()
  local temp_file = os.tmpname()

  before_each(function()
    -- Mock the config so M.open has a valid window configuration to use
    config.options = {
      win_config = {
        split = "right",
      },
    }

    -- Create the physical file so filereadable() returns true
    local f = io.open(temp_file, "w")
    if f then
      f:write("Temporary documentation content")
      f:close()
    end
  end)

  after_each(function()
    -- Cleanup: Close windows and delete the temp file
    vim.cmd("silent! only")
    os.remove(temp_file)
  end)

  it("returns nil when file does not exist", function()
    local win = view.open("/tmp/tf-doc-testing-file-that-should-not-exist")
    assert.is_nil(win)
  end)

  it("successfully opens a valid file and returns a window handle", function()
    local win = view.open(temp_file)

    assert.not_nil(win)
    assert.is_true(vim.api.nvim_win_is_valid(win))
  end)

  it("sets the correct buffer options", function()
    local win = view.open(temp_file)
    -- Extract the buffer from the created window
    local buf = vim.api.nvim_win_get_buf(win)

    assert.is_false(vim.api.nvim_get_option_value("modifiable", { buf = buf }))
    assert.is_true(vim.api.nvim_get_option_value("readonly", { buf = buf }))
    assert.are.equal("wipe", vim.api.nvim_get_option_value("bufhidden", { buf = buf }))
    assert.are.equal("markdown", vim.api.nvim_get_option_value("filetype", { buf = buf }))
  end)

  it("respects floating window configuration", function()
    -- Override the config specifically for this test
    config.options.win_config = {
      float = {
        relative = "editor",
        width = 50,
        height = 20,
        row = 5,
        col = 5,
      },
    }

    local win = view.open(temp_file)
    assert.not_nil(win)

    -- Verify it actually created a floating window
    local win_config = vim.api.nvim_win_get_config(win)
    assert.is_not_nil(win_config.zindex) -- Floating windows have a z-index
    assert.are.equal("editor", win_config.relative)
  end)
end)
