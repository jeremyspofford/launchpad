return {
  -- VSCode-like indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = {
        char = "│",
      },
      scope = {
        show_start = false,
        show_end = false,
      },
    },
  },

  -- Better folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      })
    end,
  },

  -- VSCode-like breadcrumbs
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>nv", "<cmd>Navbuddy<cr>", desc = "Nav" },
    },
    config = function()
      local actions = require("nvim-navbuddy.actions")
      require("nvim-navbuddy").setup({
        window = {
          border = "single",
        },
      })
    end,
  },
}
