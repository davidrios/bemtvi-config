vim.opt.relativenumber = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes:2"
vim.opt.colorcolumn = "80,120"

-- vim.opt.tabline = '%!v:lua.require(\'myutils\').my_tab_line()'
-- vim.cmd.colorscheme("catppuccin-mocha")

-- vim.lsp.config('*', {
--   capabilities = {
--     textDocument = {
--       semanticTokens = {
--         multilineTokenSupport = true,
--       }
--     },
--     offsetEncoding = { 'utf-16' },
--     general = {
--       positionEncodings = { 'utf-16' },
--     },
--   },
--   root_markers = { '.git' },
-- })

vim.lsp.config('basedpyright', {
  cmd = { 'uvx', '--from', 'basedpyright', 'basedpyright-langserver', '--stdio' },
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "openFilesOnly",
      },
      typeCheckingMode = "basic"
    }
  },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git", ".venv" }
})

vim.lsp.config('pylsp', {
  cmd = { 'uvx', '--from', 'python-lsp-server[rope]', '--with', 'python-lsp-black', 'pylsp' },
  settings = {
    pylsp = {
      plugins = {
        black = {
          enabled = true
        }
      }
    }
  }
})

vim.lsp.config('ruff', {
  cmd = { 'uvx', 'ruff', 'server' },
})

vim.lsp.config('pyrefly', {
  cmd = { 'uvx', 'pyrefly', 'lsp' },
})

local efmls_config = {
  -- filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    -- languages = languages,
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
    hover = true,
    documentSymbol = true,
    codeAction = true,
    completion = true
  },
}

vim.lsp.config('efm', efmls_config)
