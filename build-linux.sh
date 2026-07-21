#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Ensure the symlink is correct
ln -sfn "$DIR" ~/.dotfiles

# Auto-stage any modified files for Nix flakes
git -C "$DIR" add -A

# Apply configuration with experimental features enabled
NIX_CONFIG="experimental-features = nix-command flakes" \
  home-manager switch --flake ~/.dotfiles#"$(whoami)@linux"
