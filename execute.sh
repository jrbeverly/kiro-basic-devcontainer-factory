#!/usr/bin/env bash
# Carries out each work-item plan in order, one Kiro session per item. Each run
# gets its own number, so notes land in AI_NOTES/<epic>/<run>/<work-item>.md and
# nothing is appended to a previous run's file.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
EPIC_ID="${1:?usage: bash execute.sh <epic-id>}"
REPAIR_ATTEMPTS=2

REPO_PATH="$(sed -n 's/^repository: //p' "$ROOT/epics/$EPIC_ID.md" | head -1)"
REPO="$ROOT/$REPO_PATH"

mkdir -p "$ROOT/AI_NOTES/$EPIC_ID"
PREVIOUS_RUNS="$(ls -1 "$ROOT/AI_NOTES/$EPIC_ID" | wc -l)"
RUN="$(printf '%03d' "$((PREVIOUS_RUNS + 1))")"
NOTES="$ROOT/AI_NOTES/$EPIC_ID/$RUN"
mkdir -p "$NOTES"
echo "execute> $EPIC_ID run $RUN"

rm -rf "$REPO/.factory"

bash "$ROOT/lib/branching.sh" create_integration_branch "$REPO" "$EPIC_ID"

for plan in "$ROOT/plans/$EPIC_ID"/*.md; do
  ITEM="$(basename "$plan" .md)"
  ITEM_TITLE="$(sed -n 's/^title: //p' "$plan" | head -1)"
  PLAN_BODY="$(cat "$plan")"
  export PLAN_BODY

  bash "$ROOT/lib/branching.sh" create_task_branch "$REPO" "$EPIC_ID" "$ITEM_TITLE"
  bash "$ROOT/lib/devcontainer.sh" up "$REPO"
  bash "$ROOT/lib/devcontainer.sh" sanity_check "$REPO"

  PROMPT="$(envsubst '$PLAN_BODY' < "$ROOT/prompts/execute.md")"
  bash "$ROOT/lib/devcontainer.sh" session "$REPO" "$PROMPT"

  log="$(mktemp)"
  attempt=0
  until bash "$ROOT/lib/devcontainer.sh" validate_repository "$REPO" 2>&1 | tee "$log"; do
    attempt=$((attempt + 1))
    if [ "$attempt" -gt "$REPAIR_ATTEMPTS" ]; then
      echo "execute> $ITEM still failing after $REPAIR_ATTEMPTS repair attempts" >&2
      exit 1
    fi
    echo "execute> $ITEM failed validation, repair attempt $attempt"
    VALIDATION_OUTPUT="$(cat "$log")"
    export VALIDATION_OUTPUT
    PROMPT="$(envsubst '$PLAN_BODY $VALIDATION_OUTPUT' < "$ROOT/prompts/repair.md")"
    bash "$ROOT/lib/devcontainer.sh" session "$REPO" "$PROMPT"
  done
  rm -f "$log"

  if [ -f "$REPO/.factory/notes.md" ]; then
    mv "$REPO/.factory/notes.md" "$NOTES/$ITEM.md"
  fi
  rm -rf "$REPO/.factory"

  git -C "$REPO" add -A
  git -C "$REPO" diff --cached --quiet \
    || git -C "$REPO" commit -m "$EPIC_ID $ITEM: $ITEM_TITLE"

  bash "$ROOT/lib/branching.sh" merge_task_branch "$REPO" "$EPIC_ID" "$ITEM_TITLE"
done

echo "execute> notes in AI_NOTES/$EPIC_ID/$RUN"
