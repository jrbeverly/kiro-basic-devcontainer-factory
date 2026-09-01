#!/usr/bin/env bash
# Turns an epic into the ordered work-item plans the executor carries out. Only
# the epic body crosses into the container; the front matter carries the epic id
# and the factory path, which the session must never see.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
EPIC_ID="${1:?usage: bash pdlc.sh <epic-id>}"
EPIC="$ROOT/epics/$EPIC_ID.md"

REPO_PATH="$(sed -n 's/^repository: //p' "$EPIC" | head -1)"
REPO="$ROOT/$REPO_PATH"
EPIC_BODY="$(sed '1,/^---$/d' "$EPIC")"
export EPIC_BODY

PROMPT="$(envsubst '$EPIC_BODY' < "$ROOT/prompts/pdlc.md")"

rm -rf "$REPO/.factory"
bash "$ROOT/lib/devcontainer.sh" up "$REPO"
bash "$ROOT/lib/devcontainer.sh" sanity_check "$REPO"
bash "$ROOT/lib/devcontainer.sh" session "$REPO" "$PROMPT"

rm -rf "$ROOT/plans/$EPIC_ID"
mkdir -p "$ROOT/plans/$EPIC_ID"
mv "$REPO"/.factory/plans/*.md "$ROOT/plans/$EPIC_ID/"
rm -rf "$REPO/.factory"

ls "$ROOT/plans/$EPIC_ID"
