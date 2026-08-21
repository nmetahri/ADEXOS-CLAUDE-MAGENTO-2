#!/usr/bin/env bash
# Deny tool calls that would expose credentials, locally or on a remote server.
# Checks the tool payload itself, not the hook script name.
# Exit 2 = deny the tool call.

# One jq pass: emit the file_path and command fields the tool call might carry.
TOOL_FIELDS=$(jq -r '(.tool_input.file_path // empty), (.tool_input.command // empty)')

# Local credential store written by m2-db-setup.
readonly LOCAL_SECRETS_PATH=".config/m2-secrets"

# Remote transports that could pull a file off a preprod/prod server. The word
# boundaries exclude ssh-add, ssh-keygen and ssh-copy-id, which touch no project file.
readonly REMOTE_TRANSPORT_PATTERN='(^|[^-[:alnum:]_])(ssh|scp|sftp|rsync)([^-[:alnum:]_]|$)'
# Commands that read a remote file's contents once a transport is involved.
readonly REMOTE_READ_PATTERN='(^|[^-[:alnum:]_])(cat|less|more|head|tail|grep|egrep|awk|sed|strings|xxd|base64|od|cp|tar|zip)([^-[:alnum:]_]|$)'
# Files that carry Magento credentials on a deployed server.
readonly SECRET_FILE_PATTERN='(\.env|env\.php|config\.php|auth\.json|\.my\.cnf|\.netrc|id_rsa|id_ed25519|\.ssh/|credentials)'
# The only remote locations m2-ssh exposes; a transport touching just these is fine.
readonly LOG_PATH_PATTERN='var/(log|report)'
# The plugin's own scripts already enforce their allowlists.
readonly PLUGIN_SCRIPT_PATTERN='scripts/m2-(ssh|db)([^-[:alnum:]]|$)'

deny() {
    echo "Access denied: $1" >&2
    exit 2
}

if [[ "$TOOL_FIELDS" == *"$LOCAL_SECRETS_PATH"* ]]; then
    deny "~/.config/m2-secrets/ credential files are protected."
fi

if [[ "$TOOL_FIELDS" =~ $PLUGIN_SCRIPT_PATTERN ]]; then
    exit 0
fi

if [[ "$TOOL_FIELDS" =~ $REMOTE_TRANSPORT_PATTERN ]]; then
    if [[ "$TOOL_FIELDS" =~ $SECRET_FILE_PATTERN ]]; then
        deny "reading deployment secrets over SSH is not allowed. Use /m2-db for database access."
    fi
    if [[ "$TOOL_FIELDS" =~ $REMOTE_READ_PATTERN && ! "$TOOL_FIELDS" =~ $LOG_PATH_PATTERN ]]; then
        deny "reading remote files over SSH is restricted to var/log and var/report. Use /m2-ssh."
    fi
fi

exit 0
