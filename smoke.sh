#!/usr/bin/env bash
# Smoke: every bootstrapped repository's Dev Container comes up and can host a
# Kiro session.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

for config in "$ROOT"/repos/*/.devcontainer/devcontainer.json; do
  repo="$(dirname "$(dirname "$config")")"
  echo "smoke> $repo"
  bash "$ROOT/lib/devcontainer.sh" up "$repo"
  bash "$ROOT/lib/devcontainer.sh" sanity_check "$repo"
done

echo "smoke> ok"
