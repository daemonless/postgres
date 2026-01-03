# PostgreSQL

PostgreSQL database server on FreeBSD.

> **Requires [patched ocijail](https://github.com/daemonless/daemonless#ocijail-patch)** for SysV IPC support (`org.freebsd.jail.allow.sysvipc=true`)

## Quick Start

```bash
podman run -d --name postgres \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v /path/to/data:/var/db/postgres \
  --annotation 'org.freebsd.jail.allow.sysvipc=true' \
  ghcr.io/daemonless/postgres:17
```

## podman-compose

```yaml
services:
  postgres:
    image: ghcr.io/daemonless/postgres:17
    container_name: postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=mysecretpassword
      - POSTGRES_DB=mydb
    volumes:
      - /data/postgres:/var/db/postgres
    ports:
      - 5432:5432
    annotations:
      org.freebsd.jail.allow.sysvipc: "true"
    restart: unless-stopped
```

## Tags

| Tag | Description |
|-----|-------------|
| `:17` | PostgreSQL 17 (latest) |
| `:14` | PostgreSQL 14 |
| `:latest` | Alias for `:17` |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | `postgres` | Database superuser name |
| `POSTGRES_PASSWORD` | (empty) | Superuser password |
| `POSTGRES_DB` | `postgres` | Default database name |
| `PGDATA` | `/var/db/postgres/dataXX` | Data directory (XX = version) |
| `POSTGRES_INITDB_ARGS` | (empty) | Extra args for initdb (e.g., `--data-checksums`) |
| `POSTGRES_HOST_AUTH_METHOD` | `scram-sha-256` | Auth method (`scram-sha-256`, `md5`, `trust`) |

### Docker Secrets

Secrets can be passed via `*_FILE` environment variables:

| Variable | Description |
|----------|-------------|
| `POSTGRES_PASSWORD_FILE` | Path to file containing password |

## Initialization Scripts

Place scripts in `/docker-entrypoint-initdb.d/` to run on first startup:

| Extension | Behavior |
|-----------|----------|
| `*.sh` | Executed if executable, sourced otherwise |
| `*.sql` | Run via psql against `$POSTGRES_DB` |
| `*.sql.gz` | Decompressed and run via psql |

Scripts run in sorted filename order after database creation.

## Volumes

| Path | Description |
|------|-------------|
| `/var/db/postgres` | PostgreSQL data directory |

## Ports

| Port | Description |
|------|-------------|
| 5432 | PostgreSQL |

## Notes

- **User:** `bsd` (UID/GID 1000)

## Links

- [PostgreSQL Website](https://www.postgresql.org/)
- [FreshPorts postgresql17-server](https://www.freshports.org/databases/postgresql17-server/)
- [FreshPorts postgresql14-server](https://www.freshports.org/databases/postgresql14-server/)
