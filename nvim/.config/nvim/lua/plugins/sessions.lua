return {
  'rmagatti/auto-session',
  config = function()
    require('auto-session').setup {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      session_lens = {
        load_on_setup = true, -- Initialize on startup (requires Telescope)
        theme_conf = {        -- Pass through for Telescope theme options
          -- layout_config = { -- As one example, can change width/height of picker
          --   width = 0.8,    -- percent of window
          --   height = 0.5,
          -- },
        },
        previewer = false, -- File preview for session picker

        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { 'i', '<C-D>' },
          alternate_session = { 'i', '<C-S>' },
        },

        session_control = {
          control_dir = vim.fn.stdpath 'data' .. '/auto_session/', -- Auto session control dir, for control files, like alternating between two sessions with session-lens
          control_filename = 'session_control.json',               -- File name of the session control file
        },
      },
      vim.keymap.set('n', '<leader>ls', require('auto-session.session-lens').search_session, { noremap = true }),
    }
  end,
}
