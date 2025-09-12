return {
  -- VSCode theme
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        -- Style: 'dark' (default) or 'light'
        style = "dark",

        -- Enable transparent background
        transparent = false,

        -- Enable italic comments
        italic_comments = true,

        -- Underline links
        underline_links = true,

        -- Disable nvim-tree background color for better integration
        disable_nvimtree_bg = true,

        -- Apply theme colors to terminal
        terminal_colors = true,

        -- Color overrides (optional)
        color_overrides = {
          -- vscLineNumber = '#858585',
        },

        -- Highlight group overrides
        group_overrides = {
          -- Cursor styling
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })

      -- Set colorscheme
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- Configure LazyVim to use vscode theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
