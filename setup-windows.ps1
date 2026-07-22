# Windows Setup Script for Dotfiles
# Installs required packages and creates symlinks to dotfiles

param(
    [switch]$SkipPackages = $false
)

$dotfilesPath = Split-Path -Parent $PSCommandPath
$homeDir = $env:USERPROFILE

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Windows Dotfiles Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Scoop is installed
function Test-ScoopInstalled {
    try {
        scoop --version >$null 2>&1
        return $true
    } catch {
        return $false
    }
}

# Install packages if not skipped
if (-not $SkipPackages) {
    Write-Host "Installing Scoop (if not already installed)..." -ForegroundColor Yellow
    if (-not (Test-ScoopInstalled)) {
        Write-Host "Scoop not found. Installing..." -ForegroundColor Yellow
        iex (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    } else {
        Write-Host "Scoop is already installed." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Installing required packages via Scoop..." -ForegroundColor Yellow
    $packages = @("git", "neovim", "fd", "fzf", "jq", "ripgrep", "lazygit", "zoxide", "lsd")
    
    foreach ($package in $packages) {
        Write-Host "Installing $package..." -ForegroundColor Cyan
        scoop install $package
    }
} else {
    Write-Host "Skipping package installation." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Creating symlinks..." -ForegroundColor Yellow

# Function to create symlink
function New-SymlinkSafe {
    param(
        [string]$Link,
        [string]$Target
    )

    if (Test-Path $Link) {
        Write-Host "  $Link already exists, skipping..." -ForegroundColor Gray
        return
    }

    $LinkDir = Split-Path -Parent $Link
    if (-not (Test-Path $LinkDir)) {
        New-Item -ItemType Directory -Path $LinkDir -Force >$null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force >$null
        Write-Host "  ✓ $Link -> $Target" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to create symlink for $Link" -ForegroundColor Red
    }
}

# Create symlinks
New-SymlinkSafe -Link "$homeDir\.vimrc" -Target "$dotfilesPath\.vimrc"
New-SymlinkSafe -Link "$homeDir\.ideavimrc" -Target "$dotfilesPath\.ideavimrc"
New-SymlinkSafe -Link "$homeDir\.inputrc" -Target "$dotfilesPath\.inputrc"
New-SymlinkSafe -Link "$homeDir\.wezterm.lua" -Target "$dotfilesPath\.wezterm.lua"

# Create .config directory structure
$configDir = "$homeDir\.config"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force >$null
}

New-SymlinkSafe -Link "$homeDir\.config\nvim" -Target "$dotfilesPath\.config\nvim"
New-SymlinkSafe -Link "$homeDir\.config\ghostty" -Target "$dotfilesPath\.config\ghostty"
New-SymlinkSafe -Link "$homeDir\.config\mise" -Target "$dotfilesPath\.config\mise"

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: PowerShell profile symlink should be created manually." -ForegroundColor Yellow
Write-Host "Your PowerShell profile is typically located at:" -ForegroundColor Yellow
Write-Host "  $PROFILE" -ForegroundColor White
Write-Host ""
