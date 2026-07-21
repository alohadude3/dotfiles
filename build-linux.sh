#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Ensure the symlink exists in the current user's home directory.
ln -sfn "$DIR" "$HOME/.dotfiles"

echo "==> Applying NixOS configuration..."
sudo nixos-rebuild switch --flake ~/.dotfiles#linux

echo "==> Ensuring mise tools are installed..."
# Run mise install normally.
# We also prune any versions that are no longer requested in our pinned config.
mise prune --yes
mise install --yes
