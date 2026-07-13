"""Pull-based secondary cloud backup helper for CatchMenu.

Default mode is dry-run. Use --execute only when a human explicitly approves
creating a real cloud dump through Supabase CLI.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

try:
    from .cloud_target_config import EXPECTED_PROJECT_REF
except ImportError:
    from cloud_target_config import EXPECTED_PROJECT_REF


BACKUP_DIR = Path("E:/catchmenu_backups")
BACKUP_LOG = BACKUP_DIR / "backup_log.txt"
LINKED_PROJECT_REF_FILE = Path("supabase/.temp/project-ref")
RETENTION_DAYS = 30


def now_local() -> datetime:
    return datetime.now().astimezone()


def ensure_backup_dir() -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)


def read_linked_project_ref() -> str:
    if not LINKED_PROJECT_REF_FILE.exists():
        raise RuntimeError(
            f"REFUSED: linked project ref file not found: {LINKED_PROJECT_REF_FILE}"
        )
    return LINKED_PROJECT_REF_FILE.read_text(encoding="utf-8").lstrip("\ufeff").strip()


def confirm_linked_project_ref() -> str:
    actual_ref = read_linked_project_ref()
    if actual_ref != EXPECTED_PROJECT_REF:
        raise RuntimeError(
            "REFUSED: linked Supabase project ref mismatch. "
            f"expected={EXPECTED_PROJECT_REF!r}, actual={actual_ref!r}. "
            "Run aborted before any cloud dump command."
        )
    return actual_ref


def backup_filename(timestamp: datetime | None = None) -> Path:
    ts = timestamp or now_local()
    return BACKUP_DIR / f"cloud_backup_{ts.strftime('%Y%m%d_%H%M%S')}.sql"


def free_space_text() -> str:
    usage = shutil.disk_usage(BACKUP_DIR)
    free_gb = usage.free / (1024**3)
    total_gb = usage.total / (1024**3)
    return f"{free_gb:.2f} GiB free / {total_gb:.2f} GiB total"


def append_log(
    *,
    status: str,
    mode: str,
    output_file: Path | None = None,
    file_size: int | None = None,
    message: str = "",
) -> None:
    ensure_backup_dir()
    timestamp = now_local().isoformat(timespec="seconds")
    size_text = "-" if file_size is None else str(file_size)
    file_text = "-" if output_file is None else str(output_file)
    line = (
        f"{timestamp}\tstatus={status}\tmode={mode}\tfile={file_text}"
        f"\tsize_bytes={size_text}\tfree_space={free_space_text()}\tmessage={message}\n"
    )
    with BACKUP_LOG.open("a", encoding="utf-8", newline="\n") as fh:
        fh.write(line)


def prune_old_backups(*, retention_days: int = RETENTION_DAYS, dry_run: bool) -> list[Path]:
    ensure_backup_dir()
    cutoff = now_local() - timedelta(days=retention_days)
    candidates = sorted(BACKUP_DIR.glob("cloud_backup_*.sql"))
    stale_files = [
        path
        for path in candidates
        if datetime.fromtimestamp(path.stat().st_mtime).astimezone() < cutoff
    ]
    if not dry_run:
        for path in stale_files:
            path.unlink()
    return stale_files


def run_supabase_dump(output_file: Path) -> subprocess.CompletedProcess[str]:
    cmd = ["supabase", "db", "dump", "--linked", "-f", str(output_file)]
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def run_dry_run() -> int:
    ensure_backup_dir()
    try:
        actual_ref = confirm_linked_project_ref()
        output_file = backup_filename()
        stale_files = prune_old_backups(dry_run=True)
        print("DRY_RUN: cloud secondary backup")
        print(f"linked_project_ref={actual_ref}")
        print(f"expected_project_ref={EXPECTED_PROJECT_REF}")
        print(f"backup_dir={BACKUP_DIR}")
        print(f"planned_output_file={output_file}")
        print("planned_command=supabase db dump --linked -f <planned_output_file>")
        print(
            "retention_preview="
            + (
                "none"
                if not stale_files
                else ", ".join(path.name for path in stale_files)
            )
        )
        print(f"free_space={free_space_text()}")
        append_log(
            status="OK",
            mode="DRY_RUN",
            output_file=output_file,
            message=f"dry-run only; stale_preview_count={len(stale_files)}",
        )
        return 0
    except Exception as exc:
        message = str(exc)
        print(message, file=sys.stderr)
        try:
            append_log(status="REFUSED", mode="DRY_RUN", message=message)
        except Exception as log_exc:
            print(f"LOG_WRITE_FAILED: {log_exc}", file=sys.stderr)
        return 1


def run_execute() -> int:
    ensure_backup_dir()
    output_file = backup_filename()
    try:
        actual_ref = confirm_linked_project_ref()
        print("EXECUTE: cloud secondary backup")
        print(f"linked_project_ref={actual_ref}")
        print(f"expected_project_ref={EXPECTED_PROJECT_REF}")
        print(f"backup_dir={BACKUP_DIR}")
        print(f"output_file={output_file}")
        result = run_supabase_dump(output_file)
        if result.stdout:
            print(result.stdout, end="")
        if result.stderr:
            print(result.stderr, file=sys.stderr, end="")
        if result.returncode != 0:
            append_log(
                status="FAILED",
                mode="EXECUTE",
                output_file=output_file,
                message=f"supabase db dump failed with exit_code={result.returncode}",
            )
            return result.returncode
        file_size = output_file.stat().st_size if output_file.exists() else None
        deleted_files = prune_old_backups(dry_run=False)
        append_log(
            status="OK",
            mode="EXECUTE",
            output_file=output_file,
            file_size=file_size,
            message=f"deleted_stale_count={len(deleted_files)}",
        )
        print(f"backup_file_size_bytes={file_size}")
        print(
            "deleted_stale_files="
            + (
                "none"
                if not deleted_files
                else ", ".join(path.name for path in deleted_files)
            )
        )
        print(f"free_space={free_space_text()}")
        return 0
    except Exception as exc:
        message = str(exc)
        print(message, file=sys.stderr)
        try:
            append_log(
                status="REFUSED_OR_FAILED",
                mode="EXECUTE",
                output_file=output_file,
                message=message,
            )
        except Exception as log_exc:
            print(f"LOG_WRITE_FAILED: {log_exc}", file=sys.stderr)
        return 1


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Pull cloud backup into E:/catchmenu_backups. Defaults to dry-run."
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview safety checks, planned dump path, and retention candidates.",
    )
    mode.add_argument(
        "--execute",
        action="store_true",
        help="Actually run supabase db dump --linked and prune backups older than 30 days.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    if args.execute:
        return run_execute()
    return run_dry_run()


if __name__ == "__main__":
    raise SystemExit(main())
