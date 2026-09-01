#!/usr/bin/env bash
# Destroys repos/ and recreates it from references/: copy it over, rebuild each
# Dev Container so the run starts from a known working state, then commit the
# scaffold that resulted.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

rm -rf "$ROOT/repos"
mkdir -p "$ROOT/repos"

for reference in "$ROOT"/references/*/; do
  name="$(basename "$reference")"
  repo="$ROOT/repos/$name"

  cp -R "$reference" "$repo"

  bash "$ROOT/lib/devcontainer.sh" recreate "$repo"
  bash "$ROOT/lib/devcontainer.sh" sanity_check "$repo"

  git -C "$repo" init -b main
  git -C "$repo" config user.name "bootstrap"
  git -C "$repo" config user.email "bootstrap@kiro.local"
  git -C "$repo" add .
  git -C "$repo" commit -m "Initial repository scaffold"

  echo "bootstrap> $name ready"
done
