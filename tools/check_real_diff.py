"""Compare working-tree sql/migrations/*.sql files against the git HEAD blob, ignoring CRLF/LF noise.

Created 2026-07-11 (checksum-vs-live-execution incident response session) to distinguish
"line-ending only" diffs from genuine content edits when auditing applied migration files
before/after a §24 lightweight bugfix pass.

Requires: local Supabase Docker container `supabase_db_yoonsul_wait_order_handoff` running,
and must be run from repo root (uses relative `sql/migrations/` paths and `git show HEAD:...`).
"""
import subprocess, os

result = subprocess.run(
    ["docker", "exec", "supabase_db_yoonsul_wait_order_handoff", "psql",
     "-U", "postgres", "-d", "postgres", "-t", "-A", "-c",
     "SELECT filename FROM catchmenu_meta.migration_history WHERE success = true ORDER BY filename;"],
    capture_output=True, text=True
)
filenames = [l.strip() for l in result.stdout.strip().split("\n") if l.strip()]

# git HEAD에 커밋된 버전(정규화 이전일 수도, 이후일 수도 있음)과
# 현재 디스크 파일을 "줄바꿈 무시하고" 비교
real_diff = []
crlf_only = []
for fn in filenames:
    path = os.path.join("sql", "migrations", fn)
    if not os.path.exists(path):
        continue
    with open(path, "rb") as f:
        current_raw = f.read()
    # git이 추적하는 blob (인덱스/HEAD 기준)
    show = subprocess.run(["git", "show", f"HEAD:sql/migrations/{fn}"],
                           capture_output=True)
    head_raw = show.stdout
    # 줄바꿈만 다른지 확인: \r\n -> \n 정규화 후 비교
    if current_raw.replace(b"\r\n", b"\n") == head_raw.replace(b"\r\n", b"\n"):
        crlf_only.append(fn)
    else:
        real_diff.append(fn)

print(f"줄바꿈만 다름 (내용 동일): {len(crlf_only)}개")
print(f"실제 내용도 다름 (진짜 위험): {len(real_diff)}개")
if real_diff:
    print("실제 내용이 다른 파일:")
    for f in real_diff:
        print(" -", f)
