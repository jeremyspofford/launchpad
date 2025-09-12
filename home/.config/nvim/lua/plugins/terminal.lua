return {
  "akinsho/toggleterm.nvim",
  opts = {
    size = 15,
    open_mapping = [[<C-`>]], -- VSCode-like terminal toggle
    hide_numbers = true,
    shade_terminals = false,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 3,
    },
  },
  keys = {
    { "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
  },
}
