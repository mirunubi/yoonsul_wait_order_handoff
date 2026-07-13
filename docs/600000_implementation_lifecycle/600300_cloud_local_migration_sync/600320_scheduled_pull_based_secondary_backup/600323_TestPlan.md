# 600323_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 명령어다. 이 TestPlan은 `tools/cloud_target_config.py`/`tools/pull_secondary_backup.py`가 Stage 4에서 작성된 뒤 실행하는 절차이며, 이번 문서 작성 시점에는 두 파일이 아직 존재하지 않는다(Stage 1.5, `.py` 파일 미생성).

## 1. `cloud_target_config.py` 단독 테스트

```powershell
cd D:\workspace\yoonsul_wait_order_handoff
python -c "from tools.cloud_target_config import EXPECTED_PROJECT_REF, EXPECTED_HOST, EXPECTED_POOLER_USERNAME; print(EXPECTED_PROJECT_REF); print(EXPECTED_HOST); print(EXPECTED_POOLER_USERNAME)"
```

기대 결과:
```
upzthfwhtvazfftxnyfu
db.upzthfwhtvazfftxnyfu.supabase.co
postgres.upzthfwhtvazfftxnyfu
```
import 실패(모듈 없음/상수 없음) 없이 3줄 모두 출력되어야 한다. `apply_migrations_cloud.py`가 갖고 있는 동일 상수 값과 문자 그대로 일치하는지 육안 대조도 함께 한다(`grep -n "EXPECTED_PROJECT_REF\|EXPECTED_HOST\|EXPECTED_POOLER_USERNAME" tools/apply_migrations_cloud.py`).

## 2. 정상 시나리오 — 올바른 project-ref로 링크된 상태에서 백업 실행

사전 확인(이미 이번 세션에 확인됨, 재확인만):
```powershell
Get-Content supabase\.temp\project-ref
```
기대: `upzthfwhtvazfftxnyfu` (= `EXPECTED_PROJECT_REF`).

```powershell
python tools\pull_secondary_backup.py
```
기대 결과:
- 종료 코드 0
- `E:\catchmenu_backups\cloud_backup_<timestamp>.sql` 신규 생성 확인:
  ```powershell
  Get-ChildItem E:\catchmenu_backups\cloud_backup_*.sql | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  ```
- `E:\catchmenu_backups\backup_log.txt`에 `OK` 라인 1건 추가 확인:
  ```powershell
  Get-Content E:\catchmenu_backups\backup_log.txt -Tail 1
  ```
  기대: `... | OK | file=cloud_backup_<timestamp>.sql | size_bytes=<0보다 큰 정수> | free_space_gb=<숫자> | error=-`

## 3. 안전장치 시나리오 — project-ref 파일 값 위조 시 REFUSED

**실제 다른 프로젝트로 link하지 않는다** — 파일 값만 임시로 바꾼 뒤 즉시 원복하는 방식으로, Codex가 이전에 안전하게 재현했던 것과 동일한 절차를 따른다.

```powershell
# 1) 현재 값 백업
Copy-Item supabase\.temp\project-ref supabase\.temp\project-ref.bak

# 2) 값을 가짜로 위조
Set-Content supabase\.temp\project-ref -Value "fake-wrong-project-ref-test" -NoNewline

# 3) 백업 스크립트 실행 — REFUSED로 즉시 중단되어야 함
python tools\pull_secondary_backup.py
```
기대 결과:
- 종료 코드 0이 아님(0이면 안전장치가 작동하지 않은 것 — FAIL)
- stderr에 `REFUSED: linked Supabase project ref 'fake-wrong-project-ref-test' does not match the approved project ref 'upzthfwhtvazfftxnyfu'` 계열 메시지
- `E:\catchmenu_backups\`에 새 `.sql` 파일이 **생성되지 않았어야 함**(§2에서 확인한 최신 파일 이후로 파일 개수 불변):
  ```powershell
  (Get-ChildItem E:\catchmenu_backups\cloud_backup_*.sql).Count
  ```
- `backup_log.txt`에 `FAIL` 라인 추가, `error=` 필드에 위 REFUSED 메시지 포함

```powershell
# 4) 즉시 원복 — 절대 생략하지 말 것
Copy-Item supabase\.temp\project-ref.bak supabase\.temp\project-ref -Force
Remove-Item supabase\.temp\project-ref.bak
Get-Content supabase\.temp\project-ref
```
기대: 원복 후 다시 `upzthfwhtvazfftxnyfu` 확인.

## 4. `E:\` 드라이브 접근 실패 시나리오

```powershell
# 폴더를 임시로 다른 이름으로 바꿔 접근 불가 상태를 만든다
Rename-Item E:\catchmenu_backups E:\catchmenu_backups_temp_renamed

python tools\pull_secondary_backup.py
```
기대 결과: `ensure_backup_dir()`이 원래 경로(`E:\catchmenu_backups`)를 `mkdir(parents=True, exist_ok=True)`로 재생성하려 시도할 것이므로(폴더가 없으면 새로 만드는 것이 정상 동작), 이 시나리오가 실제로 검증하는 것은 "폴더가 없을 때 자동 생성되는지"이지 "접근 불가 시 에러"가 아니라는 점에 유의 — 그래서 이 테스트는 다음 두 결과 중 하나가 나와야 정상이다:
- (a) `E:\catchmenu_backups`가 새로 생성되고 정상적으로 백업이 진행된다(폴더 부재는 에러가 아니라 자동 복구 대상), 또는
- (b) 권한 문제 등으로 생성 자체가 실패하면 `REFUSED: cannot access or create E:\catchmenu_backups: <OSError 메시지>` 형태로 명확히 종료된다.

두 결과 모두 "조용히 다른 경로로 대체"나 "예외를 삼키고 계속 진행"이 아니면 PASS.

```powershell
# 원복
if (Test-Path E:\catchmenu_backups) { Remove-Item E:\catchmenu_backups_temp_renamed -Recurse -ErrorAction SilentlyContinue }
else { Rename-Item E:\catchmenu_backups_temp_renamed E:\catchmenu_backups }
```

## 5. 30일 보관 정책 테스트 — mtime 조작으로 실제 대기 없이 검증

```powershell
# 35일 전 mtime을 가진 더미 파일 생성
$dummy = "E:\catchmenu_backups\cloud_backup_dummy_old_test.sql"
Set-Content $dummy -Value "dummy" -NoNewline
(Get-Item $dummy).LastWriteTime = (Get-Date).AddDays(-35)

python -c "from tools.pull_secondary_backup import prune_old_backups; removed = prune_old_backups(); print([str(p) for p in removed])"
```
기대 결과: 출력 리스트에 `cloud_backup_dummy_old_test.sql` 경로가 포함되고, 파일이 실제로 삭제됨:
```powershell
Test-Path $dummy
```
기대: `False`.

**대조군**: 29일 전 mtime을 가진 더미 파일은 삭제되지 않아야 한다(경계값 확인).
```powershell
$dummy2 = "E:\catchmenu_backups\cloud_backup_dummy_recent_test.sql"
Set-Content $dummy2 -Value "dummy" -NoNewline
(Get-Item $dummy2).LastWriteTime = (Get-Date).AddDays(-29)
python -c "from tools.pull_secondary_backup import prune_old_backups; prune_old_backups()"
Test-Path $dummy2
```
기대: `True`(살아있음). 테스트 후 `$dummy2` 수동 삭제로 정리.

## 6. Windows Task Scheduler 등록 테스트

```powershell
schtasks /create /tn "CatchMenu_CloudSecondaryBackup_TEST" /tr "python D:\workspace\yoonsul_wait_order_handoff\tools\pull_secondary_backup.py" /sc daily /st 03:00
```
기대 결과: `SUCCESS: The scheduled task "CatchMenu_CloudSecondaryBackup_TEST" has successfully been created.`

```powershell
schtasks /query /tn "CatchMenu_CloudSecondaryBackup_TEST"
```
기대 결과: 방금 등록한 작업이 조회되며 `Ready`/`Scheduled` 상태와 다음 실행 시각(오늘 또는 내일 03:00)이 표시된다.

**정리(테스트용 태스크이므로 실제 운영 등록 전 반드시 삭제)**:
```powershell
schtasks /delete /tn "CatchMenu_CloudSecondaryBackup_TEST" /f
```

## 7. Open Items (→ `600324_ChangeContract.md`로 이월)

1. §6은 테스트용 태스크 이름(`_TEST` 접미사)으로 등록/조회/삭제만 검증한다 — 실제 운영 태스크 이름·등록 시점은 Stage 3 승인 이후 별도로 확정한다.
2. §3/§4/§5는 모두 실제 데이터를 건드리지 않는 방식(파일 값 임시 위조 후 즉시 원복, 폴더 임시 리네임 후 원복, 더미 파일만 사용)으로 설계했다 — Stage 4 구현자는 이 순서(위조 → 테스트 → 즉시 원복)를 반드시 그대로 지켜야 한다.
3. 보관 기간(30일)/실행 시각(새벽 3시)은 여전히 제안값이며 Human 확정 전까지는 §2/§5/§6의 구체적 숫자도 잠정치다.
