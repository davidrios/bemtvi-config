-- The `setup` hook of workspace-templates/vue-typescript.json — the port of the
-- old `workspace-templates/vue-typescript/{init,rc}.lua`.
--
-- Everything here is path-dependent, which is why it is Lua and not JSON: the
-- language servers are npm packages installed per project under
-- `<workspace>/.bemtvi/lsp`, so each server's `cmd` is only knowable once that
-- directory exists. The hook is AWAITED before the template's `lsps` are
-- registered and enabled, so the npm bootstrap finishes and every `cmd` is in
-- place before anything is spawned.
--
-- efm is the exception that stays out of the template's `lsps` entirely:
-- bemtvi-efmls-configs owns efm's `btv.lsp` config, and its `languages` map holds
-- preset factories JSON can't carry.

local mu = require("myutils")
local node = require("workspace-setup.node")

local M = {}

-- The servers the project gets its own copy of. `typescript` is the tsdk vue_ls
-- and the @vue/typescript-plugin both read; vscode-langservers-extracted supplies
-- the css/json/html/eslint servers.
local PACKAGES = {
  "typescript-language-server",
  "typescript",
  "@vue/language-server",
  "@vue/typescript-plugin",
  "vscode-langservers-extracted",
  "eslint-formatter-visualstudio",
}

-- Point each server at the project-local package, leaving everything else
-- (filetypes, root markers, settings) to the server's own preset — the same
-- split the old rc had, where only the `cmd` was ever overridden.
-- `btv.lsp.config` deep-merges, so these compose with the preset rather than
-- replacing it — and with the template's own `lsps` entries, which are applied
-- after this hook and would win on any key they set.
local function configure_servers(node_modules)
  local bin = node_modules .. "/.bin"

  btv.lsp.config("cssls", { cmd = { bin .. "/vscode-css-language-server", "--stdio" } })
  btv.lsp.config("jsonls", { cmd = { bin .. "/vscode-json-language-server", "--stdio" } })
  btv.lsp.config("html", { cmd = { bin .. "/vscode-html-language-server", "--stdio" } })
  btv.lsp.config("eslint", { cmd = { bin .. "/vscode-eslint-language-server", "--stdio" } })

  btv.lsp.config("vue_ls", {
    cmd = { bin .. "/vue-language-server", "--stdio" },
    init_options = {
      typescript = {
        tsdk = node_modules .. "/typescript/lib",
      },
    },
  })

  btv.lsp.config("ts_ls", {
    cmd = { bin .. "/typescript-language-server", "--stdio" },
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = node_modules .. "/@vue/typescript-plugin",
          languages = { "vue" },
        },
      },
    },
    -- The preset stops at the js/ts family; `vue` is what makes this the hybrid
    -- setup, with ts_ls serving the <script> blocks vue_ls hands off.
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "vue",
    },
  })
end

-- prettier through efm, for the languages the old rc listed.
local function configure_efm()
  local prettier = (require("efmls-configs.formatters.prettier"))

  require("bemtvi-efmls-configs").setup({
    languages = {
      javascript = { prettier },
      typescript = { prettier },
      typescriptreact = { prettier },
      vue = { prettier },
    },
  })
end

M.setup = btv.async(function()
  mu.extend_global_g_args({
    "!.nuxt",
    "!yarn.lock",
    "!.output",
    "!.cache",
    "!.yarn",
    "!test-report.junit.xml",
  })

  local node_modules = btv.await(node.ensure(PACKAGES))
  configure_servers(node_modules)
  configure_efm()
end)

return M
