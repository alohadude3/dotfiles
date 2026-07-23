#!/bin/bash
# Linux Setup Script for Dotfiles
# Installs required packages and creates symlinks to dotfiles
# Supports apt (Debian/Ubuntu), dnf (Fedora/RHEL), and pacman (Arch)

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_DIR="$HOME"

echo "================================"
echo "Linux Dotfiles Setup"
echo "================================"
echo ""

# Single package list (generic names)
packages=(
    "fd"
    "fzf"
    "ghostty"
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

# Detect package manager and set install command
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL_CMD="sudo apt-get install -y"
    PKG_UPDATE_CMD="sudo apt-get update"
    
    # Package name mappings for apt (where they differ from generic names)
    declare -A PKG_MAP=(
        [fd]="fd-find"
    )
    
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PKG_INSTALL_CMD="sudo dnf install -y"
    PKG_UPDATE_CMD="sudo dnf check-update"
    
    # Package name mappings for dnf (where they differ from generic names)
    declare -A PKG_MAP=(
        [fd]="fd-find"
    )
    
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    PKG_INSTALL_CMD="sudo pacman -S --noconfirm"
    PKG_UPDATE_CMD="sudo pacman -Sy"
    
    # Package name mappings for pacman (where they differ from generic names)
    declare -A PKG_MAP=()
    
else
    echo "Error: No supported package manager found."
    echo "Please install packages manually: ${packages[*]}"
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"
echo ""
echo "Updating package manager..."
$PKG_UPDATE_CMD || true

echo ""
echo "Installing required packages via $PKG_MANAGER..."

for package in "${packages[@]}"; do
    # Use mapped name if it exists, otherwise use generic name
    pkg_name="${PKG_MAP[$package]:-$package}"
    
    echo "  Installing $package ($pkg_name)..."
    $PKG_INSTALL_CMD "$pkg_name" || echo "  Warning: Failed to install $package"
done

echo ""
echo "Installing GUI applications via Flatpak..."

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found. Installing Flatpak..."
    $PKG_INSTALL_CMD flatpak || echo "Warning: Failed to install flatpak"
fi

# GUI applications to install via Flatpak
flatpak_apps=(
    "com.bitwarden.desktop"
    "com.google.Chrome"
    "com.sublimehq.SublimeText"
    "com.sublimemerge.App"
    "dev.zed.Zed"
)

for app in "${flatpak_apps[@]}"; do
    echo "  Installing $app..."
    flatpak install -y flathub "$app" || echo "  Warning: Failed to install $app"
done

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
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
