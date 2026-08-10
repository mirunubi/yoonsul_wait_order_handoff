import json
from pathlib import Path

p = Path(r"d:/workspace/yoonsul_wait_order_handoff/tools/_scan_encoding_result.json")
d = json.loads(p.read_text(encoding="utf-8-sig"))
print("template_suspects", len(d["template_clone_suspects"]))
for s in d["template_clone_suspects"]:
    print(
        s["folder"],
        "| n=", s["file_count"],
        "median=", s["median_bytes"],
        "within5pct=", s["within_5pct_ratio"],
        "prefix=", s["prefix_range"],
        "streak=", s["initial_sequential_streak"],
        "size=", s["size_min"], "-", s["size_max"],
        sep="",
    )
folder = Path(r"d:/workspace/yoonsul_wait_order_handoff/docs/700000_runtime_flow_bundle")
files = sorted(folder.glob("7001*.md"))
sizes = [f.stat().st_size for f in files]
print("7001xx count", len(files), "min", min(sizes), "max", max(sizes), "median", sorted(sizes)[len(sizes) // 2])
