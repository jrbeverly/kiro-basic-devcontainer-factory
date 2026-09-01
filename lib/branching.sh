#!/usr/bin/env bash
# Reusable branching helpers for the kiro deliverable/task model.
set -euo pipefail

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-*//;s/-*$//'
}

# git cannot hold a branch `kiro/<id>` and `kiro/<id>/<task>` together: the
# loose ref file for the first blocks the directory the second needs, so the
# integration branch lives at `kiro/<id>/integration`.
create_integration_branch() {
  local repo="$1"
  local deliverable_id="$2"
  git -C "$repo" checkout main
  git -C "$repo" branch "kiro/$deliverable_id/integration"
  echo "integration branch: kiro/$deliverable_id/integration"
}

create_task_branch() {
  local repo="$1"
  local deliverable_id="$2"
  local task_branch
  task_branch="kiro/$deliverable_id/$(slugify "$3")"
  git -C "$repo" checkout "kiro/$deliverable_id/integration"
  git -C "$repo" checkout -b "$task_branch"
  echo "task branch: $task_branch"
}

merge_task_branch() {
  local repo="$1"
  local deliverable_id="$2"
  local task_branch
  task_branch="kiro/$deliverable_id/$(slugify "$3")"
  git -C "$repo" checkout "kiro/$deliverable_id/integration"
  if git -C "$repo" merge-base --is-ancestor "$task_branch" "kiro/$deliverable_id/integration"; then
    echo "nothing to merge: $task_branch"
    return
  fi
  git -C "$repo" merge --no-ff "$task_branch" -m "Merge $task_branch" >/dev/null
  echo "merged $task_branch into kiro/$deliverable_id/integration"
}

"$@"
