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
vim.opt.fixendofline = false
vim.opt.autopairs = true

-- vim.opt.tabline = '%!v:lua.require(\'myutils\').my_tab_line()'
-- vim.cmd.colorscheme("catppuccin-mocha")

btv.complete.setup {
  sources = { "lsp", "snippets", "buffer", },
  auto = false,
  confirm = "first",
  keys = {
    next    = { "<C-n>", "<Down>" },
    prev    = { "<C-p>", "<Up>" },
    confirm = { "<Tab>", "<C-y>", "<CR>" },
    trigger = "<C-Space>"
  },
}

btv.lsp.signature_help_autotrigger(true)

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

vim.lsp.config('*', {
  -- workspace_required = true
  root_markers = { '.git' },
})

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

-- Resolve a server's root with its own `root_markers` (from the bemtvi-lspconfig
-- preset, plus any override you've merged in). When the upward walk finds nothing,
-- fall back to the workspace root — or the cwd outside a workspace — instead of the
-- file's own directory.
local function root_or_workspace(name)
  return btv.async(function(bufnr)
    local markers = btv.lsp.get_config(name).root_markers
    local root = markers and btv.await(btv.lsp.find_root(bufnr, markers, name))
    return root or btv.workspace.dir() or btv.cwd()
  end)
end

for _, name in ipairs({ "basedpyright", "pylsp", "ruff", "ty", "pyrefly" }) do
  btv.lsp.config(name, { root_dir = root_or_workspace(name) })
end

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
