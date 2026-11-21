#!/usr/bin/env bash
# Release notes from conventional commits between the previous tag and HEAD.
#   tool/changelog.sh            # previous tag .. HEAD
#   tool/changelog.sh v1.0.0     # v1.0.0 .. HEAD
# Groups feat / fix / perf and lists the rest under "Other changes". Commits of
# type test, chore(deps) and docs are left out: they don't matter to a reader of
# the release page.
set -euo pipefail

from="${1:-$(git describe --tags --abbrev=0 --match 'v*' HEAD^ 2>/dev/null || true)}"
range="${from:+$from..}HEAD"

section() { # title, regex
  local lines
  lines=$(git log "$range" --no-merges --pretty='%s' | grep -E "$2" | sed -E 's/^[a-z]+(\([^)]*\))?(!)?: //' || true)
  if [ -n "$lines" ]; then
    printf '### %s\n\n' "$1"
    printf '%s\n' "$lines" | sed 's/^/* /'
    printf '\n'
  fi
}

section "New" '^feat(\(|!|:)'
section "Fixed" '^fix(\(|!|:)'
section "Faster" '^perf(\(|!|:)'
section "Other changes" '^(refactor|build|ci|chore)(\(|!|:)'
