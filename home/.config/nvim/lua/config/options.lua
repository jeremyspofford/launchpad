-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- VSCode-like settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
vim.opt.fillchars = { eob = " " }
vim.opt.cursorline = true
vim.opt.termguicolors = true

-- Font settings (adjust based on your terminal)
vim.opt.guifont = "JetBrainsMono Nerd Font:h12"

