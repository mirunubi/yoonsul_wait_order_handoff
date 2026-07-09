#!/usr/bin/env python3
"""Apply sql/migrations/*.sql in sequence-number order against the local
Supabase Postgres instance, tracked via catchmenu_meta.migration_history.

Idempotent: files already recorded in migration_history are checksum-verified
and skipped; files not yet recorded are applied and recorded. Stops at the
first failure (SQL error) or the first checksum mismatch (a previously
applied file was edited afterward) without touching anything past that point.
"""
from __future__ import annotations

import hashlib
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS_DIR = ROOT / "sql" / "migrations"
DB_CONTAINER = "supabase_db_yoonsul_wait_order_handoff"
DB_USER = "postgres"
DB_NAME = "postgres"

# The only local dev target this script is willing to run seed files against.
# Seed files must NOT rely on a DB-name check (Supabase local and hosted
# projects both default to a database literally named "postgres" -- see
# 0034_seed_data.sql history), so the guard lives here instead, checked
# against the actual running container rather than just a string constant.
EXPECTED_LOCAL_CONTAINER = "supabase_db_yoonsul_wait_order_handoff"
EXPECTED_LOCAL_CLI_PROJECT_LABEL = "yoonsul_wait_order_handoff"

SEQ_PATTERN = re.compile(r"^(\d{4})_.+\.sql$")


def sequence_number(path: Path) -> str | None:
    m = SEQ_PATTERN.match(path.name)
    return m.group(1) if m else None


def is_seed_file(path: Path) -> bool:
    return "seed" in path.name.lower()


def confirm_local_target() -> None:
    """Refuse to proceed unless DB_CONTAINER is exactly the known local dev
    container, and that container is actually running with the label the
    Supabase CLI attaches to locally-managed stacks. Called once before any
    seed file executes."""
    if DB_CONTAINER != EXPECTED_LOCAL_CONTAINER:
        print(
            f"REFUSED: seed files only run through this script against the known "
            f"local container '{EXPECTED_LOCAL_CONTAINER}', but DB_CONTAINER is "
            f"currently set to '{DB_CONTAINER}'.",
            file=sys.stderr,
        )
        raise SystemExit(1)

    proc = subprocess.run(
        [
            "docker", "inspect", DB_CONTAINER,
            "--format", "{{ index .Config.Labels \"com.supabase.cli.project\" }}",
        ],
        capture_output=True,
    )
    if proc.returncode != 0:
        print(
            f"REFUSED: seed files only run through this script against the known local "
            f"container '{EXPECTED_LOCAL_CONTAINER}', but that container could not be "
            f"found/inspected (is it running? `supabase start`?).\n"
            f"docker inspect error: {proc.stderr.decode('utf-8', errors='replace').strip()}",
            file=sys.stderr,
        )
        raise SystemExit(1)

    label = proc.stdout.decode("utf-8", errors="replace").strip()
    if label != EXPECTED_LOCAL_CLI_PROJECT_LABEL:
        print(
            f"REFUSED: container '{EXPECTED_LOCAL_CONTAINER}' exists but its "
            f"com.supabase.cli.project label is '{label}', not the expected "
            f"'{EXPECTED_LOCAL_CLI_PROJECT_LABEL}'. Refusing to run seed files against "
            f"a container that doesn't look like the known local dev stack.",
            file=sys.stderr,
        )
        raise SystemExit(1)


def discover_migrations() -> tuple[list[Path], list[Path]]:
    """Return (ordered sequence-numbered files, skipped non-conforming files)."""
    numbered = []
    skipped = []
    for path in MIGRATIONS_DIR.glob("*.sql"):
        if sequence_number(path) is not None:
            numbered.append(path)
        else:
            skipped.append(path)
    numbered.sort(key=lambda p: sequence_number(p))
    return numbered, skipped


def checksum(path: Path) -> str:
    raw = path.read_bytes().replace(b"\r\n", b"\n")
    return hashlib.sha256(raw).hexdigest()


def run_psql(sql: str) -> tuple[bool, str]:
    proc = subprocess.run(
        [
            "docker", "exec", "-i", DB_CONTAINER,
            "psql", "-U", DB_USER, "-d", DB_NAME,
            "-v", "ON_ERROR_STOP=1",
        ],
        input=sql.encode("utf-8"),
        capture_output=True,
    )
    ok = proc.returncode == 0
    output = proc.stdout.decode("utf-8", errors="replace") + proc.stderr.decode("utf-8", errors="replace")
    return ok, output


def query_one(sql: str) -> str:
    proc = subprocess.run(
        [
            "docker", "exec", "-i", DB_CONTAINER,
            "psql", "-U", DB_USER, "-d", DB_NAME,
            "-t", "-A", "-c", sql,
        ],
        capture_output=True,
    )
    return proc.stdout.decode("utf-8", errors="replace").strip()


def history_table_exists() -> bool:
    result = query_one(
        "SELECT to_regclass('catchmenu_meta.migration_history') IS NOT NULL;"
    )
    return result == "t"


def load_history() -> dict[str, str]:
    """filename -> checksum, only for rows recorded as successfully applied."""
    if not history_table_exists():
        return {}
    result = query_one(
        "SELECT filename || '|' || checksum FROM catchmenu_meta.migration_history "
        "WHERE success = true ORDER BY filename;"
    )
    history = {}
    if result:
        for line in result.splitlines():
            if "|" in line:
                filename, chksum = line.split("|", 1)
                history[filename] = chksum
    return history


def escape_sql_literal(value: str) -> str:
    return value.replace("'", "''")


def record_result(filename: str, chksum: str, success: bool, error_message: str | None) -> None:
    err_sql = "NULL" if error_message is None else f"'{escape_sql_literal(error_message)}'"
    sql = (
        "INSERT INTO catchmenu_meta.migration_history "
        "(filename, checksum, success, error_message) VALUES ("
        f"'{escape_sql_literal(filename)}', '{chksum}', {str(success).lower()}, {err_sql}) "
        "ON CONFLICT (filename) DO UPDATE SET "
        "checksum = EXCLUDED.checksum, success = EXCLUDED.success, "
        "error_message = EXCLUDED.error_message, applied_at = now();"
    )
    ok, output = run_psql(sql)
    if not ok:
        print(f"  ! Could not record result for {filename} in migration_history: {output}", file=sys.stderr)


def main() -> int:
    numbered, skipped = discover_migrations()

    for path in skipped:
        if is_seed_file(path):
            confirm_local_target()
            print(
                f"SKIP  {path.name}  (does not match NNNN_name.sql sequence pattern; "
                f"not part of tracked order. Local-target check passed -- this file is "
                f"not auto-executed by this script, but is protected the same way if it "
                f"ever is.)"
            )
        else:
            print(f"SKIP  {path.name}  (does not match NNNN_name.sql sequence pattern; not part of tracked order)")

    if not history_table_exists():
        print(
            "catchmenu_meta.migration_history does not exist yet. "
            "Run 0000_create_migration_history_table.sql first (this script will apply it "
            "like any other numbered migration since it is named 0000_...).",
        )

    history = load_history()

    for path in numbered:
        filename = path.name
        current_checksum = checksum(path)

        if filename in history:
            recorded_checksum = history[filename]
            if recorded_checksum == current_checksum:
                print(f"OK    {filename}  (already applied, checksum matches)")
                continue
            else:
                print(f"FAIL  {filename}")
                print(f"      CHECKSUM MISMATCH: this file was edited after being applied.")
                print(f"      recorded:  {recorded_checksum}")
                print(f"      current:   {current_checksum}")
                print("      Stopping. Investigate before re-running.")
                return 1

        if is_seed_file(path):
            confirm_local_target()

        print(f"APPLY {filename} ...")
        sql_text = path.read_text(encoding="utf-8")
        ok, output = run_psql(sql_text)

        if ok:
            record_result(filename, current_checksum, True, None)
            print(f"OK    {filename}  (applied)")
        else:
            error_message = output.strip()[:4000]
            record_result(filename, current_checksum, False, error_message)
            print(f"FAIL  {filename}")
            print("      --- psql output ---")
            print(output.rstrip())
            print("      -------------------")
            print("      Stopping at first failure. No further migrations were attempted.")
            return 1

    print("All sequence-numbered migrations applied or already up to date.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
