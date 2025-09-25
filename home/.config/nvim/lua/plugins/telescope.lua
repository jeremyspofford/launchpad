-- LazyVim already provides Telescope configuration
-- This file extends the default Telescope settings and keymaps
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Add Ctrl+P for find_files (VSCode-like)
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
}
