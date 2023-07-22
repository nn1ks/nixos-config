#!/bin/sh

if [ ! -f flake.nix ]; then
  echo "The file flake.lock already exists" >&2
  exit 1
fi

# Copy device-specific lock file to flake.lock because nixos-rebuild does not allow specifying a
# custom path for it
cp "flake-$HOSTNAME.lock" flake.lock || exit 1

sudo nixos-rebuild switch --flake .

# Remove the copied lock file
rm flake.lock
