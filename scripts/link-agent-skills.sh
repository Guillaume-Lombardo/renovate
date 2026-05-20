#!/bin/sh
set -eu

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
AGENT="${1:-}"

usage() {
  printf 'usage: scripts/link-agent-skills.sh codex|claude|opencode\n' >&2
  exit 1
}

[ -n "$AGENT" ] || usage

case "$AGENT" in
  codex)
    target="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
    ;;
  claude)
    target="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
    ;;
  opencode)
    target="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
    ;;
  *)
    usage
    ;;
esac

mkdir -p "$target"

"$ROOT/scripts/list-skills.sh" | while IFS=' ' read -r category name path; do
  skill_dir="$(dirname -- "$ROOT/$path")"
  ln -sfn "$skill_dir" "$target/$name"
  printf 'linked %s/%s -> %s (%s)\n' "$target" "$name" "$skill_dir" "$category"
done
