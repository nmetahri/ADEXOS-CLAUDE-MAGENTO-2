---
description: Run a one-off command in the Magento 2 app container (www-data, non-interactive)
argument-hint: <command> [args...]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/m2-exec:*)
---
Output of running `$ARGUMENTS` in the app container:

!`"${CLAUDE_PLUGIN_ROOT}/scripts/m2-exec" $ARGUMENTS`
