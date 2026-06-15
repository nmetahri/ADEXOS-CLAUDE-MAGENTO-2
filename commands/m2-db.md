---
description: Run a read-only SQL query against a Magento 2 DB (local/preprod/prod)
argument-hint: <local|preprod|prod> "<SQL query>"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/m2-db:*)
---
Result of the read-only query (`$ARGUMENTS`):

!`"${CLAUDE_PLUGIN_ROOT}/scripts/m2-db" $ARGUMENTS`
