#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-main}"
COMMIT_MSG="${2:-update review reports}"

git add .

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "$COMMIT_MSG"
git push origin "$BRANCH"