#!/usr/bin/env bash
# Shared helpers for the m2-* scripts. Source this file, do not execute it.
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/m2-common.sh"

# Walk up from $PWD to the nearest directory containing a .env file.
# Echoes the directory path on success; returns 1 if none is found.
m2_find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        [[ -f "$dir/.env" ]] && { printf '%s\n' "$dir"; return 0; }
        dir="$(dirname "$dir")"
    done
    return 1
}

# Read a single KEY's value from an env-style file. Quotes are stripped.
#   m2_read_env <file> <key>
m2_read_env() {
    grep -E "^$2=" "$1" 2>/dev/null | head -n1 | cut -d= -f2- | tr -d '"' | tr -d "'" || true
}

# Echo the project's PROJECT_NAME (from <root>/.env), or fail with a message.
#   m2_project_name <root>
m2_project_name() {
    local name
    name=$(m2_read_env "$1/.env" PROJECT_NAME)
    [[ -n "$name" ]] || { echo "Error: PROJECT_NAME not set in $1/.env" >&2; return 1; }
    printf '%s\n' "$name"
}

# Build the project's base `docker compose` command into the global array DC.
# Mirrors the maker's own DC variable (see the Makefile).
#   m2_compose_cmd <root> <project_name>
m2_compose_cmd() {
    local root="$1" project="$2" extra=()
    [[ -f "$root/.maker/docker-compose.yml" ]] \
        || { echo "Error: no .maker/docker-compose.yml in $root (run 'make pull')" >&2; return 1; }
    [[ -f "$root/docker-compose.yml" ]] && extra=(-f "$root/docker-compose.yml")
    DC=(docker compose -p "$project" -f "$root/.maker/docker-compose.yml" "${extra[@]}" --env-file="$root/.env")
}
