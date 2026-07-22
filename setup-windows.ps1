# Windows Setup Script for Dotfiles
# Installs Scoop package manager, then installs required packages and creates symlinks to dotfiles

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

# Install Scoop package manager
function Install-Scoop {
    Write-Host "Installing Scoop package manager..." -ForegroundColor Yellow
    
    # Scoop requires git to be installed first
    # Check if git is already available
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git is required for Scoop. Attempting to install git first..." -ForegroundColor Yellow
        # Try to install git using Windows built-in package manager if available
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Installing git via winget..." -ForegroundColor Cyan
            winget install Git.Git --silent
        } else {
            Write-Host "Error: Git is required but not found and winget is not available." -ForegroundColor Red
            Write-Host "Please install Git for Windows manually: https://git-scm.com/download/win" -ForegroundColor Red
            exit 1
        }
    }
    
    # Install Scoop
    Write-Host "Running Scoop installer..." -ForegroundColor Cyan
    iex (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    
    if (Test-ScoopInstalled) {
        Write-Host "Scoop installed successfully!" -ForegroundColor Green
        Write-Host "Adding scoop to PATH..." -ForegroundColor Yellow
        $env:Path = "$env:USERPROFILE\scoop\shims;$env:Path"
    } else {
        Write-Host "Error: Scoop installation failed." -ForegroundColor Red
        exit 1
    }
}

# Install packages using Scoop
function Install-ScoopPackages {
    Write-Host ""
    Write-Host "Installing required packages via Scoop..." -ForegroundColor Yellow
    $packages = @("git", "neovim", "fd", "fzf", "jq", "ripgrep", "lazygit", "zoxide", "lsd")
    
    foreach ($package in $packages) {
        Write-Host "Installing $package..." -ForegroundColor Cyan
        scoop install $package
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Failed to install $package" -ForegroundColor Yellow
        }
    }
}

# Main installation flow
if (-not $SkipPackages) {
    if (-not (Test-ScoopInstalled)) {
        Install-Scoop
    } else {
        Write-Host "Scoop is already installed." -ForegroundColor Green
    }
    
    Install-ScoopPackages
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
