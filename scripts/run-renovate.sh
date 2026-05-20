#!/bin/sh
set -eu

: "${RENOVATE_TOKEN:?Set RENOVATE_TOKEN in .env}"
: "${RENOVATE_RUN_INTERVAL_SECONDS:=21600}"
: "${RENOVATE_BASE_DIR:=/tmp/renovate}"
: "${RENOVATE_CACHE_DIR:=${RENOVATE_BASE_DIR}/cache}"
: "${RENOVATE_RUNTIME_UID:=1000}"
: "${RENOVATE_RUNTIME_GID:=1000}"
: "${RENOVATE_RUNTIME_HOME:=/home/ubuntu}"

prepare_renovate_dirs() {
  mkdir -p "$RENOVATE_BASE_DIR" "$RENOVATE_CACHE_DIR"

  if [ "$(id -u)" -eq 0 ]; then
    chown -R "${RENOVATE_RUNTIME_UID}:${RENOVATE_RUNTIME_GID}" \
      "$RENOVATE_BASE_DIR" "$RENOVATE_CACHE_DIR"
  fi
}

run_renovate() {
  HOME="$RENOVATE_RUNTIME_HOME" renovate
}

prepare_renovate_dirs

while true; do
  printf '%s Starting Renovate run\n' "$(date -Iseconds)"

  /usr/local/bin/add-renovate-member.sh

  status=0
  run_renovate || status=$?

  if [ "$status" -eq 0 ]; then
    printf '%s Renovate run completed successfully\n' "$(date -Iseconds)"
  else
    printf '%s Renovate run failed with exit code %s\n' "$(date -Iseconds)" "$status" >&2
  fi

  printf '%s Sleeping for %s seconds\n' "$(date -Iseconds)" "$RENOVATE_RUN_INTERVAL_SECONDS"
  sleep "$RENOVATE_RUN_INTERVAL_SECONDS"
done
