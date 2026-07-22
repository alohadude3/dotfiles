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
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

echo ""
echo "Installing required packages via Homebrew..."

# Formulae to install
formulae=(
    "git"
    "neovim"
    "fd"
    "fzf"
    "jq"
    "ripgrep"
    "lazygit"
    "zoxide"
    "lsd"
)

# Casks to install (GUI applications)
casks=(
    "ghostty"
    "google-chrome"
    "jetbrains-toolbox"
    "linearmouse"
    "logi-options+"
    "sublime-text"
    "sublime-merge"
    "zed"
)

echo "Installing Homebrew formulae..."
for package in "${formulae[@]}"; do
    if brew list "$package" &>/dev/null; then
        echo "  ✓ $package is already installed"
    else
        echo "  Installing $package..."
        brew install "$package"
    fi
done

echo ""
echo "Installing Homebrew casks..."
for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "  ✓ $cask is already installed"
    else
        echo "  Installing $cask..."
        brew install --cask "$cask"
    fi
done

echo ""
echo "Creating symlinks..."

# Function to create symlink safely
create_symlink() {
    local link="$1"
    local target="$2"

    if [ -e "$link" ] || [ -L "$link" ]; then
        echo "  $link already exists, skipping..."
        return
    fi

    local link_dir=$(dirname "$link")
    mkdir -p "$link_dir"

    ln -s "$target" "$link"
    echo "  ✓ $link -> $target"
}

# Create symlinks
create_symlink "$HOME_DIR/.vimrc" "$SCRIPT_DIR/.vimrc"
create_symlink "$HOME_DIR/.ideavimrc" "$SCRIPT_DIR/.ideavimrc"
create_symlink "$HOME_DIR/.inputrc" "$SCRIPT_DIR/.inputrc"
create_symlink "$HOME_DIR/.wezterm.lua" "$SCRIPT_DIR/.wezterm.lua"
create_symlink "$HOME_DIR/.config/nvim" "$SCRIPT_DIR/.config/nvim"
create_symlink "$HOME_DIR/.config/ghostty" "$SCRIPT_DIR/.config/ghostty"
create_symlink "$HOME_DIR/.config/mise" "$SCRIPT_DIR/.config/mise"

# Handle shell configs
if [ -f "$SCRIPT_DIR/.bashrc" ]; then
    create_symlink "$HOME_DIR/.bashrc" "$SCRIPT_DIR/.bashrc"
fi

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    create_symlink "$HOME_DIR/.zshrc" "$SCRIPT_DIR/.zshrc"
fi

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
