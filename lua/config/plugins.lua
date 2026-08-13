local ok, err = pcall(function()
  vim.cmd("colorscheme catppuccin-mocha")
end)
if not ok then
  local msg
  if tostring(err):match("module 'catppuccin' not found") then
    msg = ("colorscheme 'catppuccin' is a git submodule and isn't checked out.\n"
      .. "    git -C %s submodule update --init --recursive"):format(btv.stdpath("config"))
  else
    msg = "colorscheme 'catppuccin' failed to load: " .. tostring(err)
  end
  btv.on("VimEnter", btv.async(function()
    local dir = btv.utils.joinpath(btv.stdpath("config"), "pack/defaults/start/catppuccin")
    local empty = btv.await(btv.fs.exists(dir)) and #btv.await(btv.fs.readdir(dir)) == 0
    btv.notify("config: " .. (empty and msg or "…"), btv.log.levels.ERROR)
  end))
end

btv.plugins({
  {
    "bemtvi/bemtvi-help",
    desc = "Help tags finder and visualizer",
    cmd = { "help" },
    keys = { "<leader>fh" },
  },
  {
    "bemtvi/bemtvi-editorconfig",
    desc = "Load .editorconfig settings",
    config = function()
      require("bemtvi-editorconfig").setup()
    end
  },
  {
    "bemtvi/bemtvi-keys-helper",
    desc = "Popup of available keybindings as you type",
    config = function()
      require("bemtvi-keys-helper").setup({
        spec = {
          {'<leader>b', group = 'Buffer'},
          {'<leader>k', group = 'Dock'},
          {'<leader>q', group = 'Quit'},
          {'<leader>u', group = 'Utilities'},
          {'<leader>s', group = 'Search/Replace'},
          {'<leader>f', group = 'Find files/buffers/etc'},
          {'<leader>c', group = 'Code'},
          {'<leader>d', group = 'Debug'},
          {'<leader>l', group = 'LSP'},
        }
      })
    end
  },
  {
    "bemtvi/bemtvi-tree",
    desc = "File explorer sidebar",
    cmd = { "Tree", "TreeReveal" },
    keys = { "<leader>e" },
    config = function()
      require("bemtvi-tree").setup()
    end
  },
  {
    "bemtvi/bemtvi-lspconfig",
    desc = "Quickstart configs for the built-in LSP client",
    config = function()
      require("bemtvi-lspconfig").setup()
    end
  },
  {
    "bemtvi/bemtvi-efmls-configs",
    desc = "Quickstart configs for the efm-langserver",
    config = function()
      require("bemtvi-efmls-configs").setup()
    end
  },
  {
    "bemtvi/bemtvi-line",
    desc = "Configurable statusline",
    config = function()
      require("bemtvi-line").setup({
        sections = {
          lualine_b = { "diff", "diagnostics" },
        },
      })
    end
  },
  {
    "bemtvi/bemtvi-diff",
    desc = "Diff & merge-conflict visualizer",
    cmd = { "DiffGit", "DiffConflict" },
    config = function()
      require("bemtvi-diff").setup()
    end
  },
  {
    "bemtvi/bemtvi-workspaces",
    desc = "Tools to make working with project dirs easier",
    config = function()
      require("bemtvi-workspaces").setup()
    end
  },
  {
    "bemtvi/bemtvi-dap",
    desc = "Debugger front end — breakpoints, stepping, REPL (<F5>, <leader>db)",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    keys = { "<F5>", "<leader>db" },
    config = function()
      require("bemtvi-dap").setup({})
    end
  },
  {
    "bemtvi/bemtvi-markdown-preview",
    desc = "Markdown previews server",
    cmd = { "MarkdownPreview" },
    config = function()
      require("bemtvi-markdown-preview").setup()
    end
  },
  {
    "bemtvi/bemtvi-snippets",
    desc = "Snippet collection loader and engine",
    config = function()
      require("bemtvi-snippets").setup()
    end,
    deps = { "rafamadriz/friendly-snippets" },
  }
})
