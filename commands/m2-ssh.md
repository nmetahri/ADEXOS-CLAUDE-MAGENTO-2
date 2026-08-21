---
description: Read logs or host status on a Magento 2 preprod/prod server (restricted SSH)
argument-hint: <preprod|prod> <command> [args...]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/m2-ssh:*)
---
Output of the restricted remote command (`$ARGUMENTS`):

!`"${CLAUDE_PLUGIN_ROOT}/scripts/m2-ssh" $ARGUMENTS`
