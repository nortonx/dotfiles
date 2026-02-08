local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 14

config.window_decorations = "TITLE | RESIZE"

-- Gradient disabled due to Wayland compatibility issue
-- config.window_background_gradient = {
--     orientation = 'Vertical',
--     colors = {
--         '#0f0c29',
--         '#302b63',
--         '#24243e',
--     },
--     interpolation = 'Linear',
--     blend = 'Rgb',
-- }
config.colors = {
    background = '#1a1a2e',
}

return config
