# Add `. "~/.ps1"` to the PowerShell profile .ps1 file
# Location is by calling `$PROFILE` in PowerShell

# lsd
Set-Alias -Name ls -Value lsd -Option AllScope
function lsd_long {
	lsd -lA @args
}
Set-Alias -Name ll -Value lsd_long -Option AllScope

# Zoxide
Set-Alias -Name cd -Value z -Option AllScope
Invoke-Expression (& { (zoxide init powershell | Out-String) })
