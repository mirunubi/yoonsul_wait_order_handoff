# 600922_Logic_Workpacket_Renumbering_To_Domain_Ranges.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`workpacket_renumbering_to_domain_ranges`

## §0 번호 충돌 — 확인 및 해소 (Human 결정 1, 옵션 b 채택, 2026-07-14, 재논의 금지)

### §0.1 원 충돌 (역사 기록, 이미 해소됨)

앞선 검토에서 시나리오 B(`600530`→`600520`)를 그대로 실행하면 `600520`이라는 워크패킷 식별 번호가 `600400_kds_did_implementation/600520_domain_folder_reorganization/`(이미 Stage 6 ACCEPT 완료)과 `600500_payment_confirmation/600520_mark_payment_uncertain_overload_ambiguity/`(실행 후) 양쪽에서 동시에 쓰이게 된다는 충돌이 확인됐다 — `600521`–`600524`(그룹 9 신규 번호)가 `600520_domain_folder_reorganization/`의 기존 `600521`–`600524`와 정확히 같은 6자리 번호를 갖게 되는 것이 핵심 문제였다.

### §0.2 해소 — 옵션 b 채택

**Human 결정 1(2026-07-14, 재논의 금지)**: 옵션 (b) 채택 — `600530_mark_payment_uncertain_overload_ambiguity`의 목표 번호를 `600520`이 아니라 **`600540`**으로 재조정한다. `600520_domain_folder_reorganization/`(이미 Stage 6 ACCEPT 완료)은 전혀 건드리지 않는다.

**재확인(이번 턴, 실행 전 필수 검증)**: `600540`이 `600500_payment_confirmation/` 산하에서 실제로 빈 번호인지 직접 확인했다.

- 디스크: `ls 600000_implementation_lifecycle/600500_payment_confirmation/` → `600480_...`/`600500_Readme_...`/`600502_NavigationMap_...`/`600530_...`만 존재, `600540`으로 시작하는 파일/폴더 전무.
- 프로젝트 전체: `find . -iname "600540*"` → 0건.
- `000005_Index_Document_Number.md`/`000007_Map_Full_Directory.md`: `600540` 문자열 0건.

**`600540`은 확인된 빈 슬롯이다.** 이 재조정으로 §0.1의 충돌은 완전히 해소된다 — `600540`은 `600400_kds_did_implementation/600520_domain_folder_reorganization/`과도, 다른 어떤 기존 워크패킷과도 겹치지 않는다.

## §1 전체 rename 매핑표 (53개 파일 — 그룹 1-8 46개 + 그룹 9 7개)

### 1-1. 폴더 rename (9개)

| # | 기존 경로 | 신규 경로 |
|---|---|---|
| 1 | `600500_payment_confirmation/600480_confirm_payment_from_provider_overload_ambiguity/` | `600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/` |
| 2 | `600600_waiting_order_session/600460_takeout_session_type_fix/` | `600600_waiting_order_session/600610_takeout_session_type_fix/` |
| 3 | `600600_waiting_order_session/600490_customer_handoff_contract_reconciliation/` | `600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/` |
| 4 | `600700_takeout_pickup_order/600450_place_takeout_order_unassigned_record_fix/` | `600700_takeout_pickup_order/600710_place_takeout_order_unassigned_record_fix/` |
| 5 | `600700_takeout_pickup_order/600470_orders_pickup_ready_timing_columns_migration/` | `600700_takeout_pickup_order/600720_orders_pickup_ready_timing_columns_migration/` |
| 6 | `600800_did_implementation/600330_kds_did_event_reactive_implementation/` | `600800_did_implementation/600810_kds_did_event_reactive_implementation/` |
| 7 | `600800_did_implementation/600510_did_display_state_overload_and_legacy_defect/` | `600800_did_implementation/600820_did_display_state_overload_and_legacy_defect/` |
| 8 | `600900_cross_domain_reconciliation/600430_stale_column_reconciliation_batch/` | `600900_cross_domain_reconciliation/600910_stale_column_reconciliation_batch/` |
| 9 | `600500_payment_confirmation/600530_mark_payment_uncertain_overload_ambiguity/` | `600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/` |

### 1-2. 파일 rename (53개, 폴더 rename 후 폴더 내부 기준)

**그룹 1 (payment, `confirm_payment_from_provider`, offset +30)**

| 기존 | 신규 |
|---|---|
| `600481_Overview.md` | `600511_Overview.md` |
| `600482_Logic.md` | `600512_Logic.md` |
| `600483_TestPlan.md` | `600513_TestPlan.md` |
| `600484_ChangeContract.md` | `600514_ChangeContract.md` |
| `600485_Module.md` | `600515_Module.md` |
| `600486_Verification.md` | `600516_Verification.md` |
| `600487_Audit.md` | `600517_Audit.md` |

**그룹 2 (waiting, `takeout_session_type_fix`, offset +150)**

| 기존 | 신규 |
|---|---|
| `600461_Overview.md` | `600611_Overview.md` |
| `600462_Logic.md` | `600612_Logic.md` |
| `600463_TestPlan.md` | `600613_TestPlan.md` |
| `600464_ChangeContract.md` | `600614_ChangeContract.md` |
| `600465_Module.md` | `600615_Module.md` |
| `600466_Verification.md` | `600616_Verification.md` |
| `600467_Audit.md` | `600617_Audit.md` |

**그룹 3 (waiting, `customer_handoff_contract_reconciliation`, offset +130)**

| 기존 | 신규 |
|---|---|
| `600491_Overview.md` | `600621_Overview.md` |
| `600492_Logic.md` | `600622_Logic.md` |
| `600493_TestPlan.md` | `600623_TestPlan.md` |
| `600494_ChangeContract.md` | `600624_ChangeContract.md` |
| `600495_Module.md` | `600625_Module.md` |
| `600496_Verification.md` | `600626_Verification.md` |
| `600497_Audit.md` | `600627_Audit.md` |

**그룹 4 (takeout, `place_takeout_order_unassigned_record_fix`, offset +260)**

| 기존 | 신규 |
|---|---|
| `600451_Overview.md` | `600711_Overview.md` |
| `600452_Logic.md` | `600712_Logic.md` |
| `600453_TestPlan.md` | `600713_TestPlan.md` |
| `600454_ChangeContract.md` | `600714_ChangeContract.md` |
| `600455_Module.md` | `600715_Module.md` |
| `600456_Verification.md` | `600716_Verification.md` |
| `600457_Audit.md` | `600717_Audit.md` |

**그룹 5 (takeout, `orders_pickup_ready_timing_columns_migration`, offset +250)**

| 기존 | 신규 |
|---|---|
| `600471_Overview.md` | `600721_Overview.md` |
| `600472_Logic.md` | `600722_Logic.md` |
| `600473_TestPlan.md` | `600723_TestPlan.md` |
| `600474_ChangeContract.md` | `600724_ChangeContract.md` |
| `600475_Module.md` | `600725_Module.md` |
| `600476_Verification.md` | `600726_Verification.md` |
| `600477_Audit.md` | `600727_Audit.md` |

**그룹 6 (DID, `600330`, offset +480)**: 파일 0개 — 폴더 rename만.

**그룹 7 (DID, `600510` 워크패킷, offset +310, 파일명에 이미 제목 포함, 2026-07-14 생성)**

| 기존 | 신규 |
|---|---|
| `600511_Overview_Did_Display_State_Overload.md` | `600821_Overview_Did_Display_State_Overload.md` |
| `600512_Logic_Did_Display_State_Overload.md` | `600822_Logic_Did_Display_State_Overload.md` |
| `600513_TestPlan_Did_Display_State_Overload.md` | `600823_TestPlan_Did_Display_State_Overload.md` |
| `600514_ChangeContract_Did_Display_State_Overload.md` | `600824_ChangeContract_Did_Display_State_Overload.md` |

**그룹 8 (cross-domain, `stale_column_reconciliation_batch`, offset +480)**

| 기존 | 신규 |
|---|---|
| `600431_Overview.md` | `600911_Overview.md` |
| `600432_Logic.md` | `600912_Logic.md` |
| `600433_TestPlan.md` | `600913_TestPlan.md` |
| `600434_ChangeContract.md` | `600914_ChangeContract.md` |
| `600435_Module.md` | `600915_Module.md` |
| `600436_Verification.md` | `600916_Verification.md` |
| `600437_Audit.md` | `600917_Audit.md` |
| `.gitkeep` | (rename 불필요, 폴더 이동에 자동 포함) |

**그룹 9 (payment, `mark_payment_uncertain_overload_ambiguity`, offset +10 — 정정: 이전 검토 시점엔 4개 파일·Stage 2·미완성이었으나, 그 사이 실제로 Stage 4/5/6까지 완료되어 현재 7개 파일 전부 실존)**

| 기존 | 신규 |
|---|---|
| `600531_Overview_Mark_Payment_Uncertain_Overload.md` | `600541_Overview_Mark_Payment_Uncertain_Overload.md` |
| `600532_Logic_Mark_Payment_Uncertain_Overload.md` | `600542_Logic_Mark_Payment_Uncertain_Overload.md` |
| `600533_TestPlan_Mark_Payment_Uncertain_Overload.md` | `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` |
| `600534_ChangeContract_Mark_Payment_Uncertain_Overload.md` | `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` |
| `600535_Module.md` | `600545_Module.md` |
| `600536_Verification.md` | `600546_Verification.md` |
| `600537_Audit.md` | `600547_Audit.md` |

**합계(최종, Human 결정 1 개정 반영)**: 7×7(그룹 1-5, 8, 9) + 0(그룹 6) + 4(그룹 7) = **53개 파일**(+.gitkeep 1개는 번호 없는 파일이라 표에서 제외) — Human이 제시한 숫자와 일치. 폴더 rename 9개는 그대로 유지(대상 번호만 `600520`→`600540`으로 변경).

### 1-3. `600510`(DID) — 번호만 변경, 내용/구현 상태는 "미완성" 그대로, 색인 백필 계속 제외

명시적으로 확정: 그룹 7(`600510`→`600820` 계열)은 **파일명·경로만** 바뀐다. 문서 내용·워크패킷의 실제 진행 단계(Stage 2, Human Approval 대기)는 이번 변경으로 전혀 달라지지 않는다. `000005`/`000007`에 이 워크패킷의 색인이 없는 것도 그대로 유지 — Stage 6 ACCEPT 도달 전까지 색인 백필은 여전히 보류(`600522_Logic.md` §1.1.1/`600524_ChangeContract.md` §6.4 원칙 재확인).

### 1-4. `600530`(→`600540`) — DID와 다름: 이미 Stage 6 ACCEPT 완료, 색인 백필도 이번에 포함

`600510`(DID)과 달리, 이 renumbering 워크패킷의 앞선 검토 시점 이후 `mark_payment_uncertain_overload_ambiguity`는 실제로 Stage 4(구현, `0154`)/Stage 5(§39/§43 삼중검증)/Stage 6(ACCEPT, `600537_Audit.md`)까지 전부 완료되고 `600401_ChangeHistory.md`/`600502_NavigationMap_Payment_Confirmation.md`에 이미 색인/등재됐다. 따라서:

- 그룹 9의 7개 파일은 **rename 후 `000005`/`000007`에 신규 백필 대상으로 포함된다**(DID처럼 미색인 상태로 남지 않는다) — §4에서 처리.
- `600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md`에 이미 존재하는 `600530`/`600531`–`600537` 언급은 **기존 색인 엔트리 갱신**(신규 추가가 아니라 이미 있는 행의 번호 텍스트 치환)으로 처리한다 — §4에서 명시.

## §2 확정 — `600530` → `600540` (Human 결정 1, 옵션 b, 2026-07-14, 재논의 금지)

이전 검토(시나리오 B, `600530`→`600520`)는 §0.1의 충돌 때문에 실행 보류됐다. Human 결정 1로 **옵션 (b)** 채택 — 목표 번호를 `600520`이 아닌 `600540`(`600500_payment_confirmation/` 도메인의 확인된 빈 슬롯, §0.2)으로 재조정한다. `600520_domain_folder_reorganization/`은 전혀 건드리지 않는다 — 이 결정으로 §0.1의 충돌은 발생하지 않는다.

**아울러 이번 재검토로 전제가 갱신됐다**: 이전 문서 작성 시점엔 `600530`이 Stage 2(구현 전, 4개 파일)였으나, 그 사이 실제로 Stage 6 ACCEPT까지 완료(7개 파일)됐다 — §1-4/§4에 반영.

## §3 도메인 루트 파일(Readme/NavigationMap)은 번호가 바뀌지 않음 — 명시적 경계

`600500_Readme_Payment_Confirmation.md`/`600502_NavigationMap_Payment_Confirmation.md`(및 `600600`/`600602`, `600700`/`600702`, `600800`/`600802`, `600900`/`600902`)는 도메인 자체의 고정 번호이며, 이번 워크패킷-레벨 재조정 대상이 아니다 — **본문 안의 워크패킷 번호 언급만** 갱신된다.

## §4 외부 참조 갱신 대상 (53개 이동 파일 자신 제외)

| 파일 | 처리 방법 |
|---|---|
| `000005_Index_Document_Number.md` | 그룹 1-8(비-DID) 42개 엔트리의 경로/번호 텍스트 치환 **+ 그룹 9 7개 신규 백필**(§1-4 — `600530` 계열은 이미 완료 상태이므로 DID와 달리 이번에 처음 색인). |
| `000007_Map_Full_Directory.md` | 동일(트리 노드 경로 텍스트 치환 42개 + 그룹 9 7개 신규 백필). |
| `000053_Matrix_Domain_To_Artifact_Traceability.md` | 본문 내 `600480`/`600490`/`600470`/`600430` 등 워크패킷 번호 언급 전체 치환. |
| `000054_Assessment_...md` | `600460`대/`600490`대 언급 치환. |
| `000002_Naming_Rules.md` | `600431`만 `600911`로 치환(`600441`/`600417`은 유지). |
| `000701_Guide_...md` | §37의 `600430` → `600910`, §41.3의 `600450` → `600710`, §44.3의 `600496` → `600626`. |
| `600401_ChangeHistory.md` | 그룹 1-8 각 워크패킷의 완료 기록 행 전체 치환 **+ `mark_payment_uncertain_overload_ambiguity` 행(이미 존재, 이번 턴 직전에 추가됨)의 `600530`/`600531`–`600537` 언급을 `600540`/`600541`–`600547`로 치환**(§1-4). |
| `600402_NavigationMap.md` | `600440` 행 안의 `600430` bare 언급 → `600910`. |
| `600403_DecisionLog.md` | Decision 2(d)의 `600510_did_display_state_overload_and_legacy_defect` → `600820_...`. |
| `600404_PlaceTakeoutOrder_Defect_Roadmap.md` | `600460`대/`600470`대 언급 치환. |
| `600441_Overview.md`/`600442_Logic.md`/`600446_Verification.md` | bare 언급(`600430`/`600432`/`600436`) 치환 — 파일 자체는 이동하지 않음. |
| `600521`–`600527`(7개, `600520_domain_folder_reorganization/` 자신, **이동 안 함**) | **확정(Human 결정 2, 이전 턴)** — 본문 안 옛 번호 언급(`600480`/`600460`/`600490`/`600450`/`600470`/`600330`/`600510`/`600430`) 전부 신규 번호로 갱신. 폴더/파일 자신의 번호는 이 결정에 포함되지 않음(변경 없음 — §0.2 해소로 이제 이 폴더는 어떤 충돌과도 무관). |
| `600541`–`600547`(그룹 9, 이동 대상) | 파일명 자체가 rename 대상(§1 그룹 9) — 내용 중 `600480` 언급(`600544`, 옛 `600534`) → `600510`로 치환. |
| **`600545_Module.md`/`600546_Verification.md`/`600547_Audit.md`(옛 `600535`/`600536`/`600537`) 자신의 본문 안 `600480`/`600481` 언급** — 신규 발견, 이번 개정에서 추가 | 이 3개 파일은 `600920` 워크패킷의 최초 설계(`600921`/`600922` 초안) 시점엔 아직 존재하지 않았기 때문에 원래 외부 참조 조사에서 누락됐다 — 지금 이 3개 파일이 실존하므로 명시적으로 추가한다. 직접 재확인한 정확한 건수(Codex가 보고한 건수와 다름, §4.1 참고): `600545_Module.md`(옛 `600535`) — `600480` 1건("confirm_payment_from_provider precedent, `600480`"). `600546_Verification.md`(옛 `600536`) — `confirm_payment_from_provider` 3건(전부 boundary 체크 문맥, `600480` 숫자 자체는 등장하지 않음 — 함수명만 언급, 치환 대상 아님). `600547_Audit.md`(옛 `600537`) — `600480` 1건 + `600481_Overview.md` 1건(파일명 직접 인용, Finding 3/Open Item (d)). 이 파일들은 **그룹 1(confirm_payment_from_provider, `600480`→`600510`)의 rename과 별개로, 그룹 9 자신의 이동과 동시에 자기 본문 안의 다른 워크패킷 번호도 갱신해야 하는 이중 성격**을 갖는다 — "이동 대상"이면서 "외부 참조 갱신 대상"이기도 하다. |
| `600500_Readme_Payment_Confirmation.md`/**`600502_NavigationMap_Payment_Confirmation.md`** | `600480` bare 언급(있다면) 치환 **+ 이미 존재하는 `600530_mark_payment_uncertain_overload_ambiguity/` 행 전체(워크패킷명, 7개 파일 경로 나열)를 `600540_.../600541`–`600547`로 치환**(§1-4 — 5쌍 중 유일하게 "이미 실제 행이 존재하는" 갱신 대상). |
| `600600`/`600602`, `600700`/`600702`, `600800`/`600802`, `600900`/`600902` | 소속 워크패킷 번호 텍스트 치환(§3, 기존 행 번호만 갱신, 신규 행 없음). |

### §4.1 그룹 9 자기참조 재확인 — Codex 보고 건수를 그대로 받아쓰지 않고 직접 재검증 (§44.2 적용)

Codex가 "`600535_Module.md`(600480 2건), `600536_Verification.md`(confirm_payment_from_provider 6건), `600537_Audit.md`(600480, 600481_Overview.md 언급)"를 보고했다. 방향(이 3개 파일에 다른 워크패킷 번호 언급이 실제로 존재한다는 것)은 맞았으나, **건수는 직접 재검증한 결과 정확하지 않았다** — `grep -o | wc -l`로 정확히 재확인:

| 파일 | Codex 보고 | 직접 재확인 결과 |
|---|---|---|
| `600535_Module.md` | `600480` 2건 | `600480` **1건** |
| `600536_Verification.md` | `confirm_payment_from_provider` 6건 | `confirm_payment_from_provider` **3건** |
| `600537_Audit.md` | `600480`, `600481_Overview.md` 언급 | `600480` **1건** + `600481` **1건**(정확히 일치) |

건수 자체는 이 워크패킷의 실행 계획(§4 표)에 영향을 주지 않는다 — "치환 대상 존재 여부"만 중요하고, 정확한 위치는 Stage 4 실행 시 `grep`으로 다시 확인하기 때문이다. 다만 다수(이번엔 Codex 하나뿐이지만)의 보고를 실제 근거 대조 없이 그대로 옮겨 적지 않는다는 `000701` §44.2 원칙을 재확인하는 차원에서 기록한다.

## §5 확정 — `600521`–`600527`(600520 워크패킷) 내용 갱신 (Human 결정 2, 2026-07-14, 재논의 금지 — 이번 턴 §0.2 해소로 재확인)

**이전 절충안(역사 기록 보존 + 크로스레퍼런스 각주) 기각.** `600521`–`600527`(`600520_domain_folder_reorganization/`) 본문 안의 옛 번호 언급을 지금 신규 번호로 전부 갱신한다 — 예: `600524_ChangeContract_...md` §1의 "`600480`이 `600500_payment_confirmation/`으로 이동한다"는 "`600510`이 `600500_payment_confirmation/`으로 이동한다"로 갱신.

**§0.2로 이 결정의 실행 조건이 단순해졌다**: 이전엔 "내용은 갱신하되 폴더/번호 자신은 그대로 둔다"는 구분이 §0.1의 미해소 충돌과 얽혀 있었으나, 옵션 (b) 채택으로 `600520_domain_folder_reorganization/`은 애초에 어떤 번호 충돌과도 무관해졌다 — 이 결정은 이제 순수하게 "완료된 워크패킷 문서의 상호참조 최신화" 작업일 뿐이다.

## §6 실행 순서 및 원자성 확보 방안

### 6.1 순서 (4단계, 각 단계 후 체크포인트)

1. **폴더 rename 9개** (`git mv`) — §1-1의 9개 전부, 순서 무관하게 안전(서로 다른 도메인 부모 폴더).
2. **폴더 내부 파일 rename 53개** (`git mv`) — 46개(그룹 1-8) + 7개(그룹 9, `600531`–`600537`→`600541`–`600547`). 1단계 완료 후 진행.
3. **파일 내용 치환** — 53개 이동 파일 자신의 본문에 있는 자기/형제 참조 + `600521`–`600527`(600520 워크패킷 자신, §5) + §4의 나머지 외부 참조 파일들(**`600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md`의 기존 `600530` 행 갱신 포함**). 치환은 rename 완료 후에 수행.
4. **색인/NavigationMap 갱신** — `000005`/`000007`(그룹 1-8의 42개 기존 엔트리 치환 + 그룹 9의 7개 신규 백필), `600402`, 나머지 도메인 NavigationMap 4개(`600600`/`600700`/`600800`/`600900` 계열, 신규 행 없이 번호만 치환). 3단계와 같은 이유로 마지막.

### 6.2 원자성

이동 파일 수가 53개로 늘었고, `600502_NavigationMap_Payment_Confirmation.md`/`600401_ChangeHistory.md`는 이번엔 "번호만 치환"이 아니라 "이미 존재하는 완료된 워크패킷의 색인 행 자체를 옮기는" 작업이라 더 세심한 확인이 필요하다 — Stage 5 검증에서 이 두 파일에 대해서는 rename 전/후 행 내용이 (번호를 제외하고) byte-identical한지 별도 diff 확인을 추가한다. 나머지는 이전과 동일하게 `\b` 없는 grep 전수 재확인(`600921_Overview.md` §4의 정정된 방법론)을 Stage 5 필수 항목으로 유지한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`(§42/§43/§44)
- `600921_Overview_Workpacket_Renumbering_To_Domain_Ranges.md`(같은 워크패킷의 Overview)

### Full Rules Required

- `600522_Logic_Domain_Folder_Reorganization.md`(직전 선례, bare-name 참조 전제가 이번엔 깨진다는 대비점)
- `600537_Audit.md`(그룹 9가 이제 완료 상태임을 확정하는 근거)
- §1의 53개 파일 Before/After 표 자체.

### Domain Indexes

- `000005`/`000007`, 5개 도메인 NavigationMap — 특히 `600502_NavigationMap_Payment_Confirmation.md`는 이미 실제 행이 존재하는 유일한 갱신 대상.

### Excluded Rule Families

- `sql/migrations/*.sql` — 문서 번호 재조정과 무관.
- `600330`/`600510`(DID) 워크패킷의 실제 구현/설계 판단 — 번호만 바뀌고 내용은 전혀 재론하지 않음.
- `600540`(구 `600530`)의 실제 구현 판단(Option A 확정, `0154` 등) — 마찬가지로 번호만 바뀌고 내용은 재론하지 않음.

## Module Domain Tags

- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0의 번호 충돌은 Human 결정 1(옵션 b, `600530`→`600540`)로 완전히 해소됐다 — `600540`이 실제 빈 슬롯임을 디스크/색인 양쪽에서 재확인했다. §2(`600530`→`600540` rename, 그룹 9 7개 파일로 정정)와 §5(`600520` 워크패킷 자신의 내용 갱신)는 Human 결정으로 확정됐고 §1/§4/§6에 반영 완료 — 53개 파일 전체 매핑, 외부 참조 갱신 대상(신규 색인 백필 7개 포함), 4단계 실행 순서 모두 확정됐다. Stage 4 착수를 막는 미해소 항목 없음. `.sql`/`.md` 파일 어느 것도 이번 턴에 실제로 rename·수정하지 않았다.
