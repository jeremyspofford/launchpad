-- default settings
local bridge_settings = {
  obsidian_server_address = "http://localhost:27123",
  scroll_sync = false,  -- See "Sync of buffer scrolling" section below
  cert_path = nil,      -- See "SSL configuration" section below
  warnings = true,      -- Show misconfiguration warnings
  picker = "telescope", -- Picker to use with ObsidianBridgePickCommand ("telescope" | "fzf_lua")
}

return {
  "oflisback/obsidian-bridge.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  -- dependencies = { "ibhagwan/fzf-lua" }, -- For picker = "fzf_lua"
  opts = bridge_settings,
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
}
