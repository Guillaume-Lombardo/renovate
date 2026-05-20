#!/bin/sh
set -eu
umask 077

: "${GITLAB_URL:=https://gitlab.g1lom.xyz}"
: "${GITLAB_PROJECT_OWNER:=g1lom}"
: "${GITLAB_RENOVATE_ACCESS_LEVEL:=30}"

if [ -z "${GITLAB_ADMIN_TOKEN:-}" ]; then
  printf '%s Skipping GitLab member sync: GITLAB_ADMIN_TOKEN is not set\n' "$(date -Iseconds)"
  exit 0
fi

if [ -z "${GITLAB_RENOVATE_BOT_USER_ID:-}" ]; then
  printf '%s Skipping GitLab member sync: GITLAB_RENOVATE_BOT_USER_ID is not set\n' "$(date -Iseconds)"
  exit 0
fi

json_length() {
  if command -v jq >/dev/null 2>&1; then
    jq 'length'
  else
    node -e 'let input = ""; process.stdin.on("data", chunk => input += chunk); process.stdin.on("end", () => console.log(JSON.parse(input).length));'
  fi
}

project_ids() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.[].id'
  else
    node -e 'let input = ""; process.stdin.on("data", chunk => input += chunk); process.stdin.on("end", () => JSON.parse(input).forEach(project => console.log(project.id)));'
  fi
}

curl_gitlab() {
  curl --config - "$@" <<EOF
header = "PRIVATE-TOKEN: ${GITLAB_ADMIN_TOKEN}"
EOF
}

gitlab_url="${GITLAB_URL%/}"
response_file="$(mktemp "${TMPDIR:-/tmp}/gitlab-member-sync-response.XXXXXX")"
trap 'rm -f "$response_file"' EXIT HUP INT TERM
page=1

while :; do
  projects="$(
    curl_gitlab -fsS \
      "${gitlab_url}/api/v4/users/${GITLAB_PROJECT_OWNER}/projects?per_page=100&page=${page}&simple=true"
  )"

  count="$(printf '%s' "$projects" | json_length)"
  [ "$count" -eq 0 ] && break

  printf '%s Syncing renovate-bot membership for %s project(s), page %s\n' \
    "$(date -Iseconds)" "$count" "$page"

  printf '%s' "$projects" | project_ids | while IFS= read -r project_id; do
    [ -n "$project_id" ] || continue

    http_code="$(
      curl_gitlab -sS -o "$response_file" \
        -w '%{http_code}' \
        --request POST \
        --data-urlencode "user_id=${GITLAB_RENOVATE_BOT_USER_ID}" \
        --data-urlencode "access_level=${GITLAB_RENOVATE_ACCESS_LEVEL}" \
        "${gitlab_url}/api/v4/projects/${project_id}/members"
    )"

    case "$http_code" in
      201)
        printf '%s Added renovate-bot to project %s\n' "$(date -Iseconds)" "$project_id"
        ;;
      409)
        printf '%s renovate-bot is already a direct member of project %s\n' "$(date -Iseconds)" "$project_id"
        ;;
      *)
        printf '%s Failed to add renovate-bot to project %s: HTTP %s\n' \
          "$(date -Iseconds)" "$project_id" "$http_code" >&2
        cat "$response_file" >&2
        printf '\n' >&2
        exit 1
        ;;
    esac
  done

  page=$((page + 1))
done
