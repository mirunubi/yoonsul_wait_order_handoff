# 601401 — Master Tracker: Fable Design Integrity Inspection

- Program: `601400_fable_design_integrity_inspection`
- Created: 2026-07-19
- Owner role: Cursor (Eyes Only inventory/classification), Fable execution TBD
- Status: **Domains 01–02 COMPLETED — each 6/6 slices inspected** (Domain 02 completed 2026-07-20)
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
| 02 | `domain_02_payment_ledger_kds` | **DONE** (2026-07-20) | 100% (6/6 slices) | **DONE** (2026-07-20) | Opus 4.8 (2026-07-19/20) | slice_A → **`601440`**; slice_B → **`601442`**; slice_C → **`601445`**; slice_D1 → **`601449`**; slice_D2 → **`601450`**; slice_D3 → **`601451`** | 2026-07-20 | — | **6/6 슬라이스 완료 — COMPLETED** |
| 03 | `domain_03_waiting_call_no_show` | **DONE** (2026-07-20) | 100% (2/2 slices) | **DONE** (2026-07-20) | Opus 4.8 (2026-07-20) | slice_A → **`601454`**; slice_B → **`601455`** | 2026-07-20 | — | **2/2 슬라이스 완료 — COMPLETED** |
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

## 3.3 Domain 02 — Fable slice inspection progress

| Slice | Input | Fable Output | Review Date | Findings (C/H/M/L) | Status |
|---|---|---|---|---|---|
| **`slice_A_kitchen_release_gate`** | core MD bundle **`601439`** + SQL concat (9 migrations) | **[601440](domain_02_payment_ledger_kds/slice_A_kitchen_release_gate/601440_Report_Fable_Design_Integrity_Inspection_Slice_A_Kitchen_Release_Gate.md)** | **2026-07-19** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |
| **`slice_B_financial_trust_room`** | core MD bundle **`601441`** (26 policy MD; no SQL) | **[601442](domain_02_payment_ledger_kds/slice_B_financial_trust_room/601442_Report_Fable_Design_Integrity_Inspection_Slice_B_Financial_Trust_Room.md)** | **2026-07-19** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |
| **`slice_C_cross_room_plumbing`** | core MD bundle **`601444`** (22 policy MD; no SQL) | **[601445](domain_02_payment_ledger_kds/slice_C_cross_room_plumbing/601445_Report_Fable_Design_Integrity_Inspection_Slice_C_Cross_Room_Plumbing.md)** | **2026-07-20** | **6 (0 / 2 / 2 / 2)** | **FABLE_DONE** |
| **`slice_D1_foundation_static_catalog`** | core MD bundle **`601446`** (24 policy MD; no SQL) | **[601449](domain_02_payment_ledger_kds/slice_D1_foundation_static_catalog/601449_Report_Fable_Design_Integrity_Inspection_Slice_D1_Foundation_Static_Catalog.md)** | **2026-07-20** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |
| **`slice_D2_static_catalog_runtime_planning`** | core MD bundle **`601447`** (35 policy MD; no SQL) | **[601450](domain_02_payment_ledger_kds/slice_D2_static_catalog_runtime_planning/601450_Report_Fable_Design_Integrity_Inspection_Slice_D2_Static_Catalog_Runtime_Planning.md)** | **2026-07-20** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |
| **`slice_D3_four_side_skeleton_data_governance`** | core MD bundle **`601448`** (21 policy MD; no SQL) | **[601451](domain_02_payment_ledger_kds/slice_D3_four_side_skeleton_data_governance/601451_Report_Fable_Design_Integrity_Inspection_Slice_D3_Four_Side_Skeleton_Data_Governance.md)** | **2026-07-20** | **6 (0 / 2 / 2 / 2)** | **FABLE_DONE** |

### slice_A finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | PKDS-F01, PKDS-F02 |
| MEDIUM | 3 | Report §9.2/§9.6 findings |
| LOW | 1 | PKDS-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 HIGH — PKDS-F01 / PKDS-F02

- **PKDS-F01:** 6월 정책 레이어와 7월 구현이 불일치한다. 실제 구현의 핵심인 capacity gate가 정책에 전혀 없으므로, 004000 정책을 현행화하거나 superseded planning으로 명시할지 Owner 결정이 필요하다.
- **PKDS-F02:** domain_01의 PAY-F02 dual confirmation pipeline은 의도된 설계가 아니라 정책 승인 없는 **undesigned drift**임이 확인됐다. 단일 confirmation entry 또는 명시적 two-pipeline contract 결정이 필요하며, `601438`의 B3-1 항목과 연결한다.

### Owner Decision Queue (4 items)

1. 004000 정책을 shipped three-path + capacity-gated release 및 실제 상태명으로 갱신하거나 "superseded planning"으로 표시한다. [PKDS-F01]
2. `confirm_payment` / `confirm_payment_from_provider`에 대해 단일 canonical entry 또는 명시적 two-pipeline contract를 결정하고 정책을 소급 정합화한다. [PKDS-F02]
3. alcohol handling의 deferred 상태를 확인하고, 향후 범위 포함 시 004013의 7개 상태를 실제 `kds_tickets` 스키마와 정합화한다. [PKDS-F04]
4. 004099/004090 번호 mismap과 stale related-folder 경로를 수정하고 22개 문서에 lifecycle metadata를 추가할지 결정한다. [PKDS-F05/F06]

### Regular Workpacket Recommendation Queue (4 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | 현행 three-path + capacity-gate에 맞는 Payment→KDS release 설계 문서 작성 및 004016/004260 supersede | PKDS-F01 |
| **WP-2** | **HIGH** | Payment-confirmation canonicalization / two-pipeline design contract | PKDS-F02 |
| WP-3 | MEDIUM | 004010 그룹 index number-mismap·stale cross-ref·lifecycle metadata 정리 | PKDS-F05/F06 |
| WP-4 | MEDIUM / FUTURE | 범위 승인 시 alcohol KDS-hold와 실제 스키마 정합화 | PKDS-F04 |

### slice_B finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | FTR-F01, FTR-F03 |
| MEDIUM | 3 | FTR-F02, FTR-F04, FTR-F05 |
| LOW | 1 | FTR-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 HIGH — FTR-F01 / FTR-F03

- **FTR-F01:** 최상위 원장 설계철학은 append-only·INSERT-only·WORM·double-entry를 요구하지만, 실제 `payment_ledger`는 단일 mutable row를 `UPDATE`하며 금액과 상태를 누적 변경한다. MVP mutable ledger를 승인된 interim으로 볼지, WORM/double-entry 목표를 일정화하거나 canonical intent에서 퇴역시킬지 결정이 필요하다.
- **FTR-F03:** Financial Trust Room은 provider-verified 단일 confirmation authority만 설계했고 manual/staff/POS confirmation을 financial truth로 인정하지 않는다. 따라서 직접 `confirm_payment` 경로는 설계의도 문서 체계에서 승인된 적이 없으며, PKDS-F02/PAY-F02와 **3중 교차확인**된다.

### 새로운 교차 패턴 — payment→KDS gate의 설계 부재

실제 결제→KDS 게이트의 핵심인 `kds_release_authorized`가 이 최상위 원장 설계문서 26개 어디에도 없다. 이는 CH-F11에서 특허 Logic도 KDS HOLD 개념을 알지 못했던 것과 동일한 클래스다. 상위 설계 문서와 실제 KDS release control 사이에 명시적 계약이 없다.

### slice_B Owner Decision Queue (5 items)

1. MVP mutable `payment_ledger`를 interim으로 승인하고 WORM/double-entry/hash-chain kernel을 일정화하거나 퇴역시킨다. [FTR-F01]
2. 단일 confirmation authority 또는 명시적 dual-pipeline contract를 결정한다. [FTR-F03]
3. canonical payment-ledger 설계에 여전법 storage prohibition(no PAN/CVV, PG-result-fields-only)을 추가한다. [FTR-F02]
4. `104xx`/`10609x` 내부 번호와 실제 `010xxx` 파일명을 정합화하고 dangling reference를 교정한다. [FTR-F04]
5. Physical-AI/Franchise-OS 확장 문서를 Financial Trust Room 밖의 적절한 도메인으로 재분류한다. [FTR-F05]

### slice_B Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | canonical payment-ledger 설계 정합화 및 `kds_release_authorized` 원장 레벨 문서화 | FTR-F01 |
| **WP-2** | **HIGH** | Payment-confirmation canonicalization / dual-pipeline design contract | FTR-F03, PKDS-F02, PAY-F02 |
| WP-3 | MEDIUM | 여전법 payment-ledger storage-prohibition contract 작성 | FTR-F02 |
| WP-4 | MEDIUM | 010400 numbering/provenance·lifecycle metadata·dangling-reference 정리 | FTR-F04/F06 |
| WP-5 | MEDIUM | future Physical-AI/Franchise-OS 문서 재분류 | FTR-F05 |

### slice_C finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | CRP-F01, CRP-F02 |
| MEDIUM | 2 | CRP-F03, CRP-F04 |
| LOW | 2 | CRP-F05, CRP-F06 |
| **Total** | **6** | **0 / 2 / 2 / 2** |

### ⚠ 최우선 HIGH — CRP-F01 / CRP-F02

- **CRP-F01:** webhook/provider-callback idempotency는 010660 §28의 설계가 구체적이고, `catchmenu_common.idempotency_keys` 인프라도 이미 존재하지만 payment-confirmation 경로에만 연결되지 않았다. 새 설계가 필요 없는 가장 실행가치 높은 항목이며, `confirm_payment_from_provider`에 idempotency key 또는 provider payload hash를 연결하는 즉시 구현 후보로 기록한다.
- **CRP-F02:** caller authorization 원칙은 존재하지만 actor/staff id 자체를 tamperable parameter로 다루지 않고, API gateway/reverse proxy/service mesh를 가정한다. 실제 direct client→Postgres `SECURITY DEFINER` RPC 구조와 맞지 않으며, JWT `sub`→`staff.id` bridge 및 Postgres-RPC 전용 보안계약이 필요하다.

### FTR-F04 / CRP-F04 정본 모호성 — 해결됨(거짓양성)

- 반복 인용된 `10141`은 5자리 내부 ID이고 실제 대상은 **`010004`**이며, 물리적 `010141`은 내부 ID `10041`인 별개의 Windows Installer 정책이다. 5자리 내부 ID와 6자리 파일명의 우연한 충돌을 파일 참조로 오인한 거짓양성이다. [FSC-F03]
- `10609`/`10609A~10609O` 계보는 유실된 것이 아니라 slice_B의 **`010451~010466`과 동일물**이다.
- `10600` self-ID는 물리적 `010611_Index`와 생성형 `010600_Readme` 사이에서 충돌한다. 실제 원인은 repo-wide rename/move를 제안했으나 적용되지 않은 `010105`이며, FTR-F04/CRP-F04의 `10141` dead-link 의심은 해결됐다. [FSC-F03/FSC-F04]

### slice_C Owner Decision Queue (5 items)

1. 기존 010660 §28 및 0004 인프라를 payment-confirmation path에 연결한다. [CRP-F01]
2. no-client-supplied actor-id 규칙, direct Postgres-RPC security model, auth-user→`staff.id` bridge를 확정한다. [CRP-F02]
3. payment-ledger amendment/history table을 추가하거나 mutable-in-place를 공식 승인하고 010601을 수정한다. [CRP-F03]
4. `10141`→`010004`, `10609x` cross-folder lineage, `10600` collision을 정리한다. [CRP-F04]
5. four-source audit의 POS-terminal/OS-runtime 포함 여부를 확정하거나 two-source audit으로 재정의한다. [CRP-F03]

### slice_C Regular Workpacket Recommendation Queue (4 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | `confirm_payment_from_provider`에 provider-callback idempotency 연결 | CRP-F01 |
| **WP-2** | **HIGH** | JWT auth-user→`staff.id` bridge + caller rule + Postgres-RPC security architecture | CRP-F02 |
| WP-3 | MEDIUM | Payment-ledger amendment/history table | CRP-F03, FTR-F01 |
| WP-4 | MEDIUM | 010600 numbering/reference·generated Readme·lifecycle metadata 정리 | CRP-F04/F05 |

### slice_D1 finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | FSC-F01, FSC-F02 |
| MEDIUM | 3 | FSC-F03, FSC-F04, FSC-F05 |
| LOW | 1 | FSC-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 HIGH — FSC-F01 / FSC-F02

- **FSC-F01:** 승인 trigger는 매우 정밀하게 정의됐지만 실제 구현은 동일 시기에 그 게이트가 명시적으로 금지한 SQL·payment·KDS·production mutation 범주로 출하됐다. 승인게이트가 모호했던 것이 아니라 실제 작업을 구속하지 못한 **무효화된 거버넌스 게이트**다.
- **FSC-F02:** 제품라인 우선순위 1–6은 만들어지지 않았고, 후순위이자 명시적 제외 대상인 payment/POS-KDS adapter와 문서에 없는 Flutter 구현이 먼저 출하됐다. 계획 문서와 실제 구현의 교집합이 거의 없다.

### CRP-F04 / FTR-F04 해소 확인 — FSC-F03

- `10141`은 5자리 내부 ID로서 `010004`를 가리키며, 물리적 `010141`은 내부 ID `10041`인 별개 문서다. 따라서 기존 dead-link 의심은 **해결됨(거짓양성)**이다.
- 이 혼동의 실제 원인은 적용되지 않은 repo-wide rename/move 계획 `010105`이며, 단순 zero-padding이 실제이지만 무관한 파일에 연결되는 구조다. [FSC-F03/FSC-F04]

### 보존 필요 항목

- **`010106` §12:** `POS_ACCEPTED_NOT_PAYMENT_CONFIRMED`, `KDS_COMPLETED_NOT_SETTLED` 등을 포함한 KDS-payment 결합 불변조건의 원본 출처다.
- **`010140` §11:** `FeatureAllowed = ProviderCapability AND TenantFeaturePlan AND StoreRuntimeConfiguration AND PolicyGate AND RuntimeFeatureFlag AND AuthorityBoundary AND EvidenceRequirement AND AuditRequirement` capability-gating formula의 원본이다.
- 원본 게이트·제품계획을 historical로 격하하기 전에 위 내용을 새 정본 문서로 추출·보존해야 한다.

### slice_D1 Owner Decision Queue (5 items)

1. 010110/010153–010157 authorization chain을 historical로 퇴역하거나 실제 미래 작업을 구속하도록 재정의한다. [FSC-F01]
2. 010146/010147/010149/010151 제품라인을 delivered system에 맞춰 재기준화하거나 superseded로 표시한다. [FSC-F02]
3. `0052`와 `0114` 중 canonical kiosk 구현을 지정하거나 둘 다 실제 kiosk client가 생길 때까지 퇴역한다. [FSC-F05]
4. 5↔6자리 번호 drift를 repo-wide로 정리하고 `010105`를 pending이 아닌 superseded로 표시한다. [FSC-F03/FSC-F04]
5. 폴더 퇴역 전에 `010106` §12와 `010140` §11의 불변조건·공식을 현행 정본문서로 승격한다. [§9.7]

### slice_D1 Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | never-operative authorization gate의 지위 및 실제 승인경로 정합화 | FSC-F01 |
| **WP-2** | **HIGH** | delivered reality 기준 product-line registry 재기준화 | FSC-F02 |
| WP-3 | MEDIUM | duplicate caller-less kiosk RPC canonicalization / retirement | FSC-F05 |
| WP-4 | MEDIUM | repo-wide numbering remediation 및 `010105` 퇴역 | FSC-F03/FSC-F04 |
| WP-5 | LOW | generated Readme 교체 및 010154 title/body mismatch 정리 | FSC-F06 |

### slice_D2 finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | SCP-F01, SCP-F02 |
| MEDIUM | 3 | SCP-F03, SCP-F04, SCP-F05 |
| LOW | 1 | SCP-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 즉시구현 후보 — SCP-F02 / PAY-F01

- **SCP-F02:** 환불 파이프라인은 `REFUND_PENDING`/`REFUND_FAILED`가 `chk_ledger_status`에 없고, audit decision에도 `REFUND_PENDING`이 없으며, `confirm_refund`가 법적으로 존재할 수 없는 pending row를 찾는 등 네 가지 정확한 실패 메커니즘을 가진다.
- PAY-F01의 기존 환불 결함을 독립적으로 재확인했다. 핵심 저비용 수정 후보는 **`chk_ledger_status`에 `REFUND_PENDING`/`REFUND_FAILED`를 추가**하는 것이며, 유형 A의 최우선 즉시실행 후보로 기록한다.

### ⚠ 반복 패턴 확정 — SCP-F01

- D1과 D2 합계 59개 문서에서 coding-authorization gate가 실제 구현과 같은 날짜에 열리지 않은 채 금지 범주의 구현이 출하됐다.
- D2의 34개 정책 문서는 모두 `CODING_DEFERRED`이고 gate는 `CODING_NOT_AUTHORIZED`로 끝난다. D1의 FSC-F01과 결합해 **거버넌스 연극**이 단일 사례가 아닌 반복 패턴으로 확정됐다.

### 보존 필요 항목 추가

- **`010226` §13:** `POS_ACCEPTED_NOT_PAYMENT_CONFIRMED`, `KDS_COMPLETED_NOT_SETTLED`, `EVIDENCE_NOT_APPROVAL`, `PGVECTOR_NOT_PROOF`를 포함하는 KDS-payment 결합 불변조건이다.
- D1의 `010106` §12와 동일 계열이므로 두 원본을 함께 새 정본문서로 승격한 뒤 해당 planning corpus를 historical로 격하한다.

### slice_D2 Owner Decision Queue (5 items)

1. `REFUND_PENDING`/`REFUND_FAILED`를 ledger/audit 제약과 정합화하고 세 refund engine 중 canonical 하나를 선택한다. [SCP-F02]
2. 010200 gate chain을 historical로 퇴역하거나 실제 승인경로와 미래 작업에 맞게 재정의한다. [SCP-F01]
3. shipped flat-key/enum vocabulary와 planned dotted/safe-state vocabulary 중 canonical을 결정한다. [SCP-F03]
4. 존재하지 않는 `09560`–`09650` dependency reference를 해소하거나 제거한다. [SCP-F04]
5. 폴더 퇴역 전에 `010226` §13을 D1의 `010106` §12와 함께 현행 정본문서로 승격한다. [§9.6]

### slice_D2 Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | Refund pipeline constraint reconciliation + engine canonicalization + caller wiring | SCP-F02 |
| **WP-2** | **HIGH** | D1+D2 governance reconciliation 및 never-opened gate 퇴역 | SCP-F01 |
| WP-3 | MEDIUM | shipped `message_catalog`/enum 기준 i18n/status catalog canonicalization | SCP-F03 |
| WP-4 | MEDIUM | repo-wide numbering/citation remediation | SCP-F04 |
| WP-5 | LOW | policy/handoff 중복제거·generated Readme 교체·header date 추가 | SCP-F05/F06 |

### slice_D3 finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | FSD-F01, FSD-F02 |
| MEDIUM | 2 | FSD-F03, FSD-F04 |
| LOW | 2 | FSD-F05, FSD-F06 |
| **Total** | **6** | **0 / 2 / 2 / 2** |

### ⚠ 최우선 HIGH — FSD-F01 / FSD-F02

- **FSD-F01:** 010554의 audit mesh가 모든 layer를 actor/staff id로 연결하면서도 신뢰 가능한 actor identity의 서버 측 유도·검증 방법을 정의하지 않는다. 010500 security suite도 identity를 다루지 않고, CRP-F02의 추상 원칙에도 실제 JWT `sub`→`staff.id` bridge가 없다. caller authorization의 설계 owner가 corpus 전체에 없다는 점이 최종 확정됐다.
- **FSD-F02:** refund vocabulary는 skeleton `REFUND_*` → room `REVERSAL_*` → shipped SQL의 invalid `REFUND_PENDING`/`REFUND_FAILED`로 drift했다. PAY-F01과 SCP-F02가 확인한 CHECK 실패의 정확한 3단계 계보가 완성됐다.

### 방법론 교훈 — commit 날짜 ≠ 작성 날짜

- D1/D2 보고서의 “구현과 같은 날짜에 authored” 표현은 과장이었다. git 날짜는 bulk-import 시점이며, 내부 ID 계보는 06-21 commit의 010300이 06-18 commit의 010400보다 상위 선행 문서임을 증명한다.
- 정확한 표현은 **같은 날짜에 first committed**다. D1/D2 gate가 `CODING_NOT_AUTHORIZED`로 끝나고 실제 구현이 금지 범주를 차지한다는 finding의 본질은 유지되지만, 동시 작성·동시성 추론은 사용하지 않는다.

### slice_D3 Owner Decision Queue (5 items)

1. session/JWT→staff actor-identity contract의 design owner를 지정한다. [FSD-F01]
2. `REVERSAL_*`/`REFUND_*`/shipped CHECK 중 canonical refund vocabulary를 결정하고 0098을 정정한다. [FSD-F02]
3. skeleton ancestor가 없는 payment→KDS late-binding gate의 design authority를 문서화한다. [FSD-F04]
4. 010350 §12의 잘못된 room numbering을 교정하거나 superseded로 표시한다. [FSD-F03]
5. `010520`을 채우거나 퇴역하고 generated Readme 및 010105 apply-state 모순을 정리한다. [FSD-F05]

### slice_D3 Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | Caller identity/session→staff contract; CRP-F02 및 601210 통합 | FSD-F01 |
| **WP-2** | **HIGH** | Refund vocabulary canonicalization + 0098 repair; SCP-F02/PAY-F01 통합 | FSD-F02 |
| WP-3 | MEDIUM | Payment→KDS late-binding gate design authority 문서화 | FSD-F04 |
| WP-4 | MEDIUM | Skeleton/room repo-wide numbering reconciliation | FSD-F03 |
| WP-5 | LOW | 010520 보완/퇴역 및 010300/010500 Readme 재생성 | FSD-F05 |

## 3.4 Domain 02 — completed synthesis

**상태:** `domain_02_payment_ledger_kds` **6/6 슬라이스 완료 — COMPLETED**.

### 누적 Finding 총계

| Severity | A | B | C | D1 | D2 | D3 | Total |
|---|---:|---:|---:|---:|---:|---:|---:|
| CRITICAL | 0 | 0 | 0 | 0 | 0 | 0 | **0** |
| HIGH | 2 | 2 | 2 | 2 | 2 | 2 | **12** |
| MEDIUM | 3 | 3 | 2 | 3 | 3 | 2 | **16** |
| LOW | 1 | 1 | 2 | 1 | 1 | 2 | **8** |
| **Total** | **6** | **6** | **6** | **6** | **6** | **6** | **36** |

### 반복 교차 슬라이스 패턴

1. **거버넌스 연극 2회:** FSC-F01/SCP-F01. D1/D2 gate는 never-opened 상태로 실제 구현을 구속하지 못했다. 단, “같은 날 작성”이 아니라 “같은 날 first committed”로 자기정정한다.
2. **5자리/6자리 번호·계보 drift 5회 누적:** FTR-F04, CRP-F04, FSC-F03, SCP-F04, FSD-F03. wrong-but-plausible collision, silently dangling foundation, stale room roadmap이 같은 계열로 확인됐다.
3. **환불 파이프라인 3중 확인:** PAY-F01 → SCP-F02 → FSD-F02. invalid CHECK literal의 runtime failure, 정책과 무관한 compensation chain, skeleton→room→SQL vocabulary drift가 하나의 계보로 연결됐다.
4. **Caller authorization 3중 확인:** caller-authorization foundation `601210`, CRP-F02, FSD-F01. 추상 원칙, 구현 bridge 부재, audit mesh의 unverified actor 전제가 독립적으로 같은 architecture gap을 확정한다.

### Domain-level closing assessment

- Domain 02에는 새 CRITICAL이 없지만 refund constraint와 caller identity는 최우선 HIGH 실행·아키텍처 과제다.
- payment→KDS late-binding gate는 구현됐으나 upper-design ancestor가 없고, 보존할 불변조건은 010106 §12/010226 §13에 분산돼 있다.
- 6개 슬라이스 검사는 처분을 실행하지 않고 Owner Decision Registry와 정규 Workpacket 후보를 위한 증거 상태로 완료한다.

## 3.5 Domain 03 — Fable slice inspection progress

| Slice | Input | Fable Output | Review Date | Findings (C/H/M/L) | Status |
|---|---|---|---|---|---|
| **`slice_A_entrance_waiting_policy`** | core MD bundle **`601452`** (4 policy MD) + SQL concat (`0150`) | **[601454](domain_03_waiting_call_no_show/slice_A_entrance_waiting_policy/601454_Report_Fable_Design_Integrity_Inspection_Slice_A_Entrance_Waiting_Policy.md)** | **2026-07-20** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |
| **`slice_B_store_legal_boundary`** | core MD bundle **`601453`** (2 policy MD) + SQL concat (`0162`, `0048`) | **[601455](domain_03_waiting_call_no_show/slice_B_store_legal_boundary/601455_Report_Fable_Design_Integrity_Inspection_Slice_B_Store_Legal_Boundary.md)** | **2026-07-20** | **6 (0 / 2 / 3 / 1)** | **FABLE_DONE** |

### slice_A finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | EWP-F01, EWP-F02 |
| MEDIUM | 3 | EWP-F03, EWP-F04, EWP-F05 |
| LOW | 1 | EWP-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 HIGH — EWP-F02 / EWP-F01

- **EWP-F02 — 즉시실행:** 006510 §8/§12는 native app이 별도 waiting model을 만들지 말고 Store Runtime truth를 공유하도록 명시하지만, `waiting_status_screen.dart`는 SharedPreferences만 읽고 RPC를 호출하지 않는다. 이미 존재하는 `get_waiting_status`를 연결하면 되며 WAIT-F09와 통합한다.
- **EWP-F01 — 노쇼 모델 최종 확정:** 006410의 single-stage, 006520의 session-level staff-confirmed grace, 0161의 ticket-level automatic grace가 서로 다르다. WAIT-F03의 Human 결정을 유지하더라도 두 상위 문서를 최종 canonical model에 맞춰 정합화해야 한다.

### 600680 진행 경고 — EWP-F03

006530 §10에는 preorder→table linkage의 order/session allowed-state whitelist가 없고, 006410 lifecycle에는 `ORDER_CONFIRMED`도 없다. 따라서 600680은 `create_pre_order`/`bind_table_to_session` 상태게이트를 정정하면서 참조할 상위 계약 없이 진행되고 있었다. **allowed-state whitelist를 Owner 입력으로 600680에 전달해야 한다.**

### 특기사항 — 건강한 정책 레이어

- 네 정책은 2026-07-10 작성되고 구현은 0150(07-11), 0161(07-16)에 이어져, 지금까지 검사한 레이어 중 유일하게 문서가 실제 구현보다 먼저 작성된 design-then-build 사례다.
- 선언된 baseline dependency 5개가 모두 실제 파일로 해소된다. Finding은 존재하지만 작성순서와 인용 정합성은 가장 건강하다.

### slice_A Owner Decision Queue (5 items)

1. session-level staff-confirmed grace와 ticket-level automatic grace 중 canonical no-show model을 확정하고 006410/006520/0161을 정합화한다. [EWP-F01]
2. preorder→table allowed-state whitelist를 정의해 600680 입력으로 제공한다. [EWP-F03]
3. 네 customer-facing status table 중 canonical vocabulary를 선택한다. [EWP-F05]
4. waiting evidence 21-event 요구의 범위와 SYSTEM transition actor attribution을 확정한다. [EWP-F04]
5. `get_waiting_status` client wiring을 승인한다. [EWP-F02]

### slice_A Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | No-show model reconciliation; WAIT-F03 통합 | EWP-F01 |
| **WP-2** | **HIGH** | Waiting-status client wiring; WAIT-F09 통합 | EWP-F02 |
| WP-3 | MEDIUM | Preorder→table allowed-state contract; 600680 입력 | EWP-F03 |
| WP-4 | MEDIUM | Waiting evidence coverage + SYSTEM actor attribution | EWP-F04 |
| WP-5 | MEDIUM | Customer-facing status tables canonicalization | EWP-F05 |

### slice_B finding summary

| Severity | Count | Primary findings |
|---|---:|---|
| CRITICAL | 0 | — |
| HIGH | 2 | SLB-F01, SLB-F02 |
| MEDIUM | 3 | SLB-F03, SLB-F04, SLB-F05 |
| LOW | 1 | SLB-F06 |
| **Total** | **6** | **0 / 2 / 3 / 1** |

### ⚠ 최우선 HIGH — SLB-F01 / SLB-F02

- **SLB-F01 — 환불 진단 재정정:** `REFUND_PENDING`은 적어도 10개 설계문서, `REFUND_FAILED`는 6개 설계문서에 존재한다. 구현 0098은 지배적인 표준어휘를 따랐고 진짜 이상치는 이를 허용하지 않은 `chk_ledger_status`와 별도 `REVERSAL_*` rename이다. 최저비용 해법은 CHECK 제약을 설계 corpus의 상태로 확장하고 0098을 유지하는 것이다. FSD-F02의 과도한 일반화를 대체한다.
- **SLB-F02 — seating→table link 부재:** `seat_waiting_customer`는 `dining_tables.current_session_id`를 쓰지 않고 유일한 writer는 `bind_table_to_session`이다. waiting-origin seating 후 네 occupancy guard가 모두 fail-open하며, WAIT-F01 때문에 preorder session은 linker 호출도 거부된다. 600680 완료 후 table linkage fix를 순서화해야 한다.

### 노쇼 모델 네 번째 등장 — SLB-F05

010802 legal SOP의 auto-cancel-after-grace는 구현 0161과 방향이 일치하지만, 006520의 staff-confirmed model과 충돌한다. 기존 006410/006520/0161에 legal SOP가 추가되어 네 모델이 됐으며, WAIT-F03/EWP-F01 통합과제에 SLB-F05를 포함한다.

### 자기정정 및 검증방법 교훈

Opus는 전날 FSD-F02에서 “`REFUND_PENDING`이 설계문서 어디에도 없다”고 과도하게 일반화했지만, 독립적인 legal-boundary slice에서 010802 §4를 앵커로 다시 확인해 같은 세션 안에서 오류를 스스로 정정했다. **슬라이스별 독립 검증과 이전 결론에 대한 앵커링 방지 원칙이 동일 AI 세션에서도 실제로 작동한 사례**로 기록한다.

### slice_B Owner Decision Queue (5 items)

1. `chk_ledger_status`를 dominant refund vocabulary로 확장할지, 0098과 corpus를 기존 8값으로 재작성할지 결정한다. [SLB-F01]
2. waiting seating의 table link 위치를 결정하고 WAIT-F01/600680 이후 실행한다. [SLB-F02]
3. waiting preorder limited-quantity MVP를 구현하거나 quantity control 부재를 공식 승인한다. [SLB-F03]
4. deposit-bearing no-show 전에 refund path와 legal evidence packet을 요구할지 결정하고 missing 10726 SOP를 작성한다. [SLB-F04]
5. legal auto-cancel과 operational staff-confirmed 모델 중 canonical no-show model을 확정한다. [SLB-F05]

### slice_B Regular Workpacket Recommendation Queue (5 items — Owner-gated candidates)

| ID | Priority | Title | Finding |
|---|---|---|---|
| **WP-1** | **HIGH** | Refund-state CHECK reconciliation; SCP-F02/FSD-F02 정정 | SLB-F01 |
| **WP-2** | **HIGH** | Seating→table linkage fix; 600680 이후 | SLB-F02 |
| WP-3 | MEDIUM | Waiting-preorder limited-quantity MVP | SLB-F03 |
| WP-4 | MEDIUM | No-show notice/evidence packet + 10726 | SLB-F04 |
| WP-5 | MEDIUM | Four-model canonical no-show ruling | SLB-F05 |

## 3.6 Domain 03 — completed synthesis

**상태:** `domain_03_waiting_call_no_show` **2/2 슬라이스 완료 — COMPLETED**.

### 누적 Finding 총계

| Severity | Slice A | Slice B | Total |
|---|---:|---:|---:|
| CRITICAL | 0 | 0 | **0** |
| HIGH | 2 | 2 | **4** |
| MEDIUM | 3 | 3 | **6** |
| LOW | 1 | 1 | **2** |
| **Total** | **6** | **6** | **12** |

### 반복 교차 슬라이스 패턴

1. **No-show canonical ambiguity:** EWP-F01/WAIT-F03에 SLB-F05가 합류해 operational/legal/implementation의 네 모델이 확인됐다.
2. **Preorder→table contract/linkage gap:** EWP-F03은 allowed-state 상위계약 부재를, SLB-F02는 실제 physical table link 부재와 occupancy guard fail-open을 확인했다. 두 작업 모두 600680과 순서 의존성이 있다.
3. **Refund diagnosis correction:** SLB-F01이 PAY-F01/SCP-F02/FSD-F02 계보를 재검증해 구현이 dominant vocabulary를 따랐고 schema CHECK가 outlier임을 확정했다.
4. **Policy-to-runtime contrast:** Slice A는 구현보다 먼저 작성되고 dependency가 깨끗한 건강한 정책층이지만 no-show 내부모순이 있고, Slice B의 legal SOP는 구현 방향과 더 가깝지만 evidence/limited-quantity/table-link contract가 미구현이다.

### Domain-level closing assessment

- Domain 03의 최우선 실행 순서는 refund CHECK reconciliation, 600680 완료, seating→table linkage, waiting-status client wiring이다.
- Plain waiting no-show는 refund pipeline에 의존하지 않지만 deposit-bearing no-show와 reversal은 broken refund/evidence path에 노출된다.
- 두 슬라이스 검사는 구현을 변경하지 않고 Owner Decision Registry와 정규 Workpacket 후보를 위한 증거 상태로 완료한다.

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
- 2026-07-19: **domain_02_payment_ledger_kds slice_A_kitchen_release_gate** inspection complete — Opus 4.8 reviewer output saved as `601440` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). PKDS-F01/PKDS-F02 flagged as the two highest-priority findings; Owner Decision Queue ×4 and Workpacket candidates WP-1–WP-4 recorded in §3.3. Domain 02 remains in progress.
- 2026-07-19: **domain_02_payment_ledger_kds slice_B_financial_trust_room** inspection complete — Opus 4.8 reviewer output saved as `601442` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). FTR-F01/FTR-F03 flagged as the two highest-priority findings; the missing top-level `kds_release_authorized` design contract recorded as a CH-F11-class cross-pattern; Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.3. Domain 02 remains in progress.
- 2026-07-20: **domain_02_payment_ledger_kds slice_C_cross_room_plumbing** inspection complete — Opus 4.8 reviewer output saved as `601445` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 2, LOW 2). CRP-F01 flagged as the highest-value ready-to-implement item; CRP-F02 recorded as a policy+implementation+architecture mismatch; FTR-F04 provenance resolved to `10141→010004` and `10609x→010451–010466`. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-4 recorded in §3.3. Domain 02 remains in progress.
- 2026-07-20: **domain_02_payment_ledger_kds slice_D1_foundation_static_catalog** inspection complete — Opus 4.8 reviewer output saved verbatim as `601449` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). FSC-F01/FSC-F02 flagged as the two highest-priority findings; CRP-F04/FTR-F04 `10141` dead-link suspicion closed as a false positive by FSC-F03, with unapplied `010105` identified as the numbering-drift source. `010106` §12 and `010140` §11 recorded as preserve-before-retire content. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.3. Domain 02 remains in progress.
- 2026-07-20: **domain_02_payment_ledger_kds slice_D2_static_catalog_runtime_planning** inspection complete — Opus 4.8 reviewer output saved verbatim as `601450` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). SCP-F02/PAY-F01 refund constraint failure promoted to the highest-priority type-A immediate implementation candidate; SCP-F01 confirmed the D1/D2 59-document governance-theatre pattern; `010226` §13 recorded alongside `010106` §12 as preserve-before-retire content. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.3. Domain 02 remains in progress.
- 2026-07-20: **domain_02_payment_ledger_kds slice_D3_four_side_skeleton_data_governance** inspection complete — Opus 4.8 reviewer output saved verbatim as `601451` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 2, LOW 2). FSD-F01 closed the caller-authorization ownership gap across 010500/010600/implementation; FSD-F02 completed the three-layer refund vocabulary lineage. Opus's commit-date≠authoring-date self-correction was retained as a methodology lesson. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.3.
- 2026-07-20: **domain_02_payment_ledger_kds COMPLETED — 6/6 slices**. Cumulative findings: 36 (CRITICAL 0, HIGH 12, MEDIUM 16, LOW 8). Repeated governance-theatre, numbering drift, refund-pipeline, and caller-authorization patterns consolidated in §3.4 and `601443`.
- 2026-07-20: **domain_03_waiting_call_no_show slice_A_entrance_waiting_policy** inspection complete — Opus 4.8 reviewer output saved verbatim as `601454` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). EWP-F02/WAIT-F09 recorded as an immediate client-wiring candidate; EWP-F01/WAIT-F03 recorded as a three-model no-show reconciliation; EWP-F03 added as an allowed-state-contract warning to in-progress 600680. This is the first inspected layer verified to precede its implementation and to have clean baseline dependency resolution. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.5. Domain 03 remains in progress.
- 2026-07-20: **domain_03_waiting_call_no_show slice_B_store_legal_boundary** inspection complete — Opus 4.8 reviewer output saved verbatim as `601455` (6 findings: CRITICAL 0, HIGH 2, MEDIUM 3, LOW 1). SLB-F01 corrected FSD-F02's refund-vocabulary overgeneralization and identified `chk_ledger_status` as the outlier; SLB-F02 exposed the missing seating→table link and four fail-open occupancy guards; SLB-F05 extended no-show ambiguity to four models. The within-session self-correction was retained as an independent-verification/anti-anchoring lesson. Owner Decision Queue ×5 and Workpacket candidates WP-1–WP-5 recorded in §3.5.
- 2026-07-20: **domain_03_waiting_call_no_show COMPLETED — 2/2 slices**. Cumulative findings: 12 (CRITICAL 0, HIGH 4, MEDIUM 6, LOW 2). No-show, preorder/table linkage, refund-diagnosis correction, and policy-to-runtime patterns consolidated in §3.6 and `601443`.
