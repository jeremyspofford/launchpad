return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require("lualine").setup {
      options = {
        -- theme = "catppuccin",
        -- theme = "vscode",
        -- theme = 'tokyonight-night',
        theme = "auto",
        event = "BufEnter",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename", "help", "modified", "readonly" },
        lualine_c = { "branch" },
        lualine_x = { "filetype", "fileformat" },
        lualine_y = { "progress" },
        lualine_z = { "location", "codeium" },
      },
    }
  end,
}
-- TODO: Still unable to to get the codeium status line to appear in lualine
-- -- Add Codeium status to the statusline
-- vim.o.statusline = table.concat({
-- 	"%f",                       -- Full file path
-- 	" %h",                      -- Help flag
-- 	" %m",                      -- Modified flag
-- 	" %r",                      -- Readonly flag
-- 	"%=",                       -- Right aligned
-- 	" %y ",                     -- File type
-- 	"%{&ff} ",                  -- File format
-- 	" %p%%",                    -- File position percentage
-- 	" %l:%c ",                  -- Line and column number
-- 	" [Codeium:%{v:lua.get_codeium_status()}]", -- Codeium status
-- })
