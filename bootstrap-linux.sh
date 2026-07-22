#!/usr/bin/env bash
# Takes a fresh Linux/NixOS WSL setup and applies the NixOS system config.
# Run this once.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Verify Nix environment"
if command -v nix >/dev/null 2>&1; then
    echo "    nix is installed (expected on NixOS)"
else
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: Symlink this repo to ~/.dotfiles"
ln -sfn "$DIR" ~/.dotfiles

# Fix Git ownership issues (common on WSL /mnt/c)
if command -v git >/dev/null 2>&1; then
    git config --global --add safe.directory "$DIR" || true
    git config --global --add safe.directory ~/.dotfiles || true
fi

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

# Bundle staging and switching into a single execution block
RUN_ACTIONS="
    # Environment Guard: Ensure Nix and Home Manager are in PATH
    for profile in \
        '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' \
        '/etc/profile.d/nix.sh' \
        '\$HOME/.nix-profile/etc/profile.d/nix.sh' \
        '\$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh'
    do
        if [ -e \"\$profile\" ]; then
            . \"\$profile\"
        fi
    done

    if [ -e /etc/NIXOS ]; then
        echo '==> Step 4: First NixOS system switch'
        sudo nixos-rebuild switch --flake ~/.dotfiles#linux
        echo '==> Done. NixOS system is initialized.'
        echo '    Next steps:'
        echo '    1. Restart WSL or re-login to switch to the new user account.'
        echo '    2. Run ~/.dotfiles/build-linux.sh to complete user-level setup and install mise tools.'
    else
        echo '==> Step 4: First Home Manager switch'
        # Use nix run to provide home-manager for the first-time switch
        nix run github:nix-community/home-manager/release-26.05 -- switch --refresh --flake ~/.dotfiles#linux -b backup
        echo '==> Done. Home Manager is initialized.'
        echo '    Next steps:'
        echo '    1. Restart your terminal.'
        echo '    2. Run ~/.dotfiles/build-linux.sh to ensure all tools are installed.'
    fi
"

if ! command -v git >/dev/null 2>&1; then
    echo "    git not found on PATH. Spawning transient nix-shell to provide git and run switch..."
    nix-shell -p git --run "$RUN_ACTIONS"
else
    eval "$RUN_ACTIONS"
fi

echo "==> Done. Use ./build-linux.sh for future changes."
