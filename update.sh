#!/bin/sh

nix flake update --reference-lock-file "flake-$HOSTNAME.lock" --output-lock-file "flake-$HOSTNAME.lock"
