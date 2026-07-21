#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
echo "==> Applying nix-darwin configuration..."
sudo darwin-rebuild switch --flake ~/.dotfiles#Leos-Macbook

echo "==> Ensuring mise tools are installed..."
# Ensure tools defined in Nix (mise.globalConfig) are actually downloaded
mise prune --yes
mise install --yes
