-- ============================================================================ --
-- AI Plugins for Neovim
-- ============================================================================ --
-- Requires: cmake, build-essential (Linux) or Xcode CLT (macOS)
-- Set ANTHROPIC_API_KEY environment variable for Claude integration
-- ============================================================================ --

-- Check if build tools are available
local function has_build_tools()
  return vim.fn.executable("cmake") == 1 and vim.fn.executable("make") == 1
end

-- Get Claude model from environment or use default
local function get_claude_model()
  return vim.env.CLAUDE_MODEL or "claude-sonnet-4-20250514"
end

return {
  -- Avante (Cursor-like AI experience)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    -- Only build if we have the tools
    build = has_build_tools() and "make" or nil,
    cond = function()
      if not has_build_tools() then
        vim.notify(
          "avante.nvim: cmake/make not found. Install build tools for AI features.",
          vim.log.levels.WARN
        )
        return false
      end
      return true
    end,
    opts = {
      provider = "claude",
      claude = {
        api_key_name = "ANTHROPIC_API_KEY",
        model = get_claude_model(),
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
