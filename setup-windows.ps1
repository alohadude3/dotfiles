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

# Install CLI packages using Scoop
function Install-ScoopCLI {
    Write-Host ""
    Write-Host "Installing CLI packages via Scoop..." -ForegroundColor Yellow
    $cli_packages = @(
        "fd",
        "fzf",
        "git",
        "gsudo",
        "jq",
        "lazygit",
        "lsd",
        "mise",
        "mpc-hc-fork",
        "neovim",
        "ripgrep",
        "scrcpy",
        "starship",
        "touch",
        "vim",
        "zoxide"
    )
    
    foreach ($package in $cli_packages) {
        Write-Host "Installing $package..." -ForegroundColor Cyan
        scoop install $package
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Warning: Failed to install $package" -ForegroundColor Yellow
        }
    }
}

# Install GUI packages using Scoop
function Install-ScoopGUI {
    Write-Host ""
    Write-Host "Installing GUI packages via Scoop..." -ForegroundColor Yellow
    
    # Add extras bucket for GUI applications
    Write-Host "Adding Scoop extras bucket..." -ForegroundColor Cyan
    scoop bucket add extras
    
    $gui_packages = @(
        "bitwarden",
        "googlechrome",
        "jetbrains-toolbox",
        "sublime-merge",
        "sublime-text",
        "zed"
    )
    
    foreach ($package in $gui_packages) {
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
    
    Install-ScoopCLI
    Install-ScoopGUI
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

    $LinkDir = Split-Path -Parent $Link
    if (-not (Test-Path $LinkDir)) {
        New-Item -ItemType Directory -Path $LinkDir -Force >$null
    }

    # Remove existing file/directory before creating symlink
    if (Test-Path $Link) {
        try {
            Remove-Item -Path $Link -Force -Recurse -ErrorAction Stop
        } catch {
            Write-Host "  ✗ Failed to remove existing $Link" -ForegroundColor Red
            return
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force >$null
        Write-Host "  ✓ $Link -> $Target" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed to create symlink for $Link" -ForegroundColor Red
    }
}

# Create symlinks
New-SymlinkSafe -Link "$homeDir\.ideavimrc" -Target "$dotfilesPath\.ideavimrc"
New-SymlinkSafe -Link "$homeDir\.inputrc" -Target "$dotfilesPath\.inputrc"
New-SymlinkSafe -Link "$homeDir\.vimrc" -Target "$dotfilesPath\.vimrc"
New-SymlinkSafe -Link "$homeDir\.wezterm.lua" -Target "$dotfilesPath\.wezterm.lua"

# Create .config directory structure
$configDir = "$homeDir\.config"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force >$null
}

New-SymlinkSafe -Link "$homeDir\.config\ghostty" -Target "$dotfilesPath\.config\ghostty"
New-SymlinkSafe -Link "$homeDir\.config\mise" -Target "$dotfilesPath\.config\mise"
New-SymlinkSafe -Link "$homeDir\.config\nvim" -Target "$dotfilesPath\.config\nvim"

Write-Host ""
Write-Host "Configuring Git..." -ForegroundColor Yellow

# Symlink git config
New-SymlinkSafe -Link "$homeDir\.gitconfig" -Target "$dotfilesPath\.gitconfig"

# Install pre-push hook if available
$prePushHook = "$dotfilesPath\git\hooks\pre-push"
$prePushHookDest = "$homeDir\.git\hooks\pre-push"
if (Test-Path $prePushHook) {
    $gitHooksDir = "$homeDir\.git\hooks"
    if (-not (Test-Path $gitHooksDir)) {
        New-Item -ItemType Directory -Path $gitHooksDir -Force >$null
    }
    Copy-Item -Path $prePushHook -Destination $prePushHookDest -Force
    Write-Host "  ✓ Installed pre-push hook" -ForegroundColor Green
} else {
    Write-Host "  Warning: pre-push hook not found at $prePushHook" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Creating symlinks..." -ForegroundColor Yellow

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
Write-Host "Configuring PowerShell..." -ForegroundColor Yellow

# Symlink PowerShell profile
New-SymlinkSafe -Link $PROFILE -Target "$dotfilesPath\.ps1"

Write-Host ""
Write-Host "Configuring Git..." -ForegroundColor Yellow

# Symlink git config
New-SymlinkSafe -Link "$homeDir\.gitconfig" -Target "$dotfilesPath\.gitconfig"

# Install pre-push hook if available
$prePushHook = "$dotfilesPath\git\hooks\pre-push"
$prePushHookDest = "$homeDir\.git\hooks\pre-push"
if (Test-Path $prePushHook) {
    $gitHooksDir = "$homeDir\.git\hooks"
    if (-not (Test-Path $gitHooksDir)) {
        New-Item -ItemType Directory -Path $gitHooksDir -Force >$null
    }
    Copy-Item -Path $prePushHook -Destination $prePushHookDest -Force
    Write-Host "  ✓ Installed pre-push hook" -ForegroundColor Green
} else {
    Write-Host "  Warning: pre-push hook not found at $prePushHook" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: PowerShell profile symlink should be created manually." -ForegroundColor Yellow
Write-Host "Your PowerShell profile is typically located at:" -ForegroundColor Yellow
Write-Host "  $PROFILE" -ForegroundColor White
Write-Host ""
