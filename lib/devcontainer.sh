#!/usr/bin/env bash
# Dev Container operations. Every Kiro session runs through here, so the
# workspace folder is the only place a session can reach.
set -euo pipefail

MODEL="qwen3-coder-next"
AGENT="factory"

recreate() {
  local repo="$1"
  devcontainer build --workspace-folder "$repo" </dev/null
  devcontainer up --remove-existing-container --workspace-folder "$repo" </dev/null
}

up() {
  local repo="$1"
  devcontainer up --workspace-folder "$repo" </dev/null
}

sanity_check() {
  local repo="$1"
  devcontainer exec --workspace-folder "$repo" \
    sh -c 'kiro-cli --version && test -f Makefile' </dev/null
  echo "sanity> $repo: kiro-cli responds and the workspace holds the repository"
}

session() {
  local repo="$1"
  local prompt="$2"
  devcontainer exec --workspace-folder "$repo" \
    kiro-cli chat --no-interactive --trust-all-tools --agent "$AGENT" --model "$MODEL" "$prompt" </dev/null
}

validate_repository() {
  local repo="$1"
  echo "validation> running: make validate inside the $repo container"
  devcontainer exec --workspace-folder "$repo" make validate </dev/null
}

"$@"
