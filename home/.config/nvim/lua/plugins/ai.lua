-- ============================================================================ --
-- AI Plugins for Neovim
-- ============================================================================ --

return {
  -- Avante (Cursor-like AI experience)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    build = "make",
    opts = {
      provider = "claude",
      claude = {
        api_key_name = "ANTHROPIC_API_KEY",
        model = "claude-sonnet-4-20250514",
      },
      mappings = {
        ask = "<leader>aa",
        edit = "<leader>ae",
        refresh = "<leader>ar",
      },
      hints = { enabled = true },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- Optional: for image pasting
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
          },
        },
      },
      -- Optional: for rendering markdown
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- Aider integration via toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 80,
      direction = "vertical",
    },
    keys = {
      {
        "<leader>ai",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local aider = Terminal:new({
            cmd = "aider",
            direction = "vertical",
            size = 80,
            close_on_exit = false,
            on_open = function(term)
              vim.cmd("startinsert!")
            end,
          })
          aider:toggle()
        end,
        desc = "Open Aider",
      },
      {
        "<leader>at",
        "<cmd>ToggleTerm<cr>",
        desc = "Toggle Terminal",
      },
    },
  },
}
