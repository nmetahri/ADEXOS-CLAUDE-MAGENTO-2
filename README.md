# ADEXOS Claude Magento 2

A **Claude Code plugin** for Adexos Magento 2 projects. Enforces container-first development via the
custom maker, and provides secure read-only access to remote databases.

## What it does

- **`magento2` skill** — teaches Claude to use `make` targets / `/m2-exec` instead of host binaries
  (`php`, `composer`, `node`, `bin/magento`). Auto-loads when Claude works in a maker-based M2 project.
- **Secrets guard hook** — blocks the `Read` and `Bash` tools from accessing `~/.config/m2-secrets/`,
  even via `cat`. Always on.
- **`/m2-exec`** — run a one-off command in the app container (non-interactive, as `www-data`).
- **`/m2-db`** — read-only SQL queries against `local`, `preprod`, or `prod`. Local hits the `db`
  container; preprod/prod go over an ephemeral SSH tunnel. Credentials never appear in commands.
- **`/m2-db-setup`** — set up DB credentials per project/env (interactive, run in your terminal).
- **`/m2-init`** — generate a tailored `CLAUDE.md` for a project (env, stack, custom make targets).

## Install

In Claude Code:

```
/plugin marketplace add nmetahri/ADEXOS-CLAUDE-MAGENTO-2
/plugin install adexos-magento2@adexos
```

> Requires `docker compose`, `mysql`, `ssh` (for preprod/prod tunnels), and `jq` (used by the
> secrets-guard hook) on the host.

That's it — no shell bootstrap, no `settings.json` patching. The plugin ships its own hook, skill,
and commands.

## Per-project setup

From a Magento 2 project root (where `Makefile` and `.env` live):

```
/m2-init
```

Generates `CLAUDE.md` with project-specific environment and detected make targets. Re-run with
`/m2-init --force` to overwrite.

## DB queries

All read-only, via `/m2-db <env> "<query>"`:

```
/m2-db local   "SELECT COUNT(*) FROM core_config_data"
/m2-db preprod "SELECT store_id, code FROM store"
/m2-db prod    "SELECT COUNT(*) FROM sales_order WHERE status = 'pending'"
```

- **`local`** runs inside the `db` container (`docker compose exec`). It uses the maker's default
  credentials, so no setup is needed unless a project customised the local DB user/password.
- **`preprod` / `prod`** open an ephemeral `ssh -L` tunnel to the remote host (matching how a
  PhpStorm data source connects), then run the query through it. SSH auth uses your key/agent.

Set up credentials once per project/env. Because it prompts for a password, run it yourself in the
terminal with the `!` prefix (keeps the password out of the transcript):

```
! "${CLAUDE_PLUGIN_ROOT}/scripts/m2-db-setup" <project> <local|preprod|prod>
```

`local` setup asks only for a DB user/password; `preprod`/`prod` also ask for the SSH host/user and
the DB host/port/name. Credentials are stored in `~/.config/m2-secrets/<project>-<env>.cnf`
(chmod 600, `KEY=VALUE`). The secrets-guard hook prevents Claude from reading them.

## Running container commands

```
/m2-exec bin/magento module:status
/m2-exec bin/magento indexer:reindex
/m2-exec composer diagnose
```

Or use the `make` targets documented in the `magento2` skill (`make cf`, `make comin`, `make setup`, …).

## Plugin layout

| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.claude-plugin/marketplace.json` | Single-plugin marketplace (this repo) |
| `hooks/hooks.json` | Secrets-guard hook (Read + Bash) |
| `skills/magento2/SKILL.md` | Container-first development rules |
| `commands/*.md` | `/m2-init`, `/m2-exec`, `/m2-db`, `/m2-db-setup` |
| `scripts/*` | Shell scripts backing the commands and hook |

## Note on local usage

This is a **pure plugin**: `m2-exec` / `m2-db` are not installed on your `PATH`. They run only through
their slash commands inside Claude Code, not as standalone terminal commands.
