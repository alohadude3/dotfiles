#!/usr/bin/env bash
set -euo pipefail

# Find the real path of the script directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Environment Guard: Ensure Nix and Home Manager are in PATH
# This allows the script to be run even in a fresh shell session.
for profile in \
    "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" \
    "/etc/profile.d/nix.sh" \
    "$HOME/.nix-profile/etc/profile.d/nix.sh" \
    "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
do
    if [ -e "$profile" ]; then
        # shellcheck disable=SC1091
        . "$profile"
    fi
done

if ! command -v nix >/dev/null 2>&1; then
    echo "Error: Nix is not installed or not in PATH. Please run ./bootstrap-linux.sh first."
    exit 1
fi

# Ensure the symlink exists in the current user's home directory.
ln -sfn "$DIR" "$HOME/.dotfiles"

if [ -e /etc/NIXOS ]; then
    echo "==> Applying NixOS configuration..."
    sudo nixos-rebuild switch --refresh --flake ~/.dotfiles#linux
else
    echo "==> Applying Home Manager configuration..."
    # On non-NixOS systems, we run home-manager switch.
    # We use the full path as a fallback if the command is not in PATH yet.
    HM_BIN="$HOME/.nix-profile/bin/home-manager"
    if command -v home-manager >/dev/null 2>&1; then
        home-manager switch --refresh --flake ~/.dotfiles#linux -b backup
    elif [ -x "$HM_BIN" ]; then
        "$HM_BIN" switch --refresh --flake ~/.dotfiles#linux -b backup
    else
        echo "    home-manager not found, running via nix..."
        nix run github:nix-community/home-manager/release-26.05 -- switch --refresh --flake ~/.dotfiles#linux -b backup
    fi
fi

echo "==> Ensuring mise tools are installed..."
# Run mise install normally.
# We also prune any versions that are no longer requested in our pinned config.
mise prune --yes
mise install --yes
