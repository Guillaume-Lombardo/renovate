#!/bin/sh
set -eu

TAG="${1:-}"
PRIMARY_REMOTE_NAME="${PRIMARY_REMOTE_NAME:-origin}"
PRIMARY_BRANCH="${PRIMARY_BRANCH:-main}"
GITHUB_REMOTE_NAME="${GITHUB_REMOTE_NAME:-github}"
GITHUB_REMOTE_URL="${GITHUB_REMOTE_URL:-https://github.com/Guillaume-Lombardo/renovate.git}"

fail() {
  printf 'publish-github-snapshot: %s\n' "$*" >&2
  exit 1
}

tag_is_valid() {
  printf '%s' "$1" | grep -Eq '^v[0-9]{4}\.[0-9]{2}\.[0-9]{2}([.-][A-Za-z0-9]+)?$'
}

[ -n "$TAG" ] || fail "usage: scripts/publish-github-snapshot.sh vYYYY.MM.DD"
tag_is_valid "$TAG" || fail "tag must look like vYYYY.MM.DD"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not inside a git repository"

[ -z "$(git status --porcelain)" ] || fail "working tree is not clean"
[ "$(git branch --show-current)" = "$PRIMARY_BRANCH" ] || fail "current branch must be $PRIMARY_BRANCH"

github_url="$(git remote get-url "$GITHUB_REMOTE_NAME" 2>/dev/null || true)"
[ "$github_url" = "$GITHUB_REMOTE_URL" ] || fail "remote $GITHUB_REMOTE_NAME must point to $GITHUB_REMOTE_URL"

git fetch --no-tags \
  "$PRIMARY_REMOTE_NAME" \
  "+refs/heads/$PRIMARY_BRANCH:refs/remotes/$PRIMARY_REMOTE_NAME/$PRIMARY_BRANCH"
git fetch --no-tags \
  "$GITHUB_REMOTE_NAME" \
  "+refs/heads/$PRIMARY_BRANCH:refs/remotes/$GITHUB_REMOTE_NAME/$PRIMARY_BRANCH" \
  >/dev/null 2>&1 || true

current_commit="$(git rev-parse HEAD)"
primary_commit="$(git rev-parse "$PRIMARY_REMOTE_NAME/$PRIMARY_BRANCH")"
[ "$current_commit" = "$primary_commit" ] || fail "$PRIMARY_REMOTE_NAME/$PRIMARY_BRANCH is not at HEAD"

github_parent_args=""
if git rev-parse -q --verify "refs/remotes/$GITHUB_REMOTE_NAME/$PRIMARY_BRANCH" >/dev/null; then
  github_commit="$(git rev-parse "$GITHUB_REMOTE_NAME/$PRIMARY_BRANCH")"
  github_parent_args="-p $github_commit"
fi

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  fail "local tag already exists: $TAG"
fi

if git ls-remote --exit-code --tags "$PRIMARY_REMOTE_NAME" "refs/tags/$TAG" >/dev/null 2>&1; then
  fail "$PRIMARY_REMOTE_NAME tag already exists: $TAG"
fi

if git ls-remote --exit-code --tags "$GITHUB_REMOTE_NAME" "refs/tags/$TAG" >/dev/null 2>&1; then
  fail "$GITHUB_REMOTE_NAME tag already exists: $TAG"
fi

git tag -a "$TAG" -m "Snapshot $TAG"
github_snapshot_commit="$(
  # shellcheck disable=SC2086
  git commit-tree "$current_commit^{tree}" $github_parent_args \
    -m "Snapshot $TAG" \
    -m "GitLab commit: $current_commit"
)"

git push "$PRIMARY_REMOTE_NAME" "$TAG"
git push "$GITHUB_REMOTE_NAME" \
  "$github_snapshot_commit:refs/heads/$PRIMARY_BRANCH" \
  "$github_snapshot_commit:refs/tags/$TAG"

printf 'published snapshot %s to %s tags and %s/%s\n' "$TAG" "$PRIMARY_REMOTE_NAME" "$GITHUB_REMOTE_NAME" "$PRIMARY_BRANCH"
