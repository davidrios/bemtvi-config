nx.plugins({
  {
    "nxvim/catppuccin-nxvim",
    name = "catppuccin",
    desc = "Soothing pastel colorscheme",
    config = function()
      vim.cmd("colorscheme catppuccin")
    end
  },
  {
    "nxvim/nxvim-help",
    desc = "Help tags finder and visualizer",
  },
  {
    "nxvim/nxvim-editorconfig",
    desc = "Load .editorconfig settings",
    config = function()
      require("nxvim-editorconfig").setup()
    end
  },
  {
    "nxvim/nxvim-keys-helper",
    desc = "Popup of available keybindings as you type",
    config = function()
      require("nxvim-keys-helper").setup({
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
    "nxvim/nxvim-tree",
    desc = "File explorer sidebar",
    config = function()
      require("nxvim-tree").setup()
    end
  },
  {
    "nxvim/nxvim-lspconfig",
    desc = "Quickstart configs for the built-in LSP client",
    config = function()
      require("nxvim-lspconfig").setup()
    end
  },
  {
    "nxvim/nxvim-efmls-configs",
    desc = "Quickstart configs for the efm-langserver",
    config = function()
      require("nxvim-efmls-configs").setup()
    end
  },
  {
    "nxvim/nxvim-line",
    desc = "Configurable statusline",
    config = function()
      require("nxvim-line").setup()
    end
  },
  {
    "nxvim/nxvim-diff",
    desc = "Diff & merge-conflict visualizer",
    config = function()
      require("nxvim-diff").setup()
    end
  },
  {
    "nxvim/nxvim-workspaces",
    desc = "Tools to make working with project dirs easier",
    config = function()
      require("nxvim-workspaces").setup()
    end
  },
  {
    "nxvim/nxvim-dap",
    desc = "Debugger front end — breakpoints, stepping, REPL (<F5>, <leader>db)",
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    keys = { "<F5>", "<leader>db" },
    config = function()
      require("nxvim-dap").setup({})
    end
  },
  {
    "nxvim/nxvim-markdown-preview",
    desc = "Markdown previews server",
    config = function()
      require("nxvim-markdown-preview").setup()
    end
  },
  {
    "nxvim/nxvim-snippets",
    desc = "Snippet collection loader and engine",
    config = function()
      require("nxvim-snippets").setup()
    end,
    deps = { "rafamadriz/friendly-snippets" },
  }
})
