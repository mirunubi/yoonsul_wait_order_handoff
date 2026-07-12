#!/usr/bin/env python3
"""Apply sql/migrations/*.sql in sequence-number order against the approved
Supabase cloud Postgres project, tracked via catchmenu_meta.migration_history.

Default mode is dry-run: no SQL is executed. Use --execute explicitly to run.

Connection method: this machine has no local `psql` binary on PATH. This
script instead runs `docker exec` against the already-running local Supabase
Docker container (supabase_db_yoonsul_wait_order_handoff), whose bundled
`psql` client reaches the cloud database over the network from inside that
container.

Why individual -h/-p/-U/-d flags instead of a single postgresql:// URL: an
earlier version of this script assembled a `postgresql://user:pass@host:port/db`
URL and passed it to `psql <url>`, which failed with "password authentication
failed" against the real cloud target for an unconfirmed reason (candidates:
URL-encoding of special characters in the password, or a placeholder that was
never substituted). Human confirmed that individual `-h -p -U -d` flags with
the password supplied separately connect successfully. Use that form; do not
reintroduce a single connection-string URL for the actual psql invocation.

Why a temporary .pgpass file inside the container instead of `-e
PGPASSWORD=...`: confirmed via a live test (`Get-CimInstance Win32_Process`
while a `docker exec -e PGPASSWORD=... psql ...` was running) that the
password appeared in PLAINTEXT in the host's process command line for every
process in the invocation chain (bash.exe, sh.exe, and docker.exe itself) for
as long as that process stayed alive -- visible to any other process on the
machine via WMI / Task Manager's "Command line" column. To avoid this, the
password is instead written into a temporary, 600-permission `.pgpass` file
inside the container (its content is sent over a stdin pipe, which does not
appear in any process's command line), and psql is pointed at it only via a
container-local file PATH (`PGPASSFILE=...`, not sensitive). The file is
deleted immediately after use, in a finally block that always runs.

Safety properties:
- Refuses any target whose connection identity does not resolve to the
  approved Supabase project ref (upzthfwhtvazfftxnyfu), via direct host or
  pooler host+username (see confirm_cloud_target()).
- Reads DATABASE_URL or --database-url; never hardcodes or prints passwords,
  and never passes the password as a command-line argument or environment
  variable that would be visible in a host process listing.
- Reuses the local migration checksum convention: CRLF is normalized to LF
  before SHA-256 hashing.
- Invokes psql only from this script (via docker exec into
  supabase_db_yoonsul_wait_order_handoff); do not paste migration SQL manually.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS_DIR = ROOT / "sql" / "migrations"

EXPECTED_PROJECT_REF = "upzthfwhtvazfftxnyfu"
EXPECTED_HOST = f"db.{EXPECTED_PROJECT_REF}.supabase.co"
EXPECTED_POOLER_USERNAME = f"postgres.{EXPECTED_PROJECT_REF}"
DEFAULT_DB_NAME = "postgres"
DEFAULT_PORT = 5432

# Local Supabase Docker container whose bundled psql client is reused to reach
# the cloud target, since this machine has no psql on PATH.
DOCKER_CONTAINER = "supabase_db_yoonsul_wait_order_handoff"

# Temporary, container-local credential file. Written fresh (mode 600) before
# each execute() run and removed immediately after, regardless of outcome.
PGPASS_CONTAINER_PATH = "/tmp/.apply_migrations_cloud_pgpass"

SEQ_PATTERN = re.compile(r"^(\d{4})_.+\.sql$")


@dataclass(frozen=True)
class CloudTarget:
    original_url: str
    password: str | None
    username: str
    host: str
    port: int
    database: str


def sequence_number(path: Path) -> str | None:
    m = SEQ_PATTERN.match(path.name)
    return m.group(1) if m else None


def is_seed_file(path: Path) -> bool:
    return "seed" in path.name.lower()


def discover_migrations() -> tuple[list[Path], list[Path]]:
    """Return (ordered sequence-numbered files, skipped non-conforming files)."""
    numbered: list[Path] = []
    skipped: list[Path] = []
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


def escape_sql_literal(value: str) -> str:
    return value.replace("'", "''")


def parse_cloud_target(database_url: str) -> CloudTarget:
    if not database_url:
        print(
            "REFUSED: no cloud database URL was provided. Set DATABASE_URL or pass "
            "--database-url. Expected host: "
            f"{EXPECTED_HOST}.",
            file=sys.stderr,
        )
        raise SystemExit(1)

    parsed = urlsplit(database_url)
    if parsed.scheme not in {"postgresql", "postgres"}:
        print(
            "REFUSED: DATABASE_URL must use postgresql:// or postgres://.",
            file=sys.stderr,
        )
        raise SystemExit(1)

    host = parsed.hostname or ""
    database = parsed.path.lstrip("/") or DEFAULT_DB_NAME
    password = parsed.password
    username = parsed.username or ""
    port = parsed.port or DEFAULT_PORT

    return CloudTarget(
        original_url=database_url,
        password=password,
        username=username,
        host=host,
        port=port,
        database=database,
    )


def confirm_cloud_target(target: CloudTarget) -> None:
    """Refuse to proceed unless the connection URL points at the approved
    Supabase cloud project ref.

    Direct connections prove the project ref through the host:
    db.upzthfwhtvazfftxnyfu.supabase.co.

    Supabase pooler connections prove the project ref through the username
    instead: postgres.upzthfwhtvazfftxnyfu. Pooler hosts are regional/shared
    (*.pooler.supabase.com), so host-only validation would reject the valid
    production connection path while also failing to prove project identity.

    The database name is still checked separately, but it is not sufficient
    proof of target identity because hosted Supabase projects commonly use a
    database literally named "postgres".
    """
    direct_target = target.host == EXPECTED_HOST
    pooler_target = (
        target.host.endswith(".pooler.supabase.com")
        and target.username == EXPECTED_POOLER_USERNAME
    )

    if not (direct_target or pooler_target):
        print(
            "REFUSED: cloud migrations may only target the approved Supabase "
            f"project ref '{EXPECTED_PROJECT_REF}'. Allowed target patterns are: "
            f"direct host '{EXPECTED_HOST}', or pooler host "
            f"'*.pooler.supabase.com' with username '{EXPECTED_POOLER_USERNAME}'. "
            f"Got host '{target.host or '(missing host)'}' and username "
            f"'{target.username or '(missing username)'}'. No SQL was executed.",
            file=sys.stderr,
        )
        raise SystemExit(1)

    if target.database != DEFAULT_DB_NAME:
        print(
            "REFUSED: expected database name 'postgres' for the approved Supabase "
            f"project, but got '{target.database}'. No SQL was executed.",
            file=sys.stderr,
        )
        raise SystemExit(1)


def pgpass_line(target: CloudTarget) -> str:
    """Build one `.pgpass` line: hostname:port:database:username:password.

    Per the pgpass file format, literal ':' and '\\' within a field must be
    backslash-escaped.
    """

    def escape(value: str) -> str:
        return value.replace("\\", "\\\\").replace(":", "\\:")

    return ":".join(
        [
            escape(target.host),
            escape(str(target.port)),
            escape(target.database),
            escape(target.username),
            escape(target.password or ""),
        ]
    )


def write_pgpass(target: CloudTarget) -> None:
    """Write a 600-permission .pgpass file inside the container.

    The credential line is sent over stdin (not a command-line argument or
    environment variable), so it never appears in this host's process
    listing. `umask 077` plus an explicit `chmod 600` afterward means the
    file is never briefly world/group-readable inside the container either.
    """
    line = pgpass_line(target)
    cmd = [
        "docker",
        "exec",
        "-i",
        DOCKER_CONTAINER,
        "sh",
        "-c",
        f"umask 077 && cat > {PGPASS_CONTAINER_PATH} && chmod 600 {PGPASS_CONTAINER_PATH}",
    ]
    proc = subprocess.run(cmd, input=(line + "\n").encode("utf-8"), capture_output=True)
    if proc.returncode != 0:
        output = proc.stdout.decode("utf-8", errors="replace") + proc.stderr.decode(
            "utf-8", errors="replace"
        )
        print(
            "REFUSED/FAILED: could not write the temporary .pgpass credential file "
            f"inside the {DOCKER_CONTAINER} container. No migration SQL was executed.\n"
            f"--- docker exec output ---\n{output.rstrip()}\n--------------------------",
            file=sys.stderr,
        )
        raise SystemExit(1)


def remove_pgpass() -> None:
    """Best-effort cleanup of the temporary .pgpass file. Always called from
    a finally block so it runs on both success and failure."""
    proc = subprocess.run(
        ["docker", "exec", DOCKER_CONTAINER, "rm", "-f", PGPASS_CONTAINER_PATH],
        capture_output=True,
    )
    if proc.returncode != 0:
        print(
            f"  ! Warning: could not remove temporary credential file "
            f"{PGPASS_CONTAINER_PATH} inside {DOCKER_CONTAINER}. Remove it manually.",
            file=sys.stderr,
        )


def build_psql_cmd(target: CloudTarget, args: list[str] | None = None) -> list[str]:
    cmd = [
        "docker",
        "exec",
        "-i",
        "-e",
        f"PGPASSFILE={PGPASS_CONTAINER_PATH}",
        DOCKER_CONTAINER,
        "psql",
        "-h",
        target.host,
        "-p",
        str(target.port),
        "-U",
        target.username,
        "-d",
        target.database,
        "-v",
        "ON_ERROR_STOP=1",
    ]
    if args:
        cmd.extend(args)
    return cmd


def run_psql(target: CloudTarget, sql: str, args: list[str] | None = None) -> tuple[bool, str]:
    """Run psql inside the Docker container via individual -h/-p/-U/-d flags.

    Requires write_pgpass(target) to have already been called; the password
    is supplied to psql only via PGPASSFILE (a container-local path, not a
    secret value), never as a command-line argument or PGPASSWORD env var.
    """
    cmd = build_psql_cmd(target, args)

    proc = subprocess.run(
        cmd,
        input=sql.encode("utf-8"),
        capture_output=True,
    )
    ok = proc.returncode == 0
    output = proc.stdout.decode("utf-8", errors="replace") + proc.stderr.decode(
        "utf-8", errors="replace"
    )
    return ok, output


def query_one(target: CloudTarget, sql: str) -> str:
    ok, output = run_psql(target, sql, ["-t", "-A"])
    if not ok:
        print(
            "REFUSED/FAILED: could not query the cloud migration target. "
            "No migration SQL was executed after this failure.\n"
            f"--- psql output ---\n{output.rstrip()}\n-------------------",
            file=sys.stderr,
        )
        raise SystemExit(1)
    return output.strip()


def history_table_exists(target: CloudTarget) -> bool:
    result = query_one(
        target,
        "SELECT to_regclass('catchmenu_meta.migration_history') IS NOT NULL;",
    )
    return result == "t"


def load_history(target: CloudTarget) -> dict[str, str]:
    """filename -> checksum, only for rows recorded as successfully applied."""
    if not history_table_exists(target):
        return {}
    result = query_one(
        target,
        "SELECT filename || '|' || checksum FROM catchmenu_meta.migration_history "
        "WHERE success = true ORDER BY filename;",
    )
    history: dict[str, str] = {}
    if result:
        for line in result.splitlines():
            if "|" in line:
                filename, chksum = line.split("|", 1)
                history[filename] = chksum
    return history


def record_result(
    target: CloudTarget,
    filename: str,
    chksum: str,
    success: bool,
    error_message: str | None,
) -> None:
    if not history_table_exists(target):
        print(
            f"  ! Could not record result for {filename}: "
            "catchmenu_meta.migration_history does not exist yet.",
            file=sys.stderr,
        )
        return

    err_sql = "NULL" if error_message is None else f"'{escape_sql_literal(error_message)}'"
    sql = (
        "INSERT INTO catchmenu_meta.migration_history "
        "(filename, checksum, success, error_message) VALUES ("
        f"'{escape_sql_literal(filename)}', '{chksum}', {str(success).lower()}, {err_sql}) "
        "ON CONFLICT (filename) DO UPDATE SET "
        "checksum = EXCLUDED.checksum, success = EXCLUDED.success, "
        "error_message = EXCLUDED.error_message, applied_at = now();"
    )
    ok, output = run_psql(target, sql)
    if not ok:
        print(
            f"  ! Could not record result for {filename} in migration_history: {output}",
            file=sys.stderr,
        )


def print_skipped(skipped: list[Path]) -> None:
    for path in skipped:
        if is_seed_file(path):
            print(
                f"SKIP  {path.name}  (does not match NNNN_name.sql sequence pattern; "
                "not part of tracked cloud order. Seed-like files are not auto-executed.)"
            )
        else:
            print(
                f"SKIP  {path.name}  (does not match NNNN_name.sql sequence pattern; "
                "not part of tracked cloud order)"
            )


def dry_run(numbered: list[Path], skipped: list[Path], target: CloudTarget) -> int:
    confirm_cloud_target(target)
    print("DRY-RUN ONLY: no SQL will be executed.")
    print(f"Confirmed URL host is approved project: {EXPECTED_PROJECT_REF}")
    print(f"Target host: {target.host}")
    print(f"Target database: {target.database}")
    print()
    print_skipped(skipped)
    print()
    print("Planned sequence-numbered migration order:")
    for path in numbered:
        print(f"PLAN  {path.name}  checksum={checksum(path)}")
    print()
    print(
        "Dry-run complete. To execute, rerun with --execute and the same approved "
        "DATABASE_URL/--database-url target."
    )
    return 0


def check_connection(target: CloudTarget) -> int:
    confirm_cloud_target(target)
    print("CHECK-CONNECTION mode: no migration files will be discovered or executed.")
    print("Sanitized target:")
    print(f"  host: {target.host}")
    print(f"  port: {target.port}")
    print(f"  username: {target.username}")
    print(f"  database: {target.database}")
    cmd = build_psql_cmd(target)
    print(f"Sanitized psql cmd: {cmd}")

    write_pgpass(target)
    try:
        ok, output = run_psql(target, "SELECT current_user, current_database();")
        print("--- psql output ---")
        print(output.rstrip())
        print("-------------------")
        if not ok:
            return 1
        return 0
    finally:
        remove_pgpass()


def execute(numbered: list[Path], skipped: list[Path], target: CloudTarget) -> int:
    confirm_cloud_target(target)
    print(f"EXECUTE mode confirmed for approved project ref: {EXPECTED_PROJECT_REF}")
    print(f"Target host: {target.host}")
    print(f"Target database: {target.database}")
    print("Passwords and full connection strings are intentionally not printed.")
    print()
    print_skipped(skipped)

    if not numbered or sequence_number(numbered[0]) != "0000":
        print(
            "REFUSED: migration sequence must start at 0000 because the cloud "
            "target may not yet have catchmenu_meta.migration_history. "
            "Ensure sql/migrations/0000_*.sql exists and sorts first.",
            file=sys.stderr,
        )
        return 1

    write_pgpass(target)
    try:
        if not history_table_exists(target):
            print(
                "catchmenu_meta.migration_history does not exist yet. "
                "This is expected for a fresh cloud target; 0000 will be applied first."
            )

        history = load_history(target)

        for path in numbered:
            filename = path.name
            current_checksum = checksum(path)

            if filename in history:
                recorded_checksum = history[filename]
                if recorded_checksum == current_checksum:
                    # A matching checksum does not mean the SQL was re-executed.
                    # If someone manually edits cloud migration_history checksums
                    # while the live function/body was changed through different
                    # SQL, this branch will silently skip the file. Do not hand-edit
                    # cloud checksums; see the 2026-07-11 local incident.
                    print(f"OK    {filename}  (already applied, checksum matches)")
                    continue

                print(f"FAIL  {filename}")
                print("      CHECKSUM MISMATCH: this file was edited after being applied.")
                print(f"      recorded:  {recorded_checksum}")
                print(f"      current:   {current_checksum}")
                print("      Stopping. Investigate before re-running.")
                return 1

            print(f"APPLY {filename} ...")
            sql_text = path.read_text(encoding="utf-8")
            ok, output = run_psql(target, sql_text)

            if ok:
                record_result(target, filename, current_checksum, True, None)
                print(f"OK    {filename}  (applied)")
                continue

            error_message = output.strip()[:4000]
            record_result(target, filename, current_checksum, False, error_message)
            print(f"FAIL  {filename}")
            print("      --- psql output ---")
            print(output.rstrip())
            print("      -------------------")
            print("      Stopping at first failure. No further migrations were attempted.")
            return 1

        print("All sequence-numbered cloud migrations applied or already up to date.")
        return 0
    finally:
        remove_pgpass()


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Apply CatchMenu SQL migrations to the approved Supabase cloud "
            "project. Defaults to dry-run."
        )
    )
    parser.add_argument(
        "--database-url",
        default=os.environ.get("DATABASE_URL", ""),
        help=(
            "Cloud Postgres URL. Defaults to DATABASE_URL. Expected host: "
            f"{EXPECTED_HOST}. Do not paste this into logs."
        ),
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned migration order only. This is the default.",
    )
    mode.add_argument(
        "--execute",
        action="store_true",
        help="Actually execute migrations against the approved cloud target.",
    )
    mode.add_argument(
        "--check-connection",
        action="store_true",
        help=(
            "Validate the approved cloud target and run only "
            "'SELECT current_user, current_database();'. No migration files are "
            "discovered or executed."
        ),
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    target = parse_cloud_target(args.database_url)
    if args.check_connection:
        return check_connection(target)

    numbered, skipped = discover_migrations()

    if args.execute:
        return execute(numbered, skipped, target)
    return dry_run(numbered, skipped, target)


if __name__ == "__main__":
    raise SystemExit(main())
