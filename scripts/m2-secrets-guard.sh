#!/usr/bin/env bash
# Block Read and Bash tool access to m2-secrets credential directory.
# Checks for the specific secrets path, not the hook script name.
# Exit 2 = deny the tool call.

# One jq pass: emit the file_path and command fields the tool call might carry.
TOOL_FIELDS=$(jq -r '(.tool_input.file_path // empty), (.tool_input.command // empty)')

SECRETS_PATH=".config/m2-secrets"

if [[ "$TOOL_FIELDS" == *"$SECRETS_PATH"* ]]; then
    echo "Access denied: ~/.config/m2-secrets/ credential files are protected." >&2
    exit 2
fi

exit 0
