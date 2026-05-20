# Security Best Practices Report

## Executive Summary

No committed GitLab/GitHub PAT, private key, AWS key, Slack token, JWT, or similar secret was found in the tracked working tree or in Git history using targeted regex searches and `detect-secrets`.

The local `.env` file is correctly ignored by Git, but it does contain live secrets. Those values were not committed, but they should still be treated as sensitive runtime credentials and rotated if this machine, terminal session, logs, backups, or agent transcript are not fully trusted.

## Critical

No critical committed secret leak was found.

## High

No high committed secret leak was found.

## Medium

### M-1: GitLab admin PAT was passed to `curl` as a command-line header

Evidence:

- Previous implementation of `scripts/add-renovate-member.sh`.

The previous script passed `PRIVATE-TOKEN: ${GITLAB_ADMIN_TOKEN}` as a `curl --header` argument. On systems where process arguments are visible to other users or diagnostics, this could expose the token while the request is running.

Status:

- Fixed by routing GitLab API requests through `curl_gitlab`, which passes the header via curl config on stdin.

### M-2: Predictable response file in `/tmp` was used

Evidence:

- Previous implementation of `scripts/add-renovate-member.sh`.

The previous script wrote GitLab error responses to `/tmp/gitlab-member-sync-response`. This probably did not contain the PAT, but a predictable path in `/tmp` was avoidable and could cause accidental disclosure or interference.

Status:

- Fixed with `umask 077`, `mktemp`, and cleanup via `trap`.

## Low

### L-1: Runtime secrets are passed as container environment variables

Evidence:

- `compose.yaml:9`
- `compose.yaml:10`
- `compose.yaml:19`

This is common for Compose deployments, but environment variables can be visible through container inspection to users with Docker access.

Recommendation:

- Prefer the deployment platform's secret mechanism when available.
- Restrict Docker daemon access to trusted operators only.

## Positive Findings

- `.env` and `.env.*` are ignored while `.env.example` remains tracked.
- `.env.example` contains placeholders, not real token values.
- `.gitlab-ci.yml` uses placeholder values for token-like variables.
- Git remotes are plain HTTPS repository URLs and do not embed credentials.
- The container does not mount the Docker socket.
- Compose drops all capabilities and enables `no-new-privileges`.
- Validation commands passed for `node --check config.js` and `sh -n scripts/*.sh`.

## Commands Run

- `git status --short --ignored`
- `git ls-files`
- targeted `rg` searches for PATs, tokens, private keys, AWS keys, JWT-like strings, and secret keywords
- Git history search for common secret patterns
- `detect-secrets scan --all-files --exclude-files '^\\.git/' --exclude-files '^\\.env$'`
- `git remote -v`
- `git config --local --get-regexp 'remote\\..*\\.url|url\\..*|credential\\..*'`
- `node --check config.js`
- `sh -n scripts/*.sh`
