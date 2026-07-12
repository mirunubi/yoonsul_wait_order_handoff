# 600116_Verification.md

Status: Complete
Lifecycle: Verification
Stage: 5 (Claude Code — cross-model re-verification of Codex's `600115_Module.md` self-report; not self-verification, since this agent did not write the implementation)
Owner: TBD
Last Updated: 2026-07-11

`000701` §30/§28 원칙: Codex의 self-report(`600115_Module.md`)를 액면 신뢰하지 않고, 이번 턴에 직접 로컬 DB와 git을 재조회해 독립 검증했다.

## 1. 컬럼 존재 확인

```
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name, is_nullable FROM information_schema.columns WHERE table_schema='catchmenu_pos' AND table_name='order_sessions' AND column_name IN ('customer_id','phone_hash');"
```

**결과**:
```
customer_id|YES
phone_hash|YES
```

## 2. `is_guest` 존재 확인

```
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_schema='catchmenu_store' AND table_name='customers' AND column_name='is_guest';"
```

**결과**:
```
is_guest
```

## 3. `ON DELETE SET NULL` 확인

```
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT confdeltype FROM pg_constraint WHERE conname = 'order_sessions_customer_id_fkey';"
```

**결과**:
```
n
```
(`n` = SET NULL. 이전 out-of-band 상태였던 `a`=NO ACTION에서 정상적으로 재조정됨 — `600112_Logic.md` §2.2가 정정된 근거.)

## 4. `migration_history` 기록 확인

```
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -t -A -c "SELECT filename, success, applied_at, error_message FROM catchmenu_meta.migration_history WHERE filename LIKE '0148%';"
```

**결과**:
```
0148_add_order_sessions_customer_id_and_guest_flag.sql|t|2026-07-10 18:54:26.465814+00|
```
(`success = t`, `error_message` 없음. `applied_at`이 UTC 표기라 커밋 시각(KST)보다 날짜가 하루 앞서 보이는 것에 대해서는 `600117_Audit.md`에서 별도로 다룬다.)

## 5. `git status` / `git diff --check` 결과

```
git status --short sql/migrations/0148_add_order_sessions_customer_id_and_guest_flag.sql sql/migrations/CHANGELOG.md .gitattributes sql/migrations/0000_create_migration_history_table.sql
```
**결과**: 빈 출력 — 4개 파일 전부 커밋 완료 상태(clean), 미커밋 변경 없음.

```
git diff --check -- "docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/"
```
**결과**: exit 0 — 이번 턴까지 이 폴더 하위 문서에 whitespace 오류 없음.

## 6. 추가 독립 확인 — `0000` checksum 정합성 (Module.md §2.1 주장 재검증)

`apply_migrations.py`의 `checksum()` 방식(CRLF→LF 정규화 후 SHA-256)을 그대로 로컬에서 재현:

```python
import hashlib
raw = open('sql/migrations/0000_create_migration_history_table.sql','rb').read().replace(b'\r\n', b'\n')
print(hashlib.sha256(raw).hexdigest())
```
**결과**: `9129ec09b3ce8b8ab37510f6ea540f07cf70f47791ca73917e6af32bca40fd28`

DB의 `catchmenu_meta.migration_history` 기록값과 대조 — **정확히 일치**. `600115_Module.md` §2.1의 "현재는 mismatch 해소" 주장을 독립적으로 재확인함.

## 7. 검증 결론

4개 쿼리 + git 상태 + 독립 checksum 재계산, 총 6개 확인 항목 전부 Codex self-report(`600115_Module.md`)의 주장과 일치. `600115_Module.md` §3 갱신 확인: Docker 권한 이슈는 Windows Docker Desktop의 config.json 접근 거부(npipe 연결 실패)로 확인됨, Human이 권한 승인 후 재실행하여 정상 진행됨. 이 로그는 git/CHANGELOG에 남지 않는 임시 실행 오류이므로 `600115_Module.md`가 유일한 기록이다.
