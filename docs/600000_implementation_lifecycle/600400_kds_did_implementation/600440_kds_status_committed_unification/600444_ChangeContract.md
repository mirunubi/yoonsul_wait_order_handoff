# 600444_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Last Updated: 2026-07-13
CHANGE_ID: `kds_status_committed_unification`

## 1. Allowed Files

정확히 다음 13개 파일만 이번 change의 대상이다(`600441_Overview.md` §1, `0151` 포함 확정):

| 파일 | 허용 수정 범위 |
|---|---|
| `sql/migrations/0016_create_kds_tickets.sql` | `chk_kds_status` 제약값(`600442_Logic.md` §3), 부분 인덱스 2건 predicate(`idx_kds_tickets_store_zone`/`idx_kds_tickets_device`), 컬럼/제약 COMMENT 4건(§4.1) — `READY_TO_COMMIT` → `COMMITTED` 토큰 치환만. |
| `sql/migrations/0024_create_store_bootstrap_rpc.sql` | `get_store_bootstrap()` L154의 `kds_status in (...)` 리터럴만(§4.2). |
| `sql/migrations/0026_create_order_rpc.sql` | `cancel_order()` L585의 `kds_status in (...)` 리터럴만(§4.3). |
| `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` | `evaluate_kds_capacity()`/`commit_kds_ticket()`/`authorize_kds_release()` 3개 함수 본문 및 함수 COMMENT 2건 내 `READY_TO_COMMIT` 리터럴만(§4.4, 12곳). |
| `sql/migrations/0029_create_kds_cooking_rpc.sql` | `start_cooking()` 함수 본문 및 함수 COMMENT 내 리터럴만(§4.5, 7곳). |
| `sql/migrations/0039_create_kds_bulk_commit_rpc.sql` | `bulk_commit_kds_tickets()` L80/L97의 `(v_commit_result->>'kds_status') = 'READY_TO_COMMIT'` 비교식만(§4.6, 2곳) — `0028` L275와 반드시 짝을 맞춰 함께 수정. |
| `sql/migrations/0044_create_menu_management_rpc.sql` | `update_menu_status()` L107의 리터럴만(§4.7). |
| `sql/migrations/0045_create_daily_summary_rpc.sql` | `get_kds_performance()` 함수 COMMENT L688 서술문만(§4.8, 함수 본문 로직 변경 없음). |
| `sql/migrations/0051_create_pre_order_rpc.sql` | `confirm_pre_order_arrival()` 함수 COMMENT L907 서술문만(§4.9). |
| `sql/migrations/0070_create_flutter_bootstrap_rpc.sql` | `bootstrap_app()`(base, L292/L301) **및** `bootstrap_kds_app()`(wrapper, L586) — 두 함수 모두 함께 수정(§4.10). 한쪽만 수정하는 것은 이 ChangeContract의 의도를 벗어난다. |
| `sql/migrations/0081_create_customer_app_rpc.sql` | `track_takeout_order()` L1056/L1066의 리터럴만(§4.11). |
| `sql/migrations/0143_add_no_payment_kds_release_policy.sql` | `release_kds_ticket_no_payment()` 함수 본문 및 함수 COMMENT 내 리터럴만(§4.12, 7곳). |
| `sql/migrations/0151_create_check_kds_capacity_function.sql` | `check_kds_capacity()` L74의 `kds_status in ('COOKING', 'READY_TO_COMMIT')`만(§4.13). Human 결정(`600441_Overview.md` §3)으로 13번째 파일로 신규 포함 — 이미 Stage 6 Audited(ACCEPT, `600417_Audit.md`)된 파일이지만, 이번 수정은 그 판정을 무효화하는 것이 아니라 감사 이후 발생한 새 Human 결정에 따른 후속 파생 수정이다(`600442_Logic.md` §4.13). |

**공통 원칙**: 13개 파일 모두 `READY_TO_COMMIT` → `COMMITTED` 리터럴 치환(및 `0016`의 제약/인덱스 정의 갱신)만 허용한다 — 그 외의 어떤 로직 변경, 리팩터링, 새 컬럼/함수 추가도 허용하지 않는다.

## 2. Explicitly Forbidden

- **900시리즈 특허/설계 문서** — `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md`, `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md`, `900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md`, `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md`. 이 문서들은 `COMMITTED` 통일 결정의 **근거**일 뿐이다(`600441_Overview.md` §0) — 이번 change가 이 문서들을 수정할 이유는 없으며, 수정하지 않는다.
- **`600417_Audit.md`** — `0151`이 이미 이 문서에서 Stage 6 Audited(ACCEPT)됐다는 사실 때문에 교차 참조를 남길 필요성이 확인됐으나(`600442_Logic.md` §7 Open Item 1), 이번 change의 Allowed Files 목록 밖이다. 이번 배치에서는 수정하지 않는다 — 교차 참조 기입은 Open Item으로 이월(§3).
- `sql/migrations/0015_create_payment_reconciliation.sql`, `sql/migrations/0121_create_security_pipeline.sql` — 무관, 편집 금지(기존 원칙 재확인).
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`, `0099_create_realtime_pipeline_rpc.sql`, `0106_create_delivery_platform_pipeline_rpc.sql`, `0116_create_customer_app_bootstrap_rpc.sql` — 이미 `COMMITTED`를 사용 중이며 이번 재확인으로 클린 상태가 사실 확인됨(`600441_Overview.md` §4). 손댈 필요 없고, 손대지 않는다.
- §1 목록에 없는 그 외 `sql/migrations/**`, `catchmenu_app/**`, `docs/600000_implementation_lifecycle/` 내 이 워크패킷(`600440`) 외 다른 폴더 전체.

## 3. Open Items (전부 `600442_Logic.md`/`600443_TestPlan.md`에서 이월, 재논의 금지)

1. **`600417_Audit.md`로의 교차 참조 필요성** — `0151`이 이미 Stage 6 Audited(ACCEPT)된 파일이므로, 이번 후속 수정이 "감사 무효화"가 아니라 "감사 이후 파생된 후속 수정"임을 `600417_Audit.md` 쪽에도 남겨야 향후 그 문서만 단독으로 읽는 사람이 오해하지 않는다(`600442_Logic.md` §4.13/§7 Open Item 1). `600417_Audit.md`는 §2에서 명시했듯 이번 change의 Allowed Files 목록 밖이므로, 실제 교차 참조 기입은 별도 처리(이번 배치의 Stage 6 Audit 문서에서 `600417_Audit.md`를 갱신 대상으로 명시적으로 추가하는 방식, 또는 별도 경량 후속 변경건)로 넘긴다.
2. **`0028`/`0039`의 원자성 보장 방식** — 두 파일이 같은 ChangeContract(이 문서) 안에 함께 포함돼 있긴 하지만, 실행 순서/원자성을 같은 트랜잭션 안에서 보장할지, 아니면 순서만 고정하면 되는지는 아직 미확정이다(`600442_Logic.md` §7 Open Item 3, `600443_TestPlan.md` §7 Item 2). Stage 4 구현 시 §0(실행 순서: 제약 → 인덱스 → 함수)을 그대로 따르되, `0028`/`0039` 두 함수의 재실행 자체를 같은 트랜잭션으로 묶을지는 Stage 4 구현자가 결정하고 `600445_Module.md`(다음 번호, Stage 4 산출물)에 어느 쪽을 택했는지 기록한다.

## 4. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (실행: 600443_TestPlan.md의 §0 순서를 그대로 따라 실행) within the file boundary in §1 (승인일자: 2026-07-13)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

이 섹션의 체크박스가 Human에 의해 명시적으로 체크되기 전까지, 어떤 `.sql` 파일도 이 ChangeContract 하에서 수정되지 않으며, 어떤 라이브 DDL/함수 재실행도 실행되지 않는다.
