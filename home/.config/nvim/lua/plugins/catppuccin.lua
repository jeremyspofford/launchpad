-- ============================================================================ --
-- Catppuccin Theme with Auto Dark Mode
-- ============================================================================ --

return {
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        which_key = true,
        mini = true,
        native_lsp = {
          enabled = true,
        },
      },
    },
  },

  -- Auto dark mode (follows system theme)
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd.colorscheme("catppuccin-mocha")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd.colorscheme("catppuccin-latte")
      end,
      update_interval = 1000,
      fallback = "dark",
    },
  },

  -- Set catppuccin as the default colorscheme for LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
