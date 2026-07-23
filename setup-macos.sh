#!/bin/bash
# macOS Setup Script for Dotfiles
# Installs required packages via Homebrew and creates symlinks to dotfiles

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_DIR="$HOME"

echo "================================"
echo "macOS Dotfiles Setup"
echo "================================"
echo ""

# Check if Homebrew is installed
brew_available=true
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "Warning: Homebrew installation failed. Package installation will be skipped."
        brew_available=false
    }
else
    echo "Homebrew is already installed."
fi

if ! command -v brew &> /dev/null; then
    brew_available=false
fi

echo ""
echo "Installing required packages via Homebrew..."

# Formulae to install
formulae=(
    "fd"
    "fzf"
    "git"
    "jq"
    "lazygit"
    "lsd"
    "mise"
    "neovim"
    "ripgrep"
    "scrcpy"
    "starship"
    "vim"
    "zoxide"
)

# Casks to install (GUI applications)
casks=(
    "bitwarden"
    "ghostty"
    "google-chrome"
    "jetbrains-toolbox"
    "linearmouse"
    "logi-options+"
    "sublime-merge"
    "sublime-text"
    "zed"
)

echo "Installing Homebrew formulae..."
if [ "$brew_available" = true ]; then
    for package in "${formulae[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo "  ✓ $package is already installed"
        else
            echo "  Installing $package..."
            brew install "$package" || echo "  Warning: Failed to install $package"
        fi
    done
else
    echo "  Skipping formula installation because Homebrew is not available."
fi

echo ""
echo "Installing Homebrew casks..."
if [ "$brew_available" = true ]; then
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            echo "  ✓ $cask is already installed"
        else
            echo "  Installing $cask..."
            brew install --cask "$cask" || echo "  Warning: Failed to install $cask"
        fi
    done
else
    echo "  Skipping cask installation because Homebrew is not available."
fi

echo ""
echo "Creating symlinks..."

# Function to create symlink safely
create_symlink() {
    local link="$1"
    local target="$2"

    local link_dir=$(dirname "$link")
    mkdir -p "$link_dir"

    # Remove existing file/directory before creating symlink
    if [ -e "$link" ] || [ -L "$link" ]; then
        rm -rf "$link" || { echo "  ✗ Failed to remove existing $link"; return 1; }
    fi

    ln -sf "$target" "$link"
    echo "  ✓ $link -> $target"
}

# Create symlinks
create_symlink "$HOME_DIR/.vimrc" "$SCRIPT_DIR/.vimrc"
create_symlink "$HOME_DIR/.ideavimrc" "$SCRIPT_DIR/.ideavimrc"
create_symlink "$HOME_DIR/.ideavim" "$SCRIPT_DIR/.ideavim"
create_symlink "$HOME_DIR/.inputrc" "$SCRIPT_DIR/.inputrc"
create_symlink "$HOME_DIR/.wezterm.lua" "$SCRIPT_DIR/.wezterm.lua"
create_symlink "$HOME_DIR/.config/nvim" "$SCRIPT_DIR/.config/nvim"
create_symlink "$HOME_DIR/.config/ghostty" "$SCRIPT_DIR/.config/ghostty"
create_symlink "$HOME_DIR/.config/mise" "$SCRIPT_DIR/.config/mise"
create_symlink "$HOME_DIR/.config/linearmouse" "$SCRIPT_DIR/.config/linearmouse"
create_symlink "$HOME_DIR/.config/starship.toml" "$SCRIPT_DIR/.config/starship.toml"

# Handle shell configs
if [ -f "$SCRIPT_DIR/.bashrc" ]; then
    create_symlink "$HOME_DIR/.bashrc" "$SCRIPT_DIR/.bashrc"
fi

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    create_symlink "$HOME_DIR/.zshrc" "$SCRIPT_DIR/.zshrc"
fi

echo ""
echo "Configuring Git..."

# Symlink git config
create_symlink "$HOME_DIR/.gitconfig" "$SCRIPT_DIR/.gitconfig"
create_symlink "$HOME_DIR/.config/git" "$SCRIPT_DIR/.config/git"
find "$SCRIPT_DIR/.config/git/hooks" -type f -exec chmod +x {} \;

echo ""
echo "Customizing macOS system settings..."

# MacOS System settings
defaults write -g AppleInterfaceStyle -string "Dark"
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g AppleShowAllExtensions -bool true
defaults write -g com.apple.mouse.linear -bool true

defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder CreateDesktop -bool false
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
