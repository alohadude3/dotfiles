local wezterm = require 'wezterm'
local config = wezterm.config_builder()

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then

local home_directory = os.getenv("USERPROFILE")
config.default_prog = { 'C:/Program Files/PowerShell/7/pwsh.exe' }

end

config.automatically_reload_config = true
config.color_scheme = 'Tokyo Night'
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.9
config.win32_system_backdrop = "Acrylic"
config.macos_window_background_blur = 30
--kde blur is nightly only
--config.kde_window_background_blur = true
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })

-- Ignore all states to close tabs unprompted
wezterm.on('mux-is-process-stateful', function(_proc)
  return false
end)

return config

