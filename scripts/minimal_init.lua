local root = vim.fn.getcwd()
vim.opt.rtp:append(root)

-- 1. Define possible paths for dependencies
local function add_dep(name)
  local paths = {
    root .. "/../" .. name, -- CI/Manual Clones
    vim.fn.stdpath("data") .. "/lazy/" .. name, -- Local Lazy.nvim
  }

  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) > 0 then
      vim.opt.rtp:append(path)
      return true
    end
  end
  print("Warning: Could not find dependency: " .. name)
  return false
end

-- 2. Load dependencies
add_dep("plenary.nvim")
add_dep("telescope.nvim")
add_dep("fzf-lua")
add_dep("snacks.nvim")

-- 3. Initialize
vim.cmd("runtime! plugin/plenary.vim")

-- Safe requires
local function setup(mod)
  local ok, m = pcall(require, mod)
  if ok then
    m.setup({})
  end
end

setup("telescope")
setup("fzf-lua")
setup("snacks")
