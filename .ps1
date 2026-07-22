# Add `. "~/.ps1"` to the PowerShell profile .ps1 file
# Location is by calling `$PROFILE` in PowerShell

# lsd
Set-Alias -Name ls -Value lsd -Option AllScope
function lsd_long {
	lsd -la @args
}
Set-Alias -Name ll -Value lsd_long -Option AllScope

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Starship
Invoke-Expression (&starship init powershell)

