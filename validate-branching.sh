#!/usr/bin/env bash
# Validates the branching model: run the factory, then assert the branch topology.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
EPIC_ID="ACME-1234"
REPO="$ROOT/repos/acme-iac"
INTEGRATION="kiro/$EPIC_ID/integration"

bash "$ROOT/bootstrap.sh"
bash "$ROOT/pdlc.sh" "$EPIC_ID"
bash "$ROOT/execute.sh" "$EPIC_ID"

fail() {
  echo "validate> FAIL: $1"
  exit 1
}

git -C "$REPO" show-ref --verify --quiet "refs/heads/$INTEGRATION" \
  || fail "missing integration branch $INTEGRATION"
echo "validate> integration branch: $INTEGRATION"

for plan in "$ROOT/plans/$EPIC_ID"/*.md; do
  title="$(sed -n 's/^title: //p' "$plan" | head -1)"
  branch="kiro/$EPIC_ID/$(bash "$ROOT/lib/branching.sh" slugify "$title")"
  git -C "$REPO" show-ref --verify --quiet "refs/heads/$branch" \
    || fail "missing task branch $branch"
  git -C "$REPO" merge-base --is-ancestor "$branch" "$INTEGRATION" \
    || fail "task branch not merged: $branch"
  echo "validate> merged: $branch"
done

[ "$(git -C "$REPO" rev-list --count main)" = "1" ] || fail "task work reached main"
echo "validate> main untouched"

[ -z "$(git -C "$REPO" remote)" ] || fail "expected no remotes"
echo "validate> no remotes"

git -C "$REPO" log --graph --oneline --all
echo "validate> ok"
