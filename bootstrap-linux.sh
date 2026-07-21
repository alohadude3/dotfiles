#!/usr/bin/env bash
# Takes a fresh Linux/NixOS WSL setup and applies the NixOS system config.
# Run this once.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Verify Nix environment"
if command -v nix >/dev/null 2>&1; then
    echo "    nix is installed (expected on NixOS)"
else
    echo "    Nix not found! Please ensure you are running this on NixOS or a system with Nix installed."
    exit 1
fi

echo "==> Step 2: Symlink this repo to ~/.dotfiles"
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: Personalize the configured username"
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"

if [ -z "$FLAKE_USER" ]; then
    echo "    Could not find the single \"user = \" line in flake.nix."
    echo "    Edit flake.nix yourself before continuing."
    exit 1
elif [ "$FLAKE_USER" != "$REAL_USER" ]; then
    echo "    I see you are \"$REAL_USER\", but flake.nix is configured for \"$FLAKE_USER\"."
    echo "    Proceeding with target user \"$FLAKE_USER\" (Normal for fresh NixOS/WSL installs)."
else
    echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

# Bundle staging and switching into a single execution block using nixos-rebuild
RUN_ACTIONS="
    echo '==> Step 4: First NixOS system switch'
    sudo nixos-rebuild switch --flake ~/.dotfiles#linux

    echo '==> Done. NixOS system is initialized.'
    echo '    Next steps:'
    echo '    1. Restart WSL or re-login to switch to the new user account.'
    echo '    2. Run ~/.dotfiles/build-linux.sh to complete user-level setup and install mise tools.'
"

if ! command -v git >/dev/null 2>&1; then
    echo "    git not found on PATH. Spawning transient nix-shell to provide git and run switch..."
    nix-shell -p git --run "$RUN_ACTIONS"
else
    eval "$RUN_ACTIONS"
fi

echo "==> Done. Use ./build-linux.sh for future changes."
