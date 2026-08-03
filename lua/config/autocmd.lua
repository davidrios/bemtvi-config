local mu = require('myutils')

local M = {}
local my_augroup = vim.api.nvim_create_augroup('11ea7949-c92d-4a4e-85d6-5208fa4b3b44', { clear = true })
M.my_augroup = my_augroup

vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  group = my_augroup,
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  callback = function()
    if not vim.fn.expand('%'):match('COMMIT_EDITMSG$') then
      -- vim.cmd('silent! normal! g`"zv')
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead' }, {
  group = my_augroup,
  desc = 'Detect other file types',
  pattern = '*',
  callback = function(ev)
    local bufnr = ev.buf
    if vim.bo[bufnr].filetype == '' or vim.bo[bufnr].filetype == 'conf' then
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
      if first_line and vim.startswith(first_line, "#!/usr/bin/env -S uv run") then
        vim.bo[bufnr].filetype = "python"
      end
    end
    if vim.bo[bufnr].filetype == '' and vim.fn.expand('%'):match('.jade$') then
      vim.bo[bufnr].filetype = "pug"
    end
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    -- vim.opt_local.textwidth = 0
    -- vim.opt_local.formatoptions:remove({ "t", "c" })
  end,
})

return M
