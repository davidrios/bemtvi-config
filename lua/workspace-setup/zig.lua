-- The `setup` hook of workspace-templates/zig.json — the efm half of the old
-- `workspace-templates/zig/rc.lua`.
--
-- `zls` is plain data and lives in the JSON. efm can't be: its `languages` map
-- holds efmls-configs PRESETS (async factories that resolve the tool binary over
-- nx.fs), not values JSON can carry. nxvim-efmls-configs owns the efm `nx.lsp`
-- config itself, so efm is deliberately absent from the template's `lsps`.

local M = {}

function M.setup()
  -- Parenthesized: nxvim's `require` returns (module, loader-path), and the bare
  -- call in a table constructor would leak that path string into the list.
  local zlint = (require("efmls-configs.linters.zlint"))

  require("nxvim-efmls-configs").setup({
    languages = {
      zig = { zlint },
    },
  })
end

return M
