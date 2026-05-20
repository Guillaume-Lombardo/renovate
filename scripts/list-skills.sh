#!/bin/sh
set -eu

ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"

find "$ROOT/skills" -mindepth 3 -maxdepth 3 -type f -name 'SKILL.md' | sort | while IFS= read -r skill_file; do
  skill_dir="$(dirname -- "$skill_file")"
  category_dir="$(dirname -- "$skill_dir")"
  category="$(basename -- "$category_dir")"
  name="$(basename -- "$skill_dir")"
  path="${skill_file#"$ROOT"/}"

  printf '%s %s %s\n' "$category" "$name" "$path"
done
