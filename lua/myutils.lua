local M = {}

local function prequire(...)
  local status, lib = pcall(require, ...)
  if (status) then return lib end
  vim.print('Failed to require ' .. ...)
  return nil
end
M.prequire = prequire

local function get_last_x(my_list, x)
  local len = #my_list
  local start_index = math.max(1, len - x + 1)
  local last_x = {}

  for i = start_index, len do
    table.insert(last_x, my_list[i])
  end

  return last_x
end
M.get_last_x = get_last_x

local function str_join(chr, arr, fn)
  if #arr == 0 then
    return ''
  end
  local rest = ''
  for i, p in vim.spairs(arr) do
    rest = rest .. ((i > 1) and chr or '') .. (fn ~= nil and fn(p, i) or p)
  end
  return rest
end
M.str_join = str_join

local CACHE_NIL_KEY = {}
local _global_cache = {}
local _cache_id = 0

local CachedFn = {}
CachedFn.__index = CachedFn

function CachedFn:new(fn, cache_key_fn, global_key)
  local instance = {}
  setmetatable(instance, self)
  instance._cache_id = _cache_id
  _cache_id = _cache_id + 1

  if global_key ~= nil and _global_cache[global_key] ~= nil then
    instance._cache = _global_cache[global_key]
  else
    instance._cache = {}
  end

  instance._fn = fn
  instance._cache_key_fn = cache_key_fn
  return instance
end

function CachedFn:_get_key(...)
  local key = CACHE_NIL_KEY
  if self._cache_key_fn ~= nil then
    key = self._cache_key_fn(...)
  end

  if key == nil then
    key = CACHE_NIL_KEY
  end

  return key
end

function CachedFn:__call(...)
  --vim.print('CachedFnCall', ...)

  local key = self:_get_key(...)
  if self._cache[key] ~= nil then
    local value = self._cache[key][1]
    -- vim.print(str_join(':', {'retrieved', self._cache_id, key, value}, tostring))
    return value
  end

  local value = self._fn(...)
  self._cache[key] = { value }
  -- vim.print(str_join(':', {'computed', self._cache_id, key, value}, tostring))
  return value
end

function CachedFn:remove_key(...)
  local key = self:_get_key(...)
  -- vim.print(str_join(':', {'removed', self._cache_id, key, '!'}, tostring))
  self._cache[key] = nil
end

M.CachedFn = CachedFn

local function cache_key_1(arg1) return arg1 end
M.cache_key_1 = cache_key_1

local function match_any(patterns, cmp)
  for i = 1, #patterns do
    if cmp:match(patterns[i]) then
      return true
    end
  end
  return false
end
M.match_any = match_any

local function my_tab_label(n)
  local buflist = vim.fn.tabpagebuflist(n)
  local i = 1

  if i > #buflist then
    i = #buflist
  end

  local bufnr = buflist[i]
  local bufname = vim.fn.bufname(bufnr)
  if #bufname == 0 then
    bufname = '[No Name]'
  end

  local parts = get_last_x(vim.split(bufname, '/'), 3)
  local fname = table.remove(parts)
  if #fname > 20 then
    fname = string.sub(fname, 0, 19) .. '…'
  end

  local rest = str_join('/', parts, function(part) return part:sub(1, 3) end)
  if #rest > 0 then
    rest = '(' .. rest .. ')'
  end
  return n .. ':' .. fname .. (vim.bo[bufnr].modified and '*' or '') .. rest
end
M.my_tab_label = my_tab_label

-- local function relative_to_cwd(fpath)
--   return Path:new(fpath):make_relative(vim.fn.getcwd())
-- end
-- M.relative_to_cwd = relative_to_cwd

local function my_tab_line()
  local s = ''
  local tabnr_last = vim.fn.tabpagenr('$')
  local tabnr_current = vim.fn.tabpagenr()

  for i = 1, tabnr_last do
    if i == tabnr_current then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    s = s .. '%' .. i .. 'T'
    s = s .. ' %{v:lua.require(\'myutils\').my_tab_label(' .. i .. ')}'
  end

  s = s .. '%#TabLineFill#%T'

  if tabnr_last > 1 then
    s = s .. '%=%#TabLine#%999Xclose'
  end

  return s
end
M.my_tab_line = my_tab_line

local function genAttachPython(name, port, remoteRoot)
  return {
    type = 'python',
    request = 'attach',
    name = 'attach ' .. name,
    pathMappings = {
      { localRoot = vim.fn.getcwd(), remoteRoot = remoteRoot or vim.fn.getcwd() }
    },
    connect = function()
      local host = '127.0.0.1'
      return { host = host, port = port }
    end,
  }
end
M.genAttachPython = genAttachPython

function M.feedkeys(keys, mode)
  if mode == nil then
    mode = 'n'
  end
  local processed_keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
  vim.api.nvim_feedkeys(processed_keys, mode, false)
end

function M.setup_workspace_rc(name)
  local mod = prequire('workspace-templates/' .. name)
  if mod == nil then
    vim.notify('error: workspace template "' .. name .. '" not found', vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(SESSION_FILE) ~= 1 then
    vim.notify('error: session file does not exist, create it first', vim.log.levels.ERROR)
    return
  end

  local rc_file_name = 'rc-' .. name .. '.lua'
  local ws_rc_file = Path:new(SESSION_PREFIX):joinpath(rc_file_name)

  if ws_rc_file:exists() then
    vim.notify(
      'error: workspace template rc file "' .. ws_rc_file .. '" already exists, not overwritting',
      vim.log.levels.ERROR)
    return
  end

  A.run(function()
    if mod.setup(ws_rc_file) then
      M.anotify(
        'workspace rc file created, source it by adding "require(\'myutils\').source_rc(\'' ..
        name .. '\')" to your rc.lua and restart')
      vim.schedule(function()
        M.source_rc(name)
      end)
    end
  end)
end

function M.source_rc(name)
  vim.cmd('luafile ' .. vim.fn.fnameescape(SESSION_PREFIX .. '/' .. 'rc-' .. name .. '.lua'))
end

vim.api.nvim_create_user_command('MyUtilsSetupRC', function(args)
  M.setup_workspace_rc(args.fargs[1])
end, {
  nargs = 1,
  complete = function()
    local scan = require('plenary.scandir')
    local ws_templates_path = vim.fn.stdpath('config') .. '/lua/workspace-templates'
    local ws_dirs = scan.scan_dir(ws_templates_path, { hidden = false, depth = 1, only_dirs = true })
    local only_names = {}
    for i = 1, #ws_dirs do
      local parts = vim.split(ws_dirs[i], '/')
      table.insert(only_names, parts[#parts])
    end
    return only_names
  end,
})

local global_g_args = { '!node_modules', '!.idea', '!.vscode', '!.neovim', '!.venv' }
function M.extend_global_g_args(g_args)
  for i = 1, #g_args do
    table.insert(global_g_args, g_args[i])
  end
end

M.global_g_args = global_g_args

-- Build the ripgrep argv for a live grep, mirroring `myutils.live_grep(us, g_args)`.
-- `--vimgrep` already implies --no-heading --with-filename --line-number --column,
-- so the parser downstream always gets `file:line:col:text`.
local function rg_args(query, opts)
  opts = opts or {}
  local args = { "--vimgrep", "--color=never", "--smart-case" }
  if opts.unrestricted and opts.unrestricted > 0 then
    args[#args + 1] = "-" .. string.rep("u", opts.unrestricted) -- -u, -uu, …
  end
  for _, g in ipairs(opts.globs or {}) do
    args[#args + 1] = "-g"
    args[#args + 1] = g
  end
  args[#args + 1] = "--"
  args[#args + 1] = query
  return args
end

-- Register a dynamic live-grep source that runs `rg` with a fixed set of extra
-- flags (`opts.unrestricted`, `opts.globs`). One factory covers plain grep, `-uu`,
-- and `-uu` + excludes — exactly the three telescope live_grep variants.
function M.make_grep_picker(name, title, opts)
  nx.picker.source({
    name = name,
    title = title,
    layer = "main",
    dynamic = true,       -- re-run rg after each (debounced) query edit
    preview = "location", -- scroll the preview to the match and highlight it
    items = nx.async(function(ctx)
      if ctx.query == "" then
        return
      end
      local stream = nx.run_stream({ cmd = "rg", args = rg_args(ctx.query, opts), cwd = ctx.cwd })
      ctx.on_cancel(function()
        stream:kill()
      end)
      for batch in nx.await_each(stream) do
        for _, l in ipairs(batch) do
          local file, lnum, col = l:match("^(.-):(%d+):(%d+):")
          if file then
            ctx.push({ text = l, path = file, row = tonumber(lnum), col = tonumber(col) })
          end
        end
      end
    end),
    confirm = function(item, mode, layer)
      nx.picker.edit(item, mode, layer)
    end,
  })
end

-- Stream a plain listing command (one path per line) as file candidates.
function M.make_files_picker(name, title, cmd, cmd_args)
  nx.picker.source({
    name = name,
    title = title,
    layer = "main",
    preview = "file",
    items = nx.async(function(ctx)
      local stream = nx.run_stream({ cmd = cmd, args = cmd_args, cwd = ctx.cwd })
      ctx.on_cancel(function()
        stream:kill()
      end)
      for batch in nx.await_each(stream) do
        for _, l in ipairs(batch) do
          if l ~= "" then
            ctx.push({ text = l, path = l })
          end
        end
      end
    end),
    confirm = function(item, mode, layer)
      nx.picker.edit(item, mode, layer)
    end,
  })
end

-- Seed a picker's prompt with the visual selection — the native replacement for
-- the old `yank_call_paste`. Yank the selection to register z, then (next tick,
-- once the register mirror has refreshed) open the picker pre-filled with it.
function M.picker_with_selection(source)
  return function()
    nx._feedkeys('"zy', false, false)
    nx.on_next_tick(function()
      local q = nx.reg.get("z"):gsub("%s+", " ")
      nx.picker.open(source, { query = q })
    end)
  end
end

function M.open_picker(source)
  return function()
    nx.picker.open(source)
  end
end

return M
