#!/usr/bin/env bash
# Takes a fresh Linux/NixOS WSL setup and applies the Home Manager config.
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
  echo "    flake.nix is configured for user \"$FLAKE_USER\", but you are \"$REAL_USER\"."
  read -r -p "    Rewrite flake.nix's \"user = \" line to \"$REAL_USER\"? [y/N] " REPLY
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    sed -i -E "s/^([[:space:]]*user = \")[^\"]+(\";.*)/\1${REAL_USER}\2/" "$DIR/flake.nix"
    echo "    Updated."
  else
    echo "    Skipped. Edit the single \"user = \" line in flake.nix yourself before continuing."
    exit 1
  fi
else
  echo "    flake.nix already matches \"$REAL_USER\", nothing to do."
fi

# Bundle staging and switching into a single execution block
RUN_ACTIONS="
  echo '==> Step 3.5: Ensuring Git repository is initialized and files are staged'
  if [ ! -d '$DIR/.git' ]; then
    git -C '$DIR' init
  fi
  git -C '$DIR' add -A

  echo '==> Step 4: First home-manager switch (pinned to release-26.05)'
  NIX_CONFIG='experimental-features = nix-command flakes' \
    nix run github:nix-community/home-manager/release-26.05 -- \
    switch --flake ~/.dotfiles#${REAL_USER}@linux
"

if ! command -v git >/dev/null 2>&1; then
  echo "    git not found on PATH. Spawning transient nix-shell to provide git and run switch..."
  nix-shell -p git --run "$RUN_ACTIONS"
else
  eval "$RUN_ACTIONS"
fi

echo "==> Done. Use ./build-linux.sh for future changes."
