-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 140
config.initial_rows = 32

-- or, changing the font size and color scheme.
config.font_size = 16
config.color_scheme = "JetBrainsMonoNLNerdFontMono-Regular"

-- Finally, return the configuration to wezterm:
return config
