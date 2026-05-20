#!/bin/sh
set -eu

GITHUB_REMOTE_NAME="${GITHUB_REMOTE_NAME:-github}"
GITHUB_REMOTE_URL="${GITHUB_REMOTE_URL:-https://github.com/Guillaume-Lombardo/renovate.git}"

fail() {
  printf 'setup-github-snapshot-remote: %s\n' "$*" >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not inside a git repository"

if git remote get-url "$GITHUB_REMOTE_NAME" >/dev/null 2>&1; then
  current_url="$(git remote get-url "$GITHUB_REMOTE_NAME")"
  if [ "$current_url" != "$GITHUB_REMOTE_URL" ]; then
    fail "remote $GITHUB_REMOTE_NAME already points to $current_url, expected $GITHUB_REMOTE_URL"
  fi

  printf 'remote %s already configured: %s\n' "$GITHUB_REMOTE_NAME" "$GITHUB_REMOTE_URL"
  exit 0
fi

git remote add "$GITHUB_REMOTE_NAME" "$GITHUB_REMOTE_URL"
printf 'configured remote %s: %s\n' "$GITHUB_REMOTE_NAME" "$GITHUB_REMOTE_URL"
