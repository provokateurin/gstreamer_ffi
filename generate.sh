#!/usr/bin/env bash
set -euxo pipefail

for file in lib/src/*.yaml; do
  dart run ffigen --config "$file"
done
