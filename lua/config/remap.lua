local mu = require("myutils")

vim.keymap.set("n", "<leader>pv", vim.cmd.TreeReveal, { desc = "Reveal file in explorer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bd, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bw", vim.cmd.w, { desc = "Write buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "Delete buffer without saving" })
vim.keymap.set("n", "<leader>bt", ":tabnew %<cr><c-tab><c-o><c-tab>", { desc = "Move buffer to separate tab" })
vim.keymap.set("n", "<leader>br",
	  function()
    if vim.bo.modified then
		      vim.notify("Cannot reload modified buffer!", vim.log.levels.ERROR)
      return
	    end

    local currf = vim.fn.expand('%')
    local escaped = vim.fn.fnameescape(currf)
    mu.feedkeys("mZ:ed ___<cr>:bd " .. escaped .. "<cr>:ed " .. escaped .. "<cr>'Z:bd ___<cr>")
    vim.schedule(function()
      mu.feedkeys("`'")
      vim.print("Buffer reloaded")
    end)
  end,
	  { desc = "Reload buffer (to activate LSP)" })
vim.keymap.set("n", "<leader>bA", ":%bd|e#<cr>", { desc = "Close all other buffers" })
