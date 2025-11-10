local wezterm = require 'wezterm'
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then

local home_directory = os.getenv("USERPROFILE")
config.default_prog = { home_directory .. '/scoop/shims/bash.exe' }

end

config.color_scheme = 'One Dark (Gogh)'
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.8
config.win32_system_backdrop = "Acrylic"
config.macos_window_background_blur = 20
--kde blur is nightly only
--config.kde_window_background_blur = true
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })

return config

