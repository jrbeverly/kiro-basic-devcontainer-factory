#!/usr/bin/env bash
# Archives a finished run under samples/<epic-id>/<run>/: the repository the
# factory produced, the work items it carried out, and the notes it wrote. The
# repository comes out of git rather than off disk, so no .git and nothing the
# repository ignores follows it into the sample.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
EPIC_ID="${1:?usage: bash stash.sh <epic-id>}"

REPO_PATH="$(sed -n 's/^repository: //p' "$ROOT/epics/$EPIC_ID.md" | head -1)"
REPO="$ROOT/$REPO_PATH"
REPO_NAME="$(basename "$REPO_PATH")"
RUN="$(ls -1 "$ROOT/AI_NOTES/$EPIC_ID" | tail -1)"
SAMPLE="$ROOT/samples/$EPIC_ID/$RUN"

rm -rf "$SAMPLE"
mkdir -p "$SAMPLE/$REPO_NAME"

git -C "$REPO" archive "kiro/$EPIC_ID/integration" | tar -x -C "$SAMPLE/$REPO_NAME"
cp -R "$ROOT/plans/$EPIC_ID" "$SAMPLE/plans"
cp -R "$ROOT/AI_NOTES/$EPIC_ID/$RUN" "$SAMPLE/notes"

echo "stash> samples/$EPIC_ID/$RUN"
