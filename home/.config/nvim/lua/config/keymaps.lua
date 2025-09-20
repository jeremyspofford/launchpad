-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- VSCode-like keymaps
-- keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
-- keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
-- keymap.set("n", "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
-- keymap.set("n", "<C-y>", "<cmd>redo<cr>", { desc = "Redo" })
-- keymap.set("n", "<C-f>", "<cmd>Telescope live_grep<cr>", { desc = "Find in files" })
-- keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
keymap.set("n", "<C-shift-p>", "<cmd>Telescope commands<cr>", { desc = "Command palette" })

-- Tab management (like VSCode)
-- keymap.set("n", "<C-t>", "<cmd>tabnew<cr>", { desc = "New tab" })
-- keymap.set("n", "<C-w>", "<cmd>bd<cr>", { desc = "Close buffer" })
-- keymap.set("n", "<C-Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
-- keymap.set("n", "<C-S-Tab>", "<cmd>bprev<cr>", { desc = "Previous buffer" })

-- Terminal toggle (Ctrl + backtick)
keymap.set("n", "<C-`>", function()
  local term_buf = nil
  local term_win = nil
  
  -- Find existing terminal buffer
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      term_buf = buf
      -- Check if terminal is visible in any window
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          term_win = win
          break
        end
      end
      break
    end
  end
  
  if term_win then
    -- Terminal is visible, close it
    vim.api.nvim_win_close(term_win, false)
  else
    -- Terminal not visible, open/create it
    vim.cmd("rightbelow vsplit")
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      -- Use existing terminal buffer
      vim.api.nvim_win_set_buf(0, term_buf)
    else
      -- Create new terminal
      vim.cmd("terminal")
    end
    -- Resize to reasonable width (40% of screen)
    local width = math.floor(vim.o.columns * 0.4)
    vim.api.nvim_win_set_width(0, width)
  end
end, { desc = "Toggle terminal to the right" })

-- Terminal toggle from within terminal (Ctrl + backtick)
keymap.set("t", "<C-`>", function()
  local term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_close(term_win, false)
end, { desc = "Close terminal from within terminal" })
