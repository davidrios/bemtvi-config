local mu = require("myutils")

vim.keymap.set("n", "<leader>pv", vim.cmd.Tree, { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bd, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bw", vim.cmd.w, { desc = "Write buffer" })
vim.keymap.set("n", "<leader>bD", function() vim.cmd("bd!") end, { desc = "Delete buffer without saving" })
vim.keymap.set("n", "<leader>bt",
  function()
    vim.cmd("tab split")
    vim.cmd("tabp")
    vim.cmd("normal! \15")
    vim.cmd("tabn")
  end,
  { desc = "Move buffer to separate tab" }
)
-- vim.keymap.set("n", "<leader>br",
-- 	  function()
--     if vim.bo.modified then
-- 		      vim.notify("Cannot reload modified buffer!", vim.log.levels.ERROR)
--       return
-- 	    end
--
--     local currf = vim.fn.expand('%')
--     local escaped = vim.fn.fnameescape(currf)
--     mu.feedkeys("mZ:ed ___<cr>:bd " .. escaped .. "<cr>:ed " .. escaped .. "<cr>'Z:bd ___<cr>")
--     vim.schedule(function()
--       mu.feedkeys("`'")
--       vim.print("Buffer reloaded")
--     end)
--   end,
-- 	  { desc = "Reload buffer (to activate LSP)" })
vim.keymap.set("n", "<leader>bA", ":%bd|e#<cr>", { desc = "Close all other buffers" })

local function jump_smart(pos)
  local jumplist, cur_idx = table.unpack(vim.fn.getjumplist())

  local target_idx = cur_idx
  -- equivalent to <C-o>
  local code = "\15"
  if pos >= 0 then
    target_idx = cur_idx + 2
    -- equivalent to <C-i>
    code = "\09"
  else
    if cur_idx == 0 then return end
  end

  if vim.v.count > 0 then
    vim.cmd("normal! " .. (vim.v.count1) .. code)
    return
  end

  local target_jump = jumplist[target_idx]
  if not target_jump then return end

  local target_bufnr = target_jump.bufnr
  local current_bufnr = vim.api.nvim_get_current_buf()

  if target_bufnr ~= current_bufnr then
    local target_windows = vim.fn.win_findbuf(target_bufnr)

    if #target_windows > 0 then
      vim.api.nvim_set_current_win(target_windows[1])
      return
    end
  end

  vim.cmd("normal! " .. (vim.v.count1) .. code)
end
vim.keymap.set("n", "<C-o>", function() jump_smart(-1) end, { desc = "Smart Jump Back" })
vim.keymap.set("n", "<C-i>", function() jump_smart(1) end, { desc = "Smart Jump Forward" })

vim.keymap.set("n", "<leader>qf", function() vim.cmd("qa!") end, { desc = "Force quit" })
vim.keymap.set("n", "<leader>qa", ":qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qw", vim.cmd.xa, { desc = "Quit writing all" })
vim.keymap.set("n", "<leader>qq", vim.cmd.q, { desc = "Quit / Close window" })
-- vim.keymap.set("n", "<leader>uc", "<cmd>Centerpad 53<cr>", { desc = "Activate Centerpad" })
-- vim.keymap.set("n", "<leader>ucc", "<cmd>Centerpad 53<cr><cmd>Centerpad 53<cr>", { desc = "Activate Centerpad" })
vim.keymap.set("n", "<leader>uh", vim.cmd.noh, { desc = "Clear highlight" })
-- vim.keymap.set("n", "<leader>uz", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>",
--   { desc = "Toggle and focus undo tree" })
-- vim.keymap.set("n", "<leader>uus", "<cmd>mksession! " .. mu.SESSION_FILE .. "<cr>", { desc = "Save session to default file" })
vim.keymap.set("n", "<c-s>", function()
  vim.cmd.w()
end, { desc = "Reformat and write buffer" })

-- if the destination file is already opened in another window, switch to it
-- this function is adapted from the neovim source code
local function on_list_goto_first(options)
  local api = vim.api
  vim.fn.setqflist({}, ' ', options)
  local from = vim.fn.getpos('.')
  local bufnr = api.nvim_get_current_buf()
  from[1] = bufnr
  local tagname = vim.fn.expand('<cword>')
  local win = api.nvim_get_current_win()
  local item = vim.fn.getqflist()[1]
  local destbufnr = item.bufnr or vim.fn.bufadd(item.filename)
  -- Push a new item into tagstack
  local tagstack = { { tagname = tagname, from = from } }
  vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, 't')
  vim.bo[destbufnr].buflisted = true
  local destwin = win
  destwin = vim.fn.win_findbuf(destbufnr)[1] or destwin
  if destwin ~= win then
    -- open destination buffer first in same window, goto cursor, save mark and go back so it's added to the jumplist
    api.nvim_win_set_buf(win, destbufnr)
    api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
    vim.cmd("normal! m'")
    vim.cmd("normal! 1\15")

    local curr_pos = vim.api.nvim_win_get_cursor(0)
    api.nvim_set_current_win(destwin)
    -- set previous buffer at previous cursor in the destination window to be able to add a jumplist
    api.nvim_win_set_buf(destwin, bufnr)
    api.nvim_win_set_cursor(destwin, { curr_pos[1], curr_pos[2] })
  end
  vim.cmd("normal! m'")
  api.nvim_win_set_buf(destwin, destbufnr)
  api.nvim_win_set_cursor(destwin, { item.lnum, item.col - 1 })
  vim._with({ win = destwin }, function()
    -- Open folds under the cursor
    vim.cmd('normal! zv')
  end)
end

-- vim.keymap.set("n", "<C-]>", function()
--   vim.lsp.buf.definition({ reuse_win = true, on_list = on_list_goto_first })
-- end, { desc = "Go to implementation" })

vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without saving" })
vim.keymap.set({ "n", "v" }, "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
-- vim.keymap.set("n", "<leader>Y", "\"+Y")
vim.keymap.set({ "n", "v" }, "<leader>ud", "\"_d", { desc = "Delete to void" })
vim.keymap.set("i", "<c-c>", "<esc>", { desc = "Same as pressing Esc" })
vim.keymap.set("n", "<leader>sr", ":%s/", { desc = "Search and replace" })
vim.keymap.set("v", "<leader>sr", "y:%s/<c-r>\"/", { desc = "Search and replace" })
vim.keymap.set("v", "<leader>sR", "y:%s/\\<<c-r>\"\\>/", { desc = "Search and replace exact" })
vim.keymap.set("v", "O", "$og0",
  { desc = "Expand selection to start of line on first line and end of line on last line" })
vim.keymap.set("n", "<leader>ft", vim.cmd.TreeReveal, { desc = "Find file in tree" })
vim.keymap.set("n", "<leader>w", "<c-w>w", { desc = "Switch windows" })
vim.keymap.set("n", "]w", "<c-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "[w", "<c-w>h", { desc = "Go to left window" })
vim.keymap.set("i", "<s-bs>", "<c-o>db", { desc = "Delete previous word" })
vim.keymap.set("i", "<s-del>", "<c-o>dw", { desc = "Delete next word" })
vim.keymap.set("i", "<s-cr>", "<c-o>o", { desc = "Add empty line and go to it" })

vim.keymap.set("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
vim.keymap.set("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
vim.keymap.set("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
vim.keymap.set("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
vim.keymap.set("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
vim.keymap.set("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
vim.keymap.set("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
vim.keymap.set("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
vim.keymap.set("n", "<leader>9", "9gt", { desc = "Go to tab 9" })

-- <leader>ff  find_files with `fd -u -t file` (overrides the shipped rg-based "files")
-- mu.make_files_picker("files", "Find Files", "fd", { "-u", "-t", "file", "--color", "never" })
-- <C-p>  git_files
mu.make_files_picker("git_files", "Git Files", "git", { "ls-files" })

-- <leader>fg  live grep            <leader>fA  live grep -uu
-- <leader>fG  live grep -uu + excludes
-- mu.make_grep_picker("live_grep", "Live Grep", {})
-- mu.make_grep_picker("live_grep_uu", "Live Grep (-uu)", { unrestricted = 2 })
mu.make_grep_picker("live_grep_ex", "Live Grep (-uu, excludes)", { unrestricted = 2, globs = mu.global_g_args })

-- Files / grep
vim.keymap.set("n", "<leader>ff", mu.open_picker("files"), { desc = "Find files" })
vim.keymap.set("v", "<leader>ff", mu.picker_with_selection("files"), { desc = "Find files (selection)" })
vim.keymap.set("n", "<C-p>", mu.open_picker("git_files"), { desc = "Git files" })
vim.keymap.set("n", "<leader>fg", mu.open_picker("live_grep"), { desc = "Live grep" })
vim.keymap.set("v", "<leader>fg", mu.picker_with_selection("live_grep"), { desc = "Live grep (selection)" })
vim.keymap.set("n", "<leader>fG", mu.open_picker("live_grep_ex"), { desc = "Live grep -uu + excludes" })
vim.keymap.set("v", "<leader>fG", mu.picker_with_selection("live_grep_ex"),
  { desc = "Live grep -uu + excludes (selection)" })
-- vim.keymap.set("v", "<leader>fA", mu.picker_with_selection("live_grep_uu"), { desc = "Live grep -uu (selection)" })

-- Code / LSP — these route their results into nx.picker on their own.
vim.keymap.set("n", "<leader>cx", mu.open_picker("diagnostics"), { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>cs", nx.lsp.document_symbol, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>cr", nx.lsp.references, { desc = "LSP references" })
vim.keymap.set("n", "<leader>ct", nx.lsp.type_definition, { desc = "LSP type definitions" })

-- Dock nav
for lhs, target in pairs({
  ["<leader>kh"] = "left",
  ["<leader>kl"] = "right",
  ["<leader>kk"] = "top",
  ["<leader>kj"] = "bottom",
  ["<leader>kk"] = "main",
}) do
  nx.keymap.set("n", lhs, function() nx.layer.focus(target) end,
    { desc = "Focus the " .. target .. " layer" })
end
