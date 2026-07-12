"""Generate UPDATE statements to re-sync catchmenu_meta.migration_history.checksum
with the current on-disk sql/migrations/*.sql files (CRLF-normalized).

Created 2026-07-11 (checksum-vs-live-execution incident response session). The earlier
gen_checksum_sync.py (deleted) computed checksums without CRLF normalization, which does
not match how apply_migrations.py hashes files and would have written wrong checksum
values into migration_history. Use this _lf version only.

CAUTION: updating the checksum column does NOT re-apply/re-execute the migration's SQL —
apply_migrations.py only compares checksums and skips files that already match. If a
migration file's actual SQL body changed, you must re-execute it directly against the
database (e.g. via `docker exec -i ... psql ... < <file>.sql`) in addition to (or instead
of) running the generated UPDATE statements.

Requires: local Supabase Docker container `supabase_db_yoonsul_wait_order_handoff` running.
Run from repo root (writes `sync_checksums_lf.sql` to the current working directory, which
is gitignored as an ephemeral/regeneratable output — see root .gitignore).
"""
import subprocess, hashlib, os

result = subprocess.run(
    ["docker", "exec", "supabase_db_yoonsul_wait_order_handoff", "psql",
     "-U", "postgres", "-d", "postgres", "-t", "-A", "-c",
     "SELECT filename FROM catchmenu_meta.migration_history WHERE success = true ORDER BY filename;"],
    capture_output=True, text=True
)
filenames = [l.strip() for l in result.stdout.strip().split("\n") if l.strip()]

updates = []
for fn in filenames:
    path = os.path.join("sql", "migrations", fn)
    if not os.path.exists(path):
        continue
    with open(path, "rb") as f:
        raw = f.read().replace(b"\r\n", b"\n")  # apply_migrations.py와 동일한 정규화
    ck = hashlib.sha256(raw).hexdigest()
    updates.append((fn, ck))

sql_statements = []
for fn, ck in updates:
    sql_statements.append(
        f"UPDATE catchmenu_meta.migration_history SET checksum = '{ck}' WHERE filename = '{fn}';"
    )

with open("sync_checksums_lf.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_statements))

print(f"{len(updates)}개 UPDATE 문을 sync_checksums_lf.sql에 생성했습니다 (LF 정규화 기준).")
