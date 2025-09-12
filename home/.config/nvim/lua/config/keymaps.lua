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
