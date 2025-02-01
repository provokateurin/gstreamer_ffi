#!/usr/bin/env bash
set -euo pipefail

out="$(nix-build --no-out-link ffigen.nix)"
cp "$out"/* lib/src/
chmod 755 lib/src/*
