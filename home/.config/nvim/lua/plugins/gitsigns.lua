-- LazyVim already provides gitsigns configuration
-- This file extends the default gitsigns settings
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = false, -- Can be enabled if desired
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 1000,
    },
  },
}
