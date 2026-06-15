---
description: How to set up remote DB credentials for a Magento 2 project (interactive)
argument-hint: [project] [local|preprod|prod]
---
Credential setup is **interactive** (it prompts for a DB password) and must run in a real terminal,
not through the assistant — otherwise the password would land in the transcript.

Tell the user to run it themselves with the `!` prefix in the Claude Code prompt:

```
! "${CLAUDE_PLUGIN_ROOT}/scripts/m2-db-setup" $ARGUMENTS
```

It writes `~/.config/m2-secrets/<project>-<env>.cnf` (chmod 600, `KEY=VALUE` format).
Those files are read-protected by the plugin hook — never read or echo them.
