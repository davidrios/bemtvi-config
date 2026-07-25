-- Project-local node package bootstrap for workspace templates whose language
-- servers ship as npm packages (see workspace-setup/vue-typescript.lua).
--
-- The port of the old `workspace-templates/node-base.lua`, which drove
-- plenary Paths and a blocking `mu.arun_job`. Here it stands on the native
-- async seams — `nx.fs` for the directory, `nx.run` for npm — so nothing
-- blocks the editor and, in a `--connect-daemon` session, both the files and
-- the npm child land on the machine the language server will actually run on.
--
-- The packages go under `<workspace>/.nxvim/lsp` (the old `.neovim/lsp`), so a
-- project's servers are pinned per project instead of globally installed.

local M = {}

-- The directory the project's language-server packages live in.
function M.lsp_dir()
  local root = nx.workspace.dir()
  if not root then
    error("workspace-setup.node: not a --workspace session (no workspace root)", 0)
  end
  return root .. "/.nxvim/lsp"
end

-- Create the package dir and `npm init -y` it when it has no package.json yet.
-- Resolves the dir path; rejects loud when npm fails (a half-initialized dir
-- would otherwise install nothing and leave the server cmds pointing at a path
-- that never fills in).
M.init = nx.async(function()
  local lsp_dir = M.lsp_dir()
  nx.await(nx.fs.mkdir(lsp_dir, { recursive = true }))

  -- This dir is machine-local build output living inside the PROJECT's repo, so
  -- it ignores itself: `*` covers node_modules, the generated package.json /
  -- lockfile, and this file too, leaving nothing here for a stray `git add -A`
  -- to pick up. Scoped to `lsp/` on purpose — `.nxvim/config.json` one level up
  -- is meant to be committed. Only written when absent, so an edit here stands.
  local gitignore = lsp_dir .. "/.gitignore"
  if not nx.await(nx.fs.exists(gitignore)) then
    nx.await(nx.fs.write(gitignore, "*\n"))
  end

  if not nx.await(nx.fs.exists(lsp_dir .. "/package.json")) then
    local res = nx.await(nx.run({ cmd = "npm", args = { "init", "-y" }, cwd = lsp_dir }))
    if res.code ~= 0 then
      error("workspace-setup.node: error creating node package: " .. res.stderr, 0)
    end
  end

  return lsp_dir
end)

-- `npm install -D <packages…>` into `lsp_dir`. Rejects loud on a non-zero exit.
M.install_packages = nx.async(function(lsp_dir, packages)
  nx.notify("installing node packages...", nx.log.levels.INFO)

  local args = { "install", "-D" }
  for _, val in ipairs(packages) do
    args[#args + 1] = val
  end

  local res = nx.await(nx.run({ cmd = "npm", args = args, cwd = lsp_dir }))
  if res.code ~= 0 then
    error("workspace-setup.node: error adding node packages: " .. res.stderr, 0)
  end

  nx.notify("node packages installed", nx.log.levels.INFO)
  return true
end)

-- init + install in one step, resolving the `node_modules` dir the server
-- commands are built from.
M.ensure = nx.async(function(packages)
  local lsp_dir = nx.await(M.init())
  nx.await(M.install_packages(lsp_dir, packages))
  return lsp_dir .. "/node_modules"
end)

return M
