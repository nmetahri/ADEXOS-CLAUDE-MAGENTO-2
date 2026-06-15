---
name: magento2
description: Development rules for Adexos Magento 2 projects using the custom maker. Use when working in a Magento 2 project (Makefile + .maker/ directory), or when running bin/magento, composer, cache, indexer, deploy, or querying preprod/prod databases.
---

# Magento 2 — Development Rules (Adexos maker)

## Container-First: Non-Negotiable

**NEVER** run system binaries for project work. No `php`, `node`, `npm`, `composer`, `bin/magento` directly on the host.
**ALWAYS** go through the containers via `make` targets or the `/m2-exec` command.

| Forbidden | Required equivalent |
|---|---|
| `php bin/magento ...` | `/m2-exec bin/magento ...` or `make magerun ...` |
| `composer install` | `make comin` |
| `composer update` | `make comup` |
| `composer update --lock` | `make comupl` |
| `node / npm / yarn` | `/m2-exec npm ...` (runs inside the container) |
| `bin/magento cache:flush` | `make cf` |
| `bin/magento setup:upgrade` | `make setup` |

## Running One-Off Commands in the Container

Use the **`/m2-exec`** command for any one-off command. It auto-detects the project from the nearest `.env`
and runs non-interactively as `www-data`.

```
/m2-exec bin/magento module:status
/m2-exec bin/magento indexer:reindex
/m2-exec composer diagnose
/m2-exec bin/magento deploy:mode:show
```

**NEVER use `make ex` or `make exa`** — these open an interactive TTY shell that blocks execution.
They are for human use only.

## Make Command Reference

### Docker Lifecycle
| Command | Description |
|---|---|
| `make up` | Pull images and start all containers |
| `make do` | Stop all containers |
| `make rr` | Restart (down + up) |
| `make logs` | Follow live container logs |
| `make ccv` | Restart Varnish |

### Shell Access (human only — NOT usable by Claude)
| Command | Note |
|---|---|
| `make ex` | Interactive shell as www-data — **blocks, do not use** |
| `make exa` | Interactive shell as root — **blocks, do not use** |

### Magento Operations
| Command | Description |
|---|---|
| `make cf` | `cache:flush` |
| `make cc` | Cache clean with file watcher |
| `make hac` | Hard clean: rm var/cache + generated/code |
| `make soc <KEYS>` | Soft clean: remove only cache files matching KEYS |
| `make setup` | `setup:upgrade` |
| `make magerun <cmd>` | Run any n98-magerun2 command |

### Composer
| Command | Description |
|---|---|
| `make comin` | `composer install` |
| `make comup` | `composer update` |
| `make comupl` | `composer update --lock` |

### Database (local)
| Command | Description |
|---|---|
| `make dbim <file.sql>` | Import SQL dump into local DB |
| `make dbex <db_name>` | Export local DB to dump.sql |

### Code Quality
| Command | Description |
|---|---|
| `make ginit` | Init grumphp git hooks |
| `make grumphp <branch>` | Run grumphp against target branch |

## Database Access (Local / Preprod / Prod)

Use the **`/m2-db`** command for every environment. It is read-only. **Never** put raw
credentials in commands.

```
/m2-db <env> "<SQL query>"

/m2-db local   "SELECT COUNT(*) FROM core_config_data"
/m2-db preprod "SELECT store_id, code FROM store"
/m2-db prod    "SELECT COUNT(*) FROM sales_order WHERE status = 'pending'"
```

- `local` runs in the `db` container. It uses the maker's standard credentials by default;
  if a project customised the local DB user/password, configure it with `/m2-db-setup`.
- `preprod` / `prod` connect over an ephemeral SSH tunnel using credentials from `/m2-db-setup`.

**Rules:**
- Only SELECT/SHOW/DESCRIBE/EXPLAIN queries — access is read-only.
- Never print or echo the content of credential files.
- Never run `cat ~/.config/m2-secrets/*` (a hook blocks this anyway).
- Credentials missing? Set them up with `/m2-db-setup` (run it in your terminal with the `!` prefix — it is interactive).

## Project-Specific Config

Each M2 project `.env` defines `PROJECT_NAME`. The `/m2-exec` and `/m2-db` commands auto-detect it from
the nearest `.env` file when run from inside the project directory. Run `/m2-init` once per project to
generate a tailored `CLAUDE.md` (env vars, detected stack, custom `.maker_additional` targets).

## DC Variable

The full docker compose command is defined in each project's Makefile:
```make
DC=docker compose -p${PROJECT_NAME} -f .maker/docker-compose.yml $(EXTRA_FILE) --env-file=.env
```
Prefer `make <target>` or `/m2-exec` over constructing `DC` manually.
