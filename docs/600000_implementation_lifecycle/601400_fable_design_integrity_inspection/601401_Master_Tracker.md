# 601401 — Master Tracker: Fable Design Integrity Inspection

- Program: `601400_fable_design_integrity_inspection`
- Created: 2026-07-19
- Owner role: Cursor (Eyes Only inventory/classification), Fable execution TBD
- Status: **Domain 01 COMPLETED — 6/6 slices inspected** (2026-07-19)
- Sibling program: `601300_fable_blind_reverse_engineering_audit` (separate track — blind code reverse-engineering)
- 운영안 canonical 위치: [`000716_Guide_CatchMenu_One_Time_Design_Integrity_And_Reverse_Engineering_Inspection_Operational_Plan.md`](../../000700_ai_agent_prelearning_and_project_context/000716_Guide_CatchMenu_One_Time_Design_Integrity_And_Reverse_Engineering_Inspection_Operational_Plan.md)

## 0. Number band confirmation

| Check | Result |
|---|---|
| `000005_Index_Document_Number.md` scan for `601400`–`601499` | **No prior entries** (2026-07-19) |
| `000007_Map_Full_Directory.md` scan for `601400` | **No prior folder** |
| Latest lifecycle program folder before this | `601300_fable_blind_reverse_engineering_audit` |
| **Confirmed BASE** | **`601400_fable_design_integrity_inspection`** |
| Master Tracker | `601401_Master_Tracker.md` |
| Domain 01 artifacts | `601411`–`601413` (Stage 1 inventory, structural issues, Stage 2 classification) |

`601020_authorize_kds_release_overload_and_redesign` under `600400_kds_did_implementation/` is a **workpacket** inside domain `600400`, not a lifecycle program folder — **no collision** with `601400`.

## 1. Program purpose

**설계무결성 검사 (Design Integrity Inspection)** — operational annex §6.1/§6.2 기준으로, 도메인별 전체 파일 인벤토리(Stage 1)와 lifecycle-layer 재분류(Stage 2)를 수행한다. Fable 블라인드 역설계(`601300`)와 달리 **설계 문서·SQL·JSON 계약을 포함**하며, 옳고그름 판단 없이 구조적 사실만 기록한다.

## 2. Domain progress table

| # | Domain folder | Stage 1 Inventory | Evidence Complete % | Stage 2 Classification | Fable Run ID | Output File | Review Date | Files Omitted | Status |
|---|---|---|---|---|---|---|---|---|---|
| 01 | `domain_01_customer_handoff` | **DONE** (2026-07-19) | 100% (495 files scoped) | **DONE** (2026-07-19) | Fable in-session → Opus 4.8 auto-transition (2026-07-19) | `601411`/`601412`/`601413`; slice_01 → **`601429`**; slice_02 → **`601431`**; slice_03 → **`601434`**; slice_04 → **`601427`**; slice_05 → **`601435`**; slice_06 → **`601437`** | 2026-07-19 | `990000_legacy_quarantine` partial overlap excluded from primary handoff path unless referenced | **6/6 슬라이스 완료 — COMPLETED** |
| 02 | `domain_02_payment_ledger_kds` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 03 | `domain_03_waiting_call_no_show` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 04 | `domain_04_order_cancel_refund` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 05 | `domain_05_menu_option_personalization` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 06 | `domain_06_pos_provider_gateway` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 07 | `domain_07_sop_agent_fallback` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 08 | `domain_08_inventory_scm` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 09 | `domain_09_security_rls_audit` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | FOLDER_ONLY |
| 10 | `domain_10_franchise_hq` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | **NO_DOCS_SQL — inspection target N/A (likely unimplemented)** |
| 11 | `domain_11_ai_customer_center` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | **NO_DOCS_SQL — inspection target N/A (likely unimplemented)** |
| 12 | `domain_12_saas_multitenant` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | **NO_DOCS_SQL — inspection target N/A (likely unimplemented)** |
| 13 | `domain_13_physical_ai` | NOT_STARTED | — | NOT_STARTED | — | — | — | — | **NO_DOCS_SQL — inspection target N/A (likely unimplemented)** |

- **Evidence Complete %**: Stage 1 scoped files inventoried vs. planned domain boundary.
- **Files Omitted**: Explicit exclusions during inventory (not judgment — scope boundary only).

## 3. Domain 01 metadata (Customer Handoff)

| Field | Value |
|---|---|
| Domain | Customer Handoff (waiting → call → pre-order → payment → KDS → DID → handoff) |
| Stage 1 Register | [601411_Register_Stage1_File_Inventory_Customer_Handoff.md](domain_01_customer_handoff/601411_Register_Stage1_File_Inventory_Customer_Handoff.md) |
| Stage 1 NDJSON | [601411_Inventory_Customer_Handoff.ndjson](domain_01_customer_handoff/601411_Inventory_Customer_Handoff.ndjson) |
| Structural Issues | [601412_Register_Stage1_Structural_Issues_Customer_Handoff.md](domain_01_customer_handoff/601412_Register_Stage1_Structural_Issues_Customer_Handoff.md) |
| Stage 2 Classification | [601413_Register_Stage2_Domain_Classification_Customer_Handoff.md](domain_01_customer_handoff/601413_Register_Stage2_Domain_Classification_Customer_Handoff.md) |
| Total files | 495 |
| Total bytes | 7,770,687 (~7.41 MiB) |
| Fable single-pass feasibility | **Likely requires slicing** — top concat artifacts alone ~250 KiB+ each; full 7.4 MiB exceeds typical single Fable context comfort zone. Recommend slice strategy mirroring `601300` (by flow: waiting / payment / KDS-DID / policy / runtime-flow). |
| Known Evidence Gaps | JSON payload/fixture files: 0 in scoped paths; Flutter app code minimal (2 dart screens under waiting) |

## 3.1 Domain 01 — Fable slice inspection progress (6-slice delivery)

| Slice | Input Package | Fable Output | Review Date | Findings (C/H/M/L) | Status |
|---|---|---|---|---|---|
| **`slice_01_waiting`** | **`601421` + core bundle `601428`** | **[601429](domain_01_customer_handoff/slices/slice_01_waiting/601429_Report_Fable_Design_Integrity_Inspection_Slice_01_Waiting.md)** | **2026-07-19** | **14 (1 / 4 / 5 / 3 + verified-clean 1)** | **FABLE_DONE** |
| **`slice_02_payment`** | **`601422` + core bundle `601430`** | **[601431](domain_01_customer_handoff/slices/slice_02_payment/601431_Report_Fable_Design_Integrity_Inspection_Slice_02_Payment.md)** | **2026-07-19** | **11 (1 / 4 / 4 / 2 + verified-clean 1)** | **FABLE_DONE** |
| **`slice_03_kds_did`** | **`601423` + core bundle `601432`** | **[601434](domain_01_customer_handoff/slices/slice_03_kds_did/601434_Report_Fable_Design_Integrity_Inspection_Slice_03_KDS_DID.md)** | **2026-07-19** | **9 (1 / 4 / 3 / 1)** | **FABLE_DONE** |
| **`slice_04_customer_handoff_policy`** | **`601424`** | **[601427](domain_01_customer_handoff/slices/slice_04_customer_handoff_policy/601427_Report_Fable_Design_Integrity_Inspection_Slice_04_Customer_Handoff_Policy.md)** | **2026-07-19** | **16 (1 / 6 / 6 / 3)** | **FABLE_DONE** |
| **`slice_05_runtime_flow`** | **`601425` + MD bundle `601433`** | **[601435](domain_01_customer_handoff/slices/slice_05_runtime_flow/601435_Report_Fable_Design_Integrity_Inspection_Slice_05_Runtime_Flow.md)** | **2026-07-19** | **4 (0 / 1 / 1 / 2)** | **FABLE_DONE** |
| **`slice_06_app_layer`** | **`601426` + core bundle `601436`** | **[601437](domain_01_customer_handoff/slices/slice_06_app_layer/601437_Report_Fable_Design_Integrity_Inspection_Slice_06_App_Layer.md)** | **2026-07-19** | **5 (0 / 0 / 3 / 2)** | **FABLE_DONE** |

Slice manifest: [601420_Register_Slice_Manifest_Customer_Handoff.md](domain_01_customer_handoff/slices/601420_Register_Slice_Manifest_Customer_Handoff.md).

### slice_06_app_layer — finding summary (2026-07-19)

| Severity | Count | Finding IDs |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 0 | — |
| MEDIUM | 3 | APP-F01, APP-F02, APP-F03 / APP-F04 중 공식 §9.1 aggregate 기준 3건 |
| LOW | 2 | APP-F05, APP-F06 |

**Finding total: 5** — CRITICAL 0, HIGH 0, MEDIUM 3, LOW 2.

### 방법론 교훈 — 반박된 거짓 CRITICAL

0116의 `bootstrap_customer_app_v2`만 읽으면 guest 호출이 `customer: null`을 반환해 Dart의 `_ensureGuestCustomerId()`가 항상 실패하는 것처럼 보인다. 그러나 같은 migration concat 뒤쪽의 **0149가 `CREATE OR REPLACE`로 함수를 교체**하며, guest customer를 생성하고 `data.customer.id`를 정상 반환한다. 따라서 이 would-be CRITICAL은 **반박됐으며 결함이 아니다**.

> **향후 도메인 검사 원칙: migration concat 파일은 반드시 끝까지 읽고 후속 `CREATE OR REPLACE`가 있는지 확인해야 한다.** 앞쪽 함수 본문만으로 live contract를 단정하지 않는다.

### slice_06 Owner Decision Queue (5 items)

1. Guest-customer TTL / dedup / retention / promotion cleanup을 정의한다. [APP-F03]
2. live path가 `customer_app_sessions`와 push token을 기록할지, v1/push RPC를 퇴역시킬지 결정한다. [APP-F04]
3. takeout client 연결 전 `place_takeout_order` phantom `order_items` 컬럼을 교정한다. [APP-F02]
4. Channel-1-web vs Channel-2-native, kiosk platform, same-binary-vs-flavor를 결정한다. [APP-F06]
5. concat/source의 superseded RPC body를 명시적으로 표시한다. [APP-F01]

### slice_06 Regular Workpacket Recommendation Queue (5 items)

| ID | Priority | Title | Finding |
|---|---|---|---|
| WP-1 | MEDIUM | Guest identity TTL·cleanup design | APP-F03 |
| WP-2 | MEDIUM | Live bootstrap와 app-session/push-token 경로 정합화 또는 v1 퇴역 | APP-F04 |
| WP-3 | MEDIUM | takeout RPC phantom-column correction을 repo-wide audit에 통합 | APP-F02 |
| WP-4 | LOW | Overview status·server-only RPC guard·stock README 정리 | APP-F05 |
| WP-5 | LOW | Channel/platform Open Item 결정 | APP-F06 |

### slice_05_runtime_flow — finding summary (2026-07-19)

| Severity | Count | Finding IDs / Notes |
|---|---:|---|
| CRITICAL | 0 | — |
| **HIGH** | **1** | **RUN-F01** |
| MEDIUM | 1 | RUN-F02 |
| LOW | 2 | RUN-F03, `gateway_sessions.*_scope` soft-reference/FK note |

**Finding total: 4** — CRITICAL 0, HIGH 1, MEDIUM 1, LOW 2.

### ⚠ 헤드라인 최우선 — RUN-F01 (79/81개 문서가 내용 없는 템플릿 껍데기)

`700100`–`700178`의 **79개 문서가 type-specific 내용이 없는 template-cloned placeholder shell**임을 byte-diff와 전수 구조 검사로 확인했다. 57개는 H1/Purpose/group-name 제거 후 byte-identical이며, 79개 전체에 Markdown table이 0개인데도 Matrix/Checklist/Evidence/Register/Audit/Runbook 등의 타입명을 사용한다. 런타임 위험은 없지만 문서 수를 부풀리고 사람이나 AI 검색자가 실제 설계·증거가 존재한다고 오인하게 할 수 있다. 전체 근거: `601435` §9.1/§9.2.

### 향후 검사 주의 패턴

**이 발견 유형(문서량은 많으나 실제 내용 없음)이 다른 미검사 도메인(5-9번)에도 있을 수 있다. 향후 검사 시 주의 깊게 볼 패턴으로 기록한다.** 파일 수·문서 타입명만 신뢰하지 않고, 본문 유사도·실제 표/체크리스트/증거 존재 여부를 함께 확인해야 한다.

### Owner Decision Queue (3 items — not auto-decidable)

1. 79개 placeholder clone을 실제 내용으로 채울지, 소수 문서로 통합할지, scaffold-not-design으로 명시하고 AI retrieval에서 제외할지 결정한다. [RUN-F01]
2. gateway ingress(0009)와 knowledge runtime(0019)의 실제 design docs를 작성할지 결정한다. [RUN-F02]
3. 700900을 canonical runtime-flow governance 위치로 확정하고 Readme/index를 완성할지 결정한다. [RUN-F03]

### Regular Workpacket Recommendation Queue (4 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | 700100–700178 scaffold disposition 및 machine-readable placeholder marker | RUN-F01 |
| WP-2 | MEDIUM | 0009/0019 runtime-flow·gateway-ingress 실설계 문서 작성 | RUN-F02 |
| WP-3 | LOW | 700900 Readme/index 완성과 700000 경계 명시 | RUN-F03 |
| WP-4 | LOW | `gateway_sessions.*_scope` FK 추가 또는 soft-reference 근거 문서화 | RUN-F02 SQL note |

### slice_03_kds_did — finding summary (2026-07-19)

| Severity | Count | Finding IDs |
|---|---:|---|
| **CRITICAL** | **1** | **KDS-F01** |
| HIGH | 4 | KDS-F02, KDS-F03, KDS-F04, KDS-F05 |
| MEDIUM | 3 | KDS-F06, KDS-F07, KDS-F08 |
| LOW | 1 | KDS-F09 |

**Finding total: 9** — CRITICAL 1, HIGH 4, MEDIUM 3, LOW 1.

### ⚠ 최우선 CRITICAL — KDS-F01 (`bootstrap_did_app` phantom)

`bootstrap_did_app()`(0117)이 실제 `did_devices`에 없는 `show_waiting_count`, `show_cms_content`, `supported_locales`, `default_locale`를 SELECT한다. **600820 Verification 단계에서 `ERROR: column "show_waiting_count" does not exist`로 실제 크래시가 재현된 기록이 있다.** 전체 근거: `601434` §9.7.

### ⚠ HIGH — KDS-F04 (migration 번호충돌 stop-and-report 원칙 위반)

600824 ChangeContract는 `0154`가 점유됐으면 멈추고 보고하며 명시적 재확인 없이 다른 번호를 선택하지 말라고 규정했다. 실제로 `0154`가 점유된 뒤 `0155`로 출하됐지만, 요구된 stop-and-report 또는 새 Human 확인 기록이 없고 승인 token·TestPlan·ChangeContract는 계속 `0154`를 가리킨다. 전체 근거: `601434` governance addendum.

### 미결항목 해소 확인 (새 결함 아님 — Owner Decision Queue 제외)

- 601020의 URGENT 미결항목이던 `confirm_payment`의 4개 phantom `payment_ledger` 컬럼은 **0158(600550)로 해결됨**을 확인했다.
- WAIT-F14의 `orders.requested_pickup_at` 누락은 **0152(600720)로 해결됨**을 확인했다.

### Owner Decision Queue (6 items — resolved closures excluded)

1. DID `did_devices` phantom 컬럼 reconciliation과 `601010` CMS-device-routing 의존성을 결정한다. [KDS-F01]
2. 0143 no-payment ticket이 `start_cooking` ledger check를 우회할지 결정하고 정책을 KDS index에 문서화한다. [KDS-F02]
3. 600810 및 900160/900161 event-reactive DID가 MVP인지 future인지 결정한다. [KDS-F05]
4. KDS 600520/601020과 DID 600810/600820을 back-index하고 number-band claim을 정합화한다. [KDS-F03]
5. 0154→0155 대체를 소급 승인하고 migration number conflict 재승인 규칙을 정한다. [KDS-F04]
6. 독립 verification rigor의 단일 표준을 정한다. [KDS-F08]

### Regular Workpacket Recommendation Queue (7 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **CRITICAL** | `did_devices` phantom-column reconciliation | KDS-F01 |
| WP-2 | HIGH | 0143 no-payment ↔ 0157 fail-closed reconciliation 및 정책 문서화 | KDS-F02 |
| WP-3 | HIGH | KDS/DID Index·NavigationMap·ChangeHistory back-index | KDS-F03 |
| WP-4 | HIGH | 0154→0155 번호변경 재승인 기록 및 600820 계약문서 정정 | KDS-F04 |
| WP-5 | HIGH / scope | DID event-reactive layer 및 900160/900161 상태 결정·문서화 | KDS-F05 |
| WP-6 | MEDIUM | 단일 repo-wide phantom-column audit | KDS-F06 |
| WP-7 | MEDIUM | 특허1/특허2 및 capacity late-binding의 900xxx authority 정합화 | KDS-F07 |

### slice_02_payment — finding summary (2026-07-19)

| Severity | Count | Finding IDs |
|---|---:|---|
| **CRITICAL** | **1** | **PAY-F01** |
| HIGH | 4 | PAY-F02, PAY-F03, PAY-F04, PAY-F05 |
| MEDIUM | 4 | PAY-F06, PAY-F07, PAY-F08, PAY-F09 |
| LOW | 2 | PAY-F10, PAY-F-hist |
| verified-clean | 1 | 여전법 및 payment audit/event-domain trap 비발생 확인 |

**Finding total: 11** — CRITICAL 1, HIGH 4, MEDIUM 4, LOW 2, verified-clean 1.

### ⚠ 최우선 CRITICAL — PAY-F01 (환불 파이프라인 + Toss-POS + audit_decision)

환불 파이프라인의 `payment_ledger` phantom 컬럼·무효 `REFUND_PENDING`/`REFUND_FAILED` 상태, Toss-POS(0104)의 phantom `order_items` 참조, 7개 라이브 파일의 무효 `audit_decision` literal로 인한 크래시 표면을 확증했다. 이는 **이미 알려진 Open Item들의 확증**이다. 전체 근거: `601431` §9.7.

### ⚠ HIGH — PAY-F05 (601030 Status 헤더 vs 본문 불일치)

601030 파일의 헤더는 `Status: Draft`이지만 본문에는 §10 APPROVED / §11 ACCEPT / §12 READY_FOR_HUMAN_MERGE가 기록돼 있다. **실제 승인은 정상이었을 가능성 높음(Human이 명시적으로 §9 체크 확인함), 헤더 메타데이터 갱신 누락으로 추정 - 확인 필요**. 전체 근거: `601431` §9.4.

### Owner Decision Queue (7 items — not auto-decidable)

1. `confirm_payment`(0098)와 `confirm_payment_from_provider`(0027) 및 KDS release gate를 통합·확정하고 staff path capacity gate 여부를 결정한다. [PAY-F02, PAY-F03]
2. 0143 no-payment 예외의 pilot scope와 권한을 문서화·확정한다. [PAY-F02]
3. Refund Pipeline Contract Redesign을 승인한다. [PAY-F01]
4. `orders.paid_at`, `order_items`(0104/0727), customer-app laggard를 포함한 repo-wide phantom-column audit 범위를 확정한다. [PAY-F06]
5. 601030 Status/Stage 및 approval-before-commit 순서를 확인하고 verification-integrity control을 채택한다. [PAY-F05]
6. 600500 Readme/NavigationMap 동기화와 pending `600920` renumbering을 결정한다. [PAY-F04, PAY-F09]
7. 0159 UNIQUE idempotency-key의 cross-path collision 여부를 감사한다. [PAY-F08]

### Regular Workpacket Recommendation Queue (7 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **CRITICAL** | Refund Pipeline Contract Redesign + audit_decision literal repair | PAY-F01 |
| WP-2 | CRITICAL / HIGH | Toss-POS(0104) phantom `order_items` correction | PAY-F01, PAY-F06 |
| WP-3 | HIGH | Payment-confirmation pipeline shared-core/unification + staff capacity-gate decision | PAY-F02, PAY-F03 |
| WP-4 | HIGH | 0143 no-payment 예외 문서화·governance + 600500 index sync | PAY-F02, PAY-F04 |
| WP-5 | MEDIUM | Repo-wide phantom-column audit | PAY-F06 |
| WP-6 | MEDIUM | Verification-integrity + live-DB test-isolation controls | PAY-F05, PAY-F07 |
| WP-7 | MEDIUM | 0159 idempotency-key cross-path collision audit | PAY-F08 |

### slice_01_waiting — finding summary (2026-07-19)

| Severity | Count | Finding IDs |
|---|---:|---|
| **CRITICAL** | **1** | **WAIT-F01** |
| HIGH | 4 | WAIT-F02, WAIT-F03, WAIT-F04, WAIT-F05 |
| MEDIUM | 5 | WAIT-F06, WAIT-F07, WAIT-F08, WAIT-F09, WAIT-F10 |
| LOW / FUTURE | 3 | WAIT-F11, WAIT-F12, WAIT-F13, WAIT-F14 중 §9.1 aggregate 기준 3건 |
| verified-clean | 1 | `chk_event_caused_by_type`의 `CUSTOMER` 허용 확인 |

**Finding total: 14** — CRITICAL 1, HIGH 4, MEDIUM 5, LOW/FUTURE 3, verified-clean 1.

### ⚠ 최우선 CRITICAL — WAIT-F01 (`pre_order_while_waiting`)

오늘 이미 진행 중인 **600680 `pre_order_while_waiting_phantom_correction` 워크패킷이 정확히 이 문제를 겨냥하고 있음을 교차확인**했다. 현재 상태는 **설계는 이미 완료, Human 승인 대기 중**이며, Opus 검사 결과와 정확히 일치한다. `orders.order_source`, 무효 `order_type='TABLE'`, `order_items.unit_price/subtotal/item_options`, `order_sessions.pre_order_amount` phantom 참조와 `order_id`/`pre_order_created_at` 미기록이 핵심이다. 전체 근거: `601429` §9.7.

### ⚠ HIGH — WAIT-F02 (NavigationMap / Readme 누락)

`600600_Readme`에는 **600630/600640/600650/600660/600670/600680 여섯 워크패킷이 누락**됐고, `600602_NavigationMap`에는 600670/600680이 누락됐다. **이미 커밋된 600670조차 두 인덱스 어디에도 등록되지 않은 상태**다. 전체 근거: `601429` §9.2.

### Owner Decision Queue (6 items — not auto-decidable)

1. No-show KDS 모델을 `HOLD→NO_SHOW_GRACE→auto-CANCELLED`로 확정하고 900101(+005410)을 갱신한다. [WAIT-F03 / CH-F02]
2. 0081/0116 phantom 컬럼과 pre-0148 `os.customer_id` 사용을 correction 범위로 확정한다. [WAIT-F05 / CH-F01]
3. `0115` 등의 superseded 함수 본문에 annotation/superseded stamp를 둘지 결정한다. [WAIT-F04]
4. NavigationMap + Readme 동기화를 의무화한다. [WAIT-F02]
5. workpacket lifecycle Stage-marker 단일 규칙을 결정한다. [WAIT-F06]
6. `get_waiting_status`를 `waiting_status_screen.dart`에 연결할지 결정한다. [WAIT-F09]

### Regular Workpacket Recommendation Queue (8 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **CRITICAL** | 600680 `pre_order_while_waiting` phantom correction 승인·Stage-8 진행 | WAIT-F01 |
| WP-2 | HIGH | Customer-app RPC phantom + `customer_id` correction (0081/0116) | WAIT-F05 |
| WP-3 | HIGH | 900101·005410 no-show grace 모델 문서 정합화 | WAIT-F03 |
| WP-4 | HIGH | 600600·600200 Index/NavigationMap/Readme 동기화 | WAIT-F02, WAIT-F10 |
| WP-5 | MEDIUM | superseded `0115`/`0050` 본문 Source-of-Truth annotation | WAIT-F04 |
| WP-6 | MEDIUM | Stage-marker + ChangeContract status normalization | WAIT-F06 |
| WP-7 | MEDIUM | `get_waiting_status` customer status screen 연결 또는 비연결 근거 문서화 | WAIT-F09 |
| WP-8 | LOW | `orders.requested_pickup_at` 존재 여부 확인 후 finding close | WAIT-F14 |

### slice_04_customer_handoff_policy — finding summary (2026-07-19)

| Severity | Count | Finding IDs |
|---|---:|---|
| **CRITICAL** | **1** | **CH-F01** |
| HIGH | 6 | CH-F02, CH-F03, CH-F04, CH-F05, CH-F06 (+1 per Fable §9.1 aggregate) |
| MEDIUM | 6 | CH-F08, CH-F09, CH-F10, CH-F11, CH-F12, CH-F13 |
| LOW / OUT-OF-SCOPE | 3 | CH-F14, CH-F15 (+1 per Fable §9.1 aggregate) |

**Finding total: 16** — CRITICAL 1, HIGH 6, MEDIUM 6, LOW/OUT-OF-SCOPE 3.

### ⚠ 최우선 CRITICAL — CH-F01 (customer-app phantom + governance gate breach)

**0081** header explicitly defers `order_sessions.customer_id` linkage until a designed forward migration passes the full `000701` pipeline (design lock, human approval, implementation, verification, audit). **0116** (later) re-enables `os.customer_id` queries in `bootstrap_customer_app_v2`, `get_customer_home`, `qr_scan_action`, `get_order_tracking`, `get_customer_history` without that gate — column arrives only in **0148** (waiting slice). Additional phantom columns: `pre_order_amount` on `order_sessions`; `unit_price`/`subtotal`/`display_order`/`is_kds_required` on `order_items` in `place_takeout_order`/`track_takeout_order` — **same defect family as workpacket 600680**. At minimum: governance-gate breach; at worst: `42703`/`23502` runtime crash surface. Full evidence: `601427` §9.7.

### Owner Decision Queue (8 items — not auto-decidable)

1. No-show / prepaid-cancel KDS fate — CANCELLED (900101 Logic) vs HOLD-with-grace (contracts + live SQL)? [CH-F02]
2. Order-confirmed-before-payment — ratify 005027 (post-gate) or 005060 (pre-payment)? SQL follows 005060. [CH-F03]
3. Provider cutline — ratify Toss+OKPOS (005241); stamp Toss+PAYCO (005191) superseded; re-point kiosk bundle. [CH-F04]
4. Canonical ChangeContract/TestPlan — 900102/900103 canonical; migrate unique 9060xx content; retire 906000/906010. [CH-F05]
5. Canonical customer-session table(s) — `order_sessions` vs `customer_app_sessions`; `customer_id↔order_sessions` linkage. [CH-F06, CH-F01]
6. Guest-identity operation — claim ≡ merge ≡ upgrade, or distinct ops? [CH-F10]
7. TTL policy — numeric expirations (token/cart/coupon-hold/guest-session/retention). [CH-F09]
8. Delivery pre-paid no-HOLD bypass — sanction or forbid; reconcile with INV-001. [CH-F11]

### Regular Workpacket Recommendation Queue (Owner-gated — candidates only)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-A** | **CRITICAL** | Customer-app phantom-column + deferral-gate correction (600680 sibling) | CH-F01 |
| WP-B | HIGH | No-show KDS-fate reconciliation (Logic vs contracts vs SQL) | CH-F02 |
| WP-C | HIGH | Payment-sequencing authority unification (005027 vs 005060) | CH-F03 |
| WP-D | HIGH | Provider-cutline supersession + kiosk-bundle re-pointing | CH-F04 |
| WP-E | HIGH | Patent-contract de-duplication (900102/900103 canonical) | CH-F05 |
| WP-F | HIGH | Customer-session Source-of-Truth + `customer_id↔order_sessions` linkage design | CH-F06 |
| WP-G | MEDIUM | 005012–005020 reference-integrity sweep + Status/Supersedes front-matter | CH-F08, CH-F12 |
| WP-H | MEDIUM | TTL/expiration numeric specification pass | CH-F09 |

### §6.4 baseline for remaining slices (from slice_04)

Downstream slices (waiting / payment / KDS-DID / runtime / app) should be checked against the six binding contracts recorded in `601427` §9.9 closing block (Payment→KDS HOLD gate, 여전법 ledger, dual session tables, 005410 sync, 005151 Toss gating, vision-doc scope hygiene).

## 3.2 Domain 01 Customer Handoff — final aggregate summary

**Completion:** 6/6 slices inspected — **COMPLETED** (2026-07-19).

| Slice | Output | Reported Finding Total | Severity (C/H/M/L) |
|---|---|---:|---|
| slice_01_waiting | `601429` | 14 | 1 / 4 / 5 / 3 (+ verified-clean 1) |
| slice_02_payment | `601431` | 11 | 1 / 4 / 4 / 2 (+ verified-clean 1) |
| slice_03_kds_did | `601434` | 9 | 1 / 4 / 3 / 1 |
| slice_04_customer_handoff_policy | `601427` | 16 | 1 / 6 / 6 / 3 |
| slice_05_runtime_flow | `601435` | 4 | 0 / 1 / 1 / 2 |
| slice_06_app_layer | `601437` | 5 | 0 / 0 / 3 / 2 |
| **Domain 01 cumulative** | **6 reports** | **59** | **4 / 19 / 22 / 13** |

누적 Finding 총계는 각 slice 보고서가 선언한 `Finding total`의 합인 **59건**이다. Severity 표기 합은 58건이며, slice_01/slice_02가 별도로 기록한 verified-clean positive observation 2건은 결함 severity와 분리해 유지한다. 원 보고서별 집계 관례 차이를 숨기지 않고 그대로 보존한다.

### Recurrent cross-slice patterns

1. **Phantom 컬럼군** — `order_items`, `order_sessions`, `payment_ledger`, `did_devices`, refund/customer-app/takeout RPC 전반에서 반복됐다. 일부는 0152/0158 등으로 해결됐지만 live-broken 또는 latent surface가 남아 있어 단일 repo-wide phantom-column audit가 반복 추천됐다.
2. **Index / NavigationMap drift** — waiting, payment, KDS/DID 도메인에서 이미 구현·커밋·ACCEPT된 workpacket까지 Readme/NavigationMap/ChangeHistory에 누락됐다. 파일시스템과 색인 문서를 함께 봐야 한다.
3. **`CREATE OR REPLACE` 잔존과 source-vs-live ambiguity** — 0050/0115/0116 등 앞선 migration의 오래된 함수 본문이 남고 후속 migration이 live 함수를 교체한다. migration concat은 끝까지 읽고 최신 재정의를 canonical로 판정해야 한다.
4. **TTL 미문서화** — customer-app session 30일, client SharedPreferences 무기한, anonymous customer row retention/cleanup 등 수명주기 정책이 분산되거나 미정이다.
5. **검증 엄격도 불일치** — Claude-only, dual, triple verification이 혼재하고 fabricated/duplicate verification claim이 실제로 적발됐다. 독립 재현과 승인 provenance의 단일 기준이 필요하다.

### Domain-level closing assessment

- Core waiting/payment/KDS gate와 0148/0149 guest linkage에는 실제로 sound한 계약과 self-correcting workpacket이 존재한다.
- 동시에 phantom-column runtime blockers, caller-less latent RPC, stale indexes, superseded source body, empty scaffold 문서가 공존한다.
- Domain 01 검사는 설계·구현 처분을 확정하지 않고, Owner Decision Queue와 정규 Workpacket 후보로 이관할 근거를 완성한 상태로 종료한다.

## 4. Structural issue summary (Domain 01 — fact counts)

| Issue class | Count (2026-07-19 scan) |
|---|---:|
| Filename ↔ H1 mismatch | 6 |
| Duplicate doc numbers in inventory | 3 |
| `600600` workpackets with Overview, no in-folder NavigationMap/Index | 8 |
| Legacy governance index basename refs (`000005_Document_Number_Index.md` etc.) | see `601412` |
| PLACEHOLDER/NOT_STARTED markers (first 800 chars) | 8 |
| Active docs referencing `604000_workpackets/` string | see `601412` §6 |

Detail: `601412_Register_Stage1_Structural_Issues_Customer_Handoff.md`.

## 5. Non-goals (this program)

- No correctness/design judgment (Eyes Only).
- No modification of inventoried source files during Stage 1/2.
- Not a substitute for `601300` Pass A/B/C blind reverse-engineering.

## 6. Snapshot Decision

- 2026-07-19: Confirmed empty band `601400` via `000005`/`000007` and filesystem listing (`601300` last program). Created program folder, 13 domain subfolders, Master Tracker, and completed Domain 01 Stage 1+2 inventory/classification (495 files, 7.77 MB).
- 2026-07-19: **slice_04_customer_handoff_policy** Fable design-integrity inspection complete — verbatim output saved as `601427` (16 findings: CRITICAL 1, HIGH 6, MEDIUM 6, LOW/OUT-OF-SCOPE 3). CH-F01 flagged 최우선; Owner Decision Queue ×8; Workpacket candidates WP-A–WP-H recorded in Master Tracker §3.1.
- 2026-07-19: **slice_01_waiting** design-integrity inspection complete — Opus 4.8 reviewer output saved verbatim as `601429` with required reviewer header (14 findings: CRITICAL 1, HIGH 4, MEDIUM 5, LOW/FUTURE 3, verified-clean 1). WAIT-F01 flagged 최우선 and cross-checked against in-progress 600680 (**설계는 이미 완료, Human 승인 대기 중**); WAIT-F02 highlighted; Owner Decision Queue ×6; Workpacket candidates WP-1–WP-8 recorded in Master Tracker §3.1.
- 2026-07-19: **slice_02_payment** design-integrity inspection complete — Opus 4.8 reviewer output saved verbatim as `601431` (11 findings: CRITICAL 1, HIGH 4, MEDIUM 4, LOW 2, verified-clean 1). PAY-F01 flagged 최우선 as confirmation of known Open Items; PAY-F05 recorded as likely header-metadata drift requiring confirmation; Owner Decision Queue ×7; Workpacket candidates WP-1–WP-7 recorded in Master Tracker §3.1.
- 2026-07-19: **slice_03_kds_did** design-integrity inspection complete — Opus 4.8 reviewer output `601434` saved from the formal §9.1 start through the closing baseline (9 findings: CRITICAL 1, HIGH 4, MEDIUM 3, LOW 1). KDS-F01 flagged 최우선 with existing Verification-time crash evidence; KDS-F04 highlighted; two resolved Open Items (601020 URGENT→0158, WAIT-F14→0152) recorded separately and excluded from Owner Decision Queue; Owner Decision Queue ×6; Workpacket candidates WP-1–WP-7 recorded in Master Tracker §3.1.
- 2026-07-19: **slice_05_runtime_flow** design-integrity inspection complete — Opus 4.8 reviewer output `601435` saved from formal §9.1 through the closing baseline (4 findings: CRITICAL 0, HIGH 1, MEDIUM 1, LOW 2). RUN-F01 (79/81 content-empty template shells) flagged as the headline finding; the same high-volume/empty-content pattern recorded for special attention in future inspections of domains 5–9; Owner Decision Queue ×3; Workpacket candidates WP-1–WP-4 recorded in Master Tracker §3.1.
- 2026-07-19: **slice_06_app_layer** design-integrity inspection complete — Opus 4.8 reviewer output `601437` saved from formal §9.1 through the domain closing note (5 findings: CRITICAL 0, HIGH 0, MEDIUM 3, LOW 2). The false would-be CRITICAL caused by reading 0116 without the later 0149 `CREATE OR REPLACE` was explicitly refuted and retained as a methodology lesson.
- 2026-07-19: **domain_01_customer_handoff COMPLETED — 6/6 slices**. Reported cumulative Finding total 59; recurring phantom-column/index-drift/CREATE-OR-REPLACE residue/TTL/verification-rigor patterns consolidated in §3.2.
