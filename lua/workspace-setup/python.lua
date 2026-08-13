-- The `setup` hook of workspace-templates/python.json — the bits of the old
-- `workspace-templates/python/rc.lua` that aren't plain data.
--
-- The LSP servers and the <C-s> chain live in the JSON now; what's left here is
-- the grep excludes and the debugpy attach configurations. It runs (and is
-- awaited) before the rest of the config is applied.
--
-- Dropped from the old rc: `luasnip.loaders.from_vscode.lazy_load()` —
-- bemtvi-snippets discovers VSCode collections lazily per filetype on its own, so
-- there is nothing per-workspace to kick off.

local mu = require("myutils")

local M = {}

-- Where the app runs inside its container, for debugpy's path mapping.
local REMOTE_ROOT = "/backend"

function M.setup()
  mu.extend_global_g_args({ "!.pytest_cache", "!coverage.html" })

  btv.plugins.on_loaded("bemtvi-dap", function(name)
    local dap = require("bemtvi-dap")

    -- The old `require('dap-python').setup('python3')`, spelled out: debugpy's own
    -- adapter, run as a stdio child.
    dap.adapters.python = {
      type = "executable",
      command = "python3",
      args = { "-m", "debugpy.adapter" },
    }

    dap.configurations.python = {
      mu.genAttachPython("app1", 5678, REMOTE_ROOT),
      mu.genAttachPython("app2", 5679, REMOTE_ROOT),
      mu.genAttachPython("app3", 5680, REMOTE_ROOT),
    }
  end)
end

return M
