-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 24
config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = "TokyoNight"
config.color_scheme = "catppuccin-mocha"

-- Finally, return the configuration to wezterm:
config.keys = {
  {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
}

return config
