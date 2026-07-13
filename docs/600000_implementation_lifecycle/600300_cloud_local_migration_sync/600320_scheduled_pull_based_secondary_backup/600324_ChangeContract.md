# 600324_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-13
CHANGE_ID: `scheduled_pull_based_secondary_backup`

## 1. Allowed Files

| 파일 | 동작 |
|---|---|
| `tools/cloud_target_config.py` | **신규** — `EXPECTED_PROJECT_REF`/`EXPECTED_HOST`/`EXPECTED_POOLER_USERNAME` 공유 상수 모듈(`600322_Logic.md` §2.2). `apply_migrations_cloud.py`는 이 모듈을 import하지 **않는다** — 그 리팩터는 별도 후속 건(§3 Open Items) |
| `tools/pull_secondary_backup.py` | **신규** — `E:\catchmenu_backups\` 폴더 확인/생성, `cloud_target_config.py` 상수 대조 안전장치, `supabase db dump --linked` 실행, 30일 보관 정책, `backup_log.txt` 로깅, 실패 시 재시도 없이 종료(`600322_Logic.md` §2 전체) |

## 2. Forbidden Files (명시적 범위 제외)

- `tools/apply_migrations_cloud.py` — **이번엔 수정 금지.** `cloud_target_config.py`를 참조하도록 리팩터하는 것이 바람직하다는 판단은 있으나, 이미 Audited(ACCEPT, `600214_ChangeContract.md`/이 파일 자체의 이전 Stage 6 감사 이력)된 파일을 다시 여는 작업이므로 별도 후속 변경건으로만 남긴다(§3 Open Items). 참조·인용만 한다.
- `sql/migrations/**` (전체) — 이 change는 백업 스크립트만 다루며 마이그레이션 파일을 생성/실행하지 않는다.
- `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600110_.../`, `600120_.../` 산출물(600111~600127 전체) — 무관, 편집 금지.
- `docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_.../` 산출물(600211~600217 전체) — 무관, 편집 금지.
- `supabase/config.toml`, `supabase/.gitignore` — 참조만(`.temp/project-ref`는 읽기만 하며 CLI가 관리하는 파일이므로 이 change가 직접 쓰지 않음, `600323_TestPlan.md` §3의 테스트 절차는 예외적으로 임시 위조 후 즉시 원복하는 테스트 전용 조작이며 스크립트 자체의 정상 동작이 아님).
- 위 목록에 없는 그 외 `sql/`, `catchmenu_app/`, `docs/600000_implementation_lifecycle/` 전체.

## 3. Open Items

1. **보관 기간 30일** — `600322_Logic.md` §5-1. 스토리지 용량/복구 시나리오 필요 기간 감안한 Human 확정 필요.
2. **Task Scheduler 실행 시각(제안: 새벽 3시)** — `600322_Logic.md` §5-2. 매장 운영/야간 배치와 겹치지 않는지 Human 확정 필요.
3. **`apply_migrations_cloud.py`를 `cloud_target_config.py` 참조 구조로 리팩터** — `600322_Logic.md` §5-5. 바람직하나 이미 Audited된 파일을 다시 여는 작업이라 별도 후속 변경건으로 분리. 이번 change는 이 리팩터를 하지 않는다.
4. **복구(restore) 절차의 별도 workpacket 분리** — `600322_Logic.md` §5-3. 백업 생성만으로는 복구 가능성이 검증되지 않으므로, 별도 change에서 실제 dry-run restore까지 다뤄야 한다는 점을 재확인.

## 4. Known Constraint — PC 상시 가동 전제 없음 (MVP 단계, 재논의 금지)

Human 결정(2026-07-11): 이 백업은 PC가 켜져 있는 동안만 실행되며, 클라우드 상시 스케줄러가 아니다. PC가 꺼져 있던 날은 그날의 백업이 누락된다 — 이는 이번 change의 결함이 아니라 MVP 단계에서 감수하기로 한 설계 전제다. Stage 4 구현자가 이를 "고치려" 임의로 상시 가동 인프라를 추가해서는 안 된다.

## 5. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (승인일자: 2026-07-11)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

**`000701` §4 Core Rule 준수**: 이 CHANGE_ID에 대해 `tools/` 내 어떤 파일도 이번 턴에 생성/수정되지 않았음(이번 턴 `git status`로 재확인, `.py` 파일 변경 0건, `apply_migrations_cloud.py` 미접촉). 이 섹션 서명 전까지 생성하지 않는다.
