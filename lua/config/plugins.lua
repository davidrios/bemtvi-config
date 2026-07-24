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
    "nxvim/nxvim-keys-helper",
    desc = "Popup of available keybindings as you type (which-key)",
    config = function()
      require("nxvim-keys-helper").setup()
    end
  },
  {
    "nxvim/nxvim-tree",
    desc = "File explorer sidebar (<leader>e)",
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
    "nxvim/nxvim-line",
    desc = "Configurable statusline (lualine)",
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
})
