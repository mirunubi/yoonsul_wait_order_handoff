#!/usr/bin/env python3
"""Mechanical scan: encoding damage, template clone patterns, mtime surges in docs/."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"


def scan_replacement_char() -> list[dict]:
    results = []
    for p in sorted(DOCS.rglob("*.md")):
        try:
            text = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        count = text.count("\ufffd")
        if count:
            results.append({"path": str(p.relative_to(ROOT)).replace("\\", "/"), "count": count})
    return results


def scan_utf8_strict_failures() -> list[dict]:
    failures = []
    for p in sorted(DOCS.rglob("*")):
        if not p.is_file():
            continue
        if p.suffix.lower() not in {".md", ".sql", ".txt", ".json", ".yaml", ".yml"}:
            continue
        raw = p.read_bytes()
        try:
            raw.decode("utf-8")
        except UnicodeDecodeError as e:
            failures.append(
                {
                    "path": str(p.relative_to(ROOT)).replace("\\", "/"),
                    "error": str(e),
                    "byte_offset": e.start,
                }
            )
    return failures


def scan_template_clone_patterns() -> list[dict]:
    """Folders with >=5 md files, >=80% within ±5% of median size, sequential numeric prefixes."""
    folder_files: dict[Path, list[Path]] = defaultdict(list)
    for p in DOCS.rglob("*.md"):
        folder_files[p.parent].append(p)

    suspects = []
    prefix_re = re.compile(r"^(\d{5,6})_")

    for folder, files in sorted(folder_files.items(), key=lambda x: str(x[0])):
        if len(files) < 5:
            continue
        sizes = [(f, f.stat().st_size) for f in files]
        size_vals = [s for _, s in sizes]
        median = sorted(size_vals)[len(size_vals) // 2]
        if median == 0:
            continue
        within = sum(1 for s in size_vals if abs(s - median) / median <= 0.05)
        ratio = within / len(size_vals)
        if ratio < 0.8:
            continue

        prefixed = []
        for f in files:
            m = prefix_re.match(f.name)
            if m:
                prefixed.append((int(m.group(1)), f.name, f.stat().st_size))
        if len(prefixed) < 5:
            continue
        prefixed.sort(key=lambda x: x[0])
        nums = [x[0] for x in prefixed]
        max_gap = max(nums[i + 1] - nums[i] for i in range(len(nums) - 1)) if len(nums) > 1 else 0
        sequential_runs = 1
        for i in range(len(nums) - 1):
            if nums[i + 1] - nums[i] <= 10:
                sequential_runs += 1
            else:
                break

        suspects.append(
            {
                "folder": str(folder.relative_to(ROOT)).replace("\\", "/"),
                "file_count": len(files),
                "median_bytes": median,
                "within_5pct_count": within,
                "within_5pct_ratio": round(ratio, 3),
                "prefixed_count": len(prefixed),
                "prefix_range": f"{nums[0]}-{nums[-1]}" if nums else "",
                "max_numeric_gap": max_gap,
                "initial_sequential_streak": sequential_runs,
                "sample_files": [x[1] for x in prefixed[:5]],
                "size_min": min(size_vals),
                "size_max": max(size_vals),
            }
        )
    return suspects


def scan_mtime_surges() -> dict:
    mtimes: list[tuple[float, str]] = []
    for p in DOCS.rglob("*.md"):
        try:
            mtimes.append((p.stat().st_mtime, str(p.relative_to(ROOT)).replace("\\", "/")))
        except OSError:
            pass

    by_hour: Counter[str] = Counter()
    by_day: Counter[str] = Counter()
    for ts, _ in mtimes:
        dt = datetime.fromtimestamp(ts)
        by_hour[dt.strftime("%Y-%m-%d %H:00")] += 1
        by_day[dt.strftime("%Y-%m-%d")] += 1

    top_hours = by_hour.most_common(20)
    top_days = by_day.most_common(20)
    median_hour = sorted(by_hour.values())[len(by_hour) // 2] if by_hour else 0

    surge_hours = [(h, c) for h, c in top_hours if c >= max(50, median_hour * 3)]

    return {
        "total_md_files": len(mtimes),
        "distinct_hours": len(by_hour),
        "distinct_days": len(by_day),
        "median_files_per_hour": median_hour,
        "top_20_hours": top_hours,
        "top_20_days": top_days,
        "surge_hours_threshold": f"max(50, median*3)={max(50, median_hour * 3)}",
        "surge_hours": surge_hours,
    }


def main() -> int:
    out = {
        "scan_root": str(DOCS),
        "scanned_at_utc": datetime.now(timezone.utc).isoformat(),
        "replacement_char": scan_replacement_char(),
        "utf8_strict_failures": scan_utf8_strict_failures(),
        "template_clone_suspects": scan_template_clone_patterns(),
        "mtime_surges": scan_mtime_surges(),
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
