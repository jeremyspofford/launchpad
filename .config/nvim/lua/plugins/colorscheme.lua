return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    "Mofiqul/vscode.nvim",
    name = "vscode",
    lazy = false,
    priority = 2,
    config = function()
      vim.cmd.colorscheme "catppuccin"
      -- to get light theme, do :lua require('').load('light')
    end,
  },
  {
    "dracula/vim",
    name = "dracula",
    lazy = true,
    priority = 2,
    config = function()
      vim.cmd.colorscheme "dracula"
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 2,
    opts = {},
    config = function()
      vim.cmd.colorscheme "tokyonight-night"
    end,
  },
  {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = true,
    priority = 2,
    config = function()
      vim.cmd.colorscheme "nightfly"
    end,
  },
  {
    "joshdick/onedark.vim",
    name = "onedark",
    lazy = true,
    priority = 2,
    config = function()
      vim.cmd.colorscheme "onedark"
    end,
  },
}
