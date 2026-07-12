"""Compare sql/migrations/*.sql on-disk checksums against catchmenu_meta.migration_history.

Created 2026-07-11 (checksum-vs-live-execution incident response session) after discovering
that apply_migrations.py normalizes CRLF to LF (`file_bytes.replace(b"\\r\\n", b"\\n")`) before
hashing. The earlier check_checksums.py (deleted) did not apply this normalization and could
report false mismatches for CRLF-saved files. Use this _lf version, not a non-LF variant, or
the reported mismatch/match counts will not agree with what apply_migrations.py actually sees.

Requires: local Supabase Docker container `supabase_db_yoonsul_wait_order_handoff` running.
Run from repo root (relies on relative path `sql/migrations/`).
"""
import subprocess, hashlib, os

result = subprocess.run(
    ["docker", "exec", "supabase_db_yoonsul_wait_order_handoff", "psql",
     "-U", "postgres", "-d", "postgres", "-t", "-A", "-c",
     "SELECT filename || '\''|'\'' || checksum FROM catchmenu_meta.migration_history WHERE success = true ORDER BY filename;"],
    capture_output=True, text=True
)
recorded = {}
for line in result.stdout.strip().split("\n"):
    if "|" in line:
        fn, ck = line.split("|")
        recorded[fn.strip()] = ck.strip()

mismatch, match = [], []
for fn, ck in recorded.items():
    path = os.path.join("sql", "migrations", fn)
    if not os.path.exists(path):
        continue
    with open(path, "rb") as f:
        raw = f.read().replace(b"\r\n", b"\n")
    current = hashlib.sha256(raw).hexdigest()
    (match if current == ck else mismatch).append(fn)

print(f"일치(LF 정규화 기준): {len(match)}개")
print(f"불일치: {len(mismatch)}개")
for m in mismatch:
    print(" -", m)
