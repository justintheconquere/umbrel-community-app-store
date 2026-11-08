# Twenty migration runbook — Arcane → sparkles-twenty

Move Twenty CRM from the Arcane Compose project (`twenty`, running inside
Arcane's Docker-in-Docker on ufo) to the `sparkles-twenty` Umbrel app in
this store, with the Arcane copy kept as rollback.

> **Hard rule: only ONE Twenty may run at a time.** Both use port 3000 and
> the same `SERVER_URL` (http://100.122.244.66:3000). Stop one before
> starting the other, every time.

> **Paths marked VERIFY-ON-BOX are placeholders.** Arcane runs
> Docker-in-Docker, so its named volumes live inside Arcane's own data
> directory on the host. Confirm the real volume names/paths on ufo
> before running anything:
>
> ```
> # expected shape (VERIFY-ON-BOX):
> /Apps/arcane/data/docker/volumes/twenty_db-data/_data
> /Apps/arcane/data/docker/volumes/twenty_server-local-data/_data
> ls /Apps/arcane/data/docker/volumes/ | grep twenty
> ```

## 1. Stop the Arcane Twenty project

In Arcane (http://ufo.local:3552), open the `twenty` project and stop it
(the **Stop** button). Leave the project and its volumes in place — that
stopped copy is the rollback.

## 2. Dump the database from the Arcane db container

Arcane's DinD containers are not visible to the host Docker, so run the
dump through Arcane's own Docker socket. VERIFY-ON-BOX: container names
below follow Arcane's Compose naming (`twenty-db-1`); check with
`docker ps` against the DinD socket first.

```
export DOCKER_HOST=unix:///Apps/arcane/data/docker/docker.sock

# confirm the container names (VERIFY-ON-BOX)
docker ps -a --format '{{.Names}}' | grep twenty

# dump (writes to the current directory on the host)
docker exec twenty-db-1 pg_dump -U twenty -d default -Fc > twenty-backup.dump
```

## 3. Copy the server local-storage data

```
# VERIFY-ON-BOX: source path is the Arcane server-local-data volume
sudo cp -a /Apps/arcane/data/docker/volumes/twenty_server-local-data/_data/. \
  /tmp/twenty-local-storage/
```

## 4. Install sparkles-twenty from the store

In umbrelOS, open the Sparkles store and install **Twenty CRM**
(`sparkles-twenty`). On first install, `exports.sh` generates the app
secret and database password and persists them in the app's exports env
file. Let it start once so the app data directories exist, then stop the
app in umbrelOS before restoring (step 5) so the restore is not racing a
running server.

## 5. Restore data into sparkles-twenty

Umbrel app data lives under the Umbrel app-data directory
(VERIFY-ON-BOX, typically `/Apps/sparkles-twenty/data/...` — Umbrel app
ids are used as folder names).

```
# 5a. local storage files
sudo cp -a /tmp/twenty-local-storage/. \
  /Apps/sparkles-twenty/data/server-local-data/

# 5b. database: start ONLY the new db container, restore, then stop it
# (container name follows the Umbrel form: sparkles-twenty_db_1)
docker start sparkles-twenty_db_1
cat twenty-backup.dump | docker exec -i sparkles-twenty_db_1 \
  pg_restore -U twenty -d default --clean --if-exists
docker stop sparkles-twenty_db_1
```

Alternative for 5b: start the full app once, let Twenty run its own
migrations against the empty database, then restore the dump into the
running `sparkles-twenty_db_1` with the same `pg_restore` command and
restart the app.

## 6. Start and verify

Start `sparkles-twenty` in umbrelOS, then check:

```
curl --fail http://100.122.244.66:3000/healthz
```

- Open http://100.122.244.66:3000 and sign in (Tailscale must be
  connected — this address is tailnet-only by design).
- The first account to sign up on a fresh Twenty becomes the workspace
  admin. With a restored database, your existing admin/workspace should
  come across with the dump — confirm the workspace, users and records
  are present before declaring the migration done.
- Check the worker is processing (app logs in umbrelOS).

## 7. Rollback window — 7 days

Keep the Arcane `twenty` project **stopped but intact** for 7 days after
a verified migration. If anything is wrong, rollback is: stop
`sparkles-twenty` in umbrelOS, start the `twenty` project in Arcane.
Never run both at once.

After 7 clean days, delete the `twenty` project in Arcane (project +
its named volumes) to retire it.
