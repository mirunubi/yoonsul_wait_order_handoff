# 601301 — Master Tracker: Fable Blind Reverse-Engineering Audit

- Program: `601300_fable_blind_reverse_engineering_audit`
- Created: 2026-07-18
- Owner role: Claude Code (구조 생성/추적표 관리), 실제 Pass A/B/C 수행자는 Claude Fable
- Status: 진행 중 — 공통/기반 Pass A, 결제 Pass A, waiting_order Pass A(5/5 슬라이스) 완료로 표준 진행률 3/18. 나머지 15개 표준 Pass 슬롯은 NOT_STARTED이며, waiting_order의 단일 Pass A 슬롯은 5개 슬라이스 결과 파일이 공동으로 대체한다.

## 0. 번호 확정 근거

`000700_ai_agent_prelearning_and_project_context/`는 `000700`-`000715` 전부 flat 개별 파일로만 구성되어 있어(하위 폴더 없음), 이 프로그램이 요구하는 "폴더 + 6개 도메인 하위폴더(각 10단위 블록) + 다수 파일" 구조와 맞지 않는다. 반면 `600000_implementation_lifecycle/`은 `601100_store_admin_console`, `601200_caller_authorization_foundation`처럼 폴더+하위 워크패킷 구조가 표준인 곳이며, 확인된 최대 프로그램 번호가 `601200`이었다. 이 판단은 직전 라운드에서 이미 확정해 실제로 `601300` 아래 구조를 생성한 바 있으므로, 이번 라운드에서는 그 결정을 유지하고 번호 재검토를 반복하지 않았다 — `601300`을 BASE로 그대로 사용한다.

BASE=`601300`, 도메인별 10단위 블록 배정:

| 블록 | 도메인 |
|---|---|
| 601310 | 00_common_auth |
| 601320 | 01_payment |
| 601330 | 02_waiting_order |
| 601340 | 03_store_admin |
| 601350 | 04_kds_did |
| 601360 | 05_cms |

`601301`=Master Tracker, `601390`=Modularization & Integration Plan(Phase 4). `6013xx` 전 구간을 `000005`/`000007` 인덱스에서 재확인한 결과 이 프로그램 자신의 기존 등록분 외에는 사용된 번호가 없었다.

## 1. 프로그램 배경 및 목적

`catchmenu` 코드베이스 전체에 대해 **Fable을 이용한 블라인드 역설계 감사**를 수행하기 위한 추적/저장 구조다. 절차는 3-Pass로 도메인마다 반복된다:

- **Pass A — Blind Reverse Engineering**: 설계 문서를 보여주지 않고, 코드(SQL 마이그레이션/RPC 정의)만으로 Fable이 "이 코드가 실제로 무엇을 하는가"를 독립적으로 역설계.
- **Pass B — Intent Comparison**: Pass A 결과를 원래 설계 의도(Overview/Logic/ChangeContract)와 대조.
- **Pass C — Confirmed Gaps And Disposition**: Pass A/B 비교에서 나온 불일치를 확정된 Findings로 정리하고, 각 항목에 대해 판정(철회/재분류/확정)을 내린다.

6개 도메인 모두 Pass C까지 끝나고 Entry Gate(§5)를 통과하면 `601390_Modularization_Integration_Plan.md`(Phase 4)를 작성한다.

## 2. 진행 상황 추적표

| Domain | Pass A | Evidence Complete % | Pass B | Pass C | Critical | High | Unknown | Final State |
|---|---|---|---|---|---|---|---|---|
| 00_common_auth | COMPLETED (2026-07-18) | 100% (자체 명시된 한계 제외) | NOT_STARTED | NOT_STARTED | 2 (4-1, 4-9 잠정) | 2 (4-3, 4-5 잠정) | — | PENDING (Pass B 대기) |
| 01_payment | COMPLETED (2026-07-18) | 100% (자체 명시된 한계 제외) | NOT_STARTED | NOT_STARTED | 2 (4-1, 4-7 잠정) | 2 (4-2, 4-3 잠정) | — | PENDING (Pass B 대기) |
| 02_waiting_order | COMPLETED — 5/5 슬라이스 완료 (slice05, slice01, slice02, slice03, slice04; 2026-07-18) | 5개 슬라이스 전부 100% (공유기반+등록/조회+호출/도착+노쇼/유예+사전주문/착석/주문본체) | NOT_STARTED | NOT_STARTED | 2 (slice04 4-1/4-2, 4-3 잠정) | — | — | PASS_A_DONE (슬라이스별 완료, 통합 Pass A는 Pass B 진입 전 종합 권장) |
| 03_store_admin | NOT_STARTED | — | NOT_STARTED | NOT_STARTED | — | — | — | PENDING |
| 04_kds_did | NOT_STARTED | — | NOT_STARTED | NOT_STARTED | — | — | — | PENDING |
| 05_cms | NOT_STARTED | — | NOT_STARTED | NOT_STARTED | — | — | — | PENDING |

### §2.1 최우선 Critical 발견 — waiting_order slice04

1. **`pre_order_while_waiting()` — phantom 교정 캠페인에서 누락된 다섯 번째 형제 함수.** `0160`/`0163`/`0164`가 형제 waiting 함수들의 phantom 컬럼을 교정했지만 이 함수는 누락됐다. 현재 라이브 스키마에 없는 `orders.order_source`, `order_items.unit_price`/`subtotal`/`item_options`, `order_sessions.pre_order_amount`를 참조하고, 유효하지 않은 enum `order_type='TABLE'`을 INSERT하며, 동시에 PUBLIC EXECUTE로 노출돼 있다. 현재 라이브 스키마 기준 실행 시 크래시는 확정적이다. 별도 긴급 워크패킷 후보 **`pre_order_while_waiting_phantom_correction`**으로 최우선 기록하고, Pass B/C에서 처분을 확정한다.
2. **사전주문 해피패스 상태게이트 모순.** 정상 경로 `create_pre_order()`는 세션을 `ORDER_CONFIRMED`로 전이하지만, 다음 `confirm_pre_order_arrival()`이 위임하는 `bind_table_to_session()`은 `WAITING`/`ARRIVAL_PENDING`/`ORDERING`만 허용하고 `ORDER_CONFIRMED`를 거부한다. 따라서 `create_pre_order → confirm_pre_order_arrival` 해피패스가 상태머신상 완주되지 않는다. 별도 Critical로 기록하고 Pass B/C에서 호출 순서 및 수정 경계를 확정한다.

- **Evidence Complete %**: Pass A 입력 매니페스트 대비 Fable이 실제로 커버했다고 확인된 파일/함수 비율. Pass A 완료 시 채운다.
- **Critical / High / Unknown**: Pass C에서 확정된 발견 건수(심각도별). Pass C 완료 전까지 `—`.
- **Final State**: `PENDING` → `IN_REVIEW` → `PASS_A_DONE` → `PASS_B_DONE` → `PASS_C_DONE` → (전체 완료 시) `CLOSED`.

## 3. 도메인별 메타데이터

각 도메인 Pass가 진행될 때마다 아래 표의 해당 행을 채운다. (현재 공통/기반·결제·waiting_order 도메인 Pass A 기록 완료, waiting_order는 5개 슬라이스 파일로 분산 저장, 나머지 3개 도메인 미기록)

| Domain | Input Manifest | Fable Run ID | Output File | Review Date | Files Omitted | Known Evidence Gaps | Pass A frozen git commit hash |
|---|---|---|---|---|---|---|---|
| 00_common_auth | 01_foundation_input_package.md (19 migrations, 149 RPC) + 01_foundation_migrations_concat.sql | Opus 4.8 (fallback) — Reviewer note: "Fable 5 blocked mid-request, auto-fell-back to Opus 4.8 per Anthropic's safety-switching policy - review completed by Opus 4.8, not Fable 5" (파일 601311 헤더는 원문 보존 지시에 따라 'Claude Fable 5' 표기 유지, 실제 완료 모델은 이 노트 기준) | 601311 | 2026-07-18 | 설계문서/특허문서 일체(블라인드 조건), 601210~601212(Known Prior Finding) | RLS 정책 라이브 텍스트(pg_policy.cmd 추출오류), 민감컬럼 값 8종 redacted, 호출측 코드(Flutter/게이트웨이) 미포함 | scratch 파일 기반(비추적) — 커밋 해시 미고정, 향후 고정 필요 |
| 01_payment | 02_payment_600500_input_package.md (15 migrations, 87 RPC) + 02_payment_600500_migrations_concat.sql | 확인불가 — 파일 Reviewer는 `Claude Fable 5`로 표기되어 있으나 실제 Fable 5 완료인지 Opus 4.8 fallback인지 독립적으로 확인할 실행 메타데이터 없음 | 601321 | 2026-07-18 | 설계문서/특허문서 일체(블라인드 조건), 601210~601212(Known Prior Finding) | RLS 정책 라이브 텍스트(pg_policy.cmd 추출오류), 민감컬럼 값 redacted, 호출측(엣지/앱) 코드 미포함, 15개 밖 후속 마이그레이션 미포함(4-3 드리프트 판정 유보) | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 02_waiting_order (slice 05) | slice_05_cross_slice_reconciliation_input_package.md (9 migrations, 공유 RPC 0025/0026/0049 포함) + slice_05_..._migrations_concat.sql | Claude Fable 5 (in-session) | 601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md (5개 슬라이스 통합 전 부분 결과) | 2026-07-18 | 설계문서/특허문서 일체(블라인드), 601210~601212(Known Prior Finding), 슬라이스 01~04(대기등록/호출도착/노쇼/사전주문·착석) | RLS 정책 라이브 텍스트, 민감컬럼 redacted, 0025/0049 grant 문 미포함, KDS 티켓 상태(COMMITTED/COOKING) 관계는 04 슬라이스 소관 | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 02_waiting_order (slice 01) | slice_01_waiting_queue_input_package.md (4 migrations: 0050/0115/0149/0164, 6 RPC) + slice_01_waiting_queue_migrations_concat.sql | Claude Fable 5 (in-session) | 601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md (5개 슬라이스 통합 전 부분 결과) | 2026-07-18 | 설계문서/특허문서 일체(블라인드), 601210~601212(Known Prior Finding), 공유 테이블 DDL(slice 05 관할), 형제 함수 라이브 정의(슬라이스 02~04) | RLS 정책 텍스트, 민감컬럼 redacted, 0115/0164의 register_waiting·get_waiting_status·get_waiting_admin_view grant 문 미포함(PUBLIC proacl 사실만 확인) | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 02_waiting_order (slice 02) | slice_02_customer_call_arrival_input_package.md (5 migrations: 0160/0164/0167/0115/0050, 5 RPC) + slice_02_customer_call_arrival_migrations_concat.sql | Claude Fable 5 (in-session) | 601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md (5개 슬라이스 통합 전 부분 결과) | 2026-07-18 | 설계문서/특허문서 일체(블라인드), 601210~601212(Known Prior Finding), 공유 테이블 DDL(slice 05), 형제 함수(get_waiting_*/cancel_waiting/seat_* 슬라이스 01/04) | RLS 정책 텍스트, 민감컬럼 redacted, 0115/0164의 call_waiting_customer·confirm_arrival grant 문 미포함(PUBLIC proacl 사실만 확인), 구 call_next_waiting 상위 호출측 코드 미포함 | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 02_waiting_order (slice 03) | slice_03_no_show_grace_input_package.md (3 migrations: 0161/0050/0115, 5 RPC) + slice_03_no_show_grace_migrations_concat.sql (kds_tickets 스키마 포함) | Claude Fable 5 (in-session) | 601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md (5개 슬라이스 통합 전 부분 결과) | 2026-07-18 | 설계문서/특허문서 일체(블라인드), 601210~601212(Known Prior Finding), 공유 테이블 DDL(slice 05), KDS 용량/조건 판정 로직(슬라이스 04) | RLS 정책 텍스트, 민감컬럼 redacted, no_show_kds_grace_minutes 컬럼(slice05 store_settings 덤프에 없음, 후속 마이그레이션 여부 유보), NO_SHOW_GRACE HOLD의 용량 포함 여부는 04 슬라이스 소관 | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 02_waiting_order (slice 04) | slice_04_pre_order_order_session_input_package.md (5 migrations: 0051/0115/0025/0026/0163, 15 RPC) + slice_04_..._migrations_concat.sql (orders/order_items 스키마 포함) | Claude Fable 5 (in-session) | 601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md (5개 슬라이스 통합 전 부분 결과) | 2026-07-18 | 설계문서/특허문서 일체(블라인드), 601210~601212(Known Prior Finding), 공유 테이블 상태정의(slice 05), 앞단 등록/호출/노쇼(슬라이스 01~03) | RLS 정책 텍스트, 민감컬럼 redacted, 0115 계열 grant 원문 미포함(PUBLIC proacl만 확인), order_source/pre_order_amount/'TABLE' enum의 후속 마이그레이션 추가 여부 유보, 호출측 호출순서(create_pre_order→confirm_pre_order_arrival 등) 코드 미포함 | scratch 파일 기반(비추적) — 커밋 해시 미고정 |
| 03_store_admin | — | — | 601341 | — | — | — | — |
| 04_kds_did | — | — | 601351 | — | — | — | — |
| 05_cms | — | — | 601361 | — | — | — | — |

- **Input Manifest**: Pass A에 실제로 제공한 파일 목록(정확한 경로 나열, 별도 파일 또는 이 셀에 직접 기록).
- **Fable Run ID**: Fable 세션/응답을 재현·추적하기 위한 식별자(있는 경우).
- **Files Omitted**: 의도적으로 Pass A 입력에서 제외한 파일(예: 설계 문서, §4의 Known Prior Finding 관련 문서 전부).
- **Pass A frozen git commit hash**: Pass A 입력을 만든 시점의 정확한 커밋 해시 — 이후 코드가 바뀌어도 "그 순간의 코드"를 기준으로 재검증할 수 있도록 고정.

### 02_waiting_order 도메인 특이사항

Pass A 입력은 Cursor의 재분할 결과에 따라 5개 슬라이스로 관리한다. slice05(공유 테이블/이벤트/트리거)는 `601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md`, slice01(대기열 등록/조회)은 `601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md`, slice02(호출/도착확인)는 `601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md`, slice03(노쇼/유예)은 `601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md`, slice04(사전주문/착석/주문본체)는 `601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md`에 저장됐다. 5개 슬라이스가 모두 끝났으므로 이 도메인의 Pass A는 `COMPLETED — 5/5` 및 `PASS_A_DONE`으로 확정한다. 기존 단일 `601331_PassA_Blind_Reverse_Engineering_Waiting_Order.md` PLACEHOLDER는 이 5개 결과 파일로 대체된 표준 슬롯이며 진행률에 중복 계산하지 않는다. 표준 Pass B/C 파일은 계속 PLACEHOLDER 상태로 둔다.

### `call_waiting_customer()` PUBLIC 노출 — 3중 독립 확증

slice02의 `call_waiting_customer()` PUBLIC 노출은 동일 사실이 서로 독립적인 세 경로에서 확인됐다: (1) ChatGPT Stage 11B Blind Audit이 `PUBLIC EXECUTE` 위험을 최초로 지적했고, (2) Cursor+Codex가 라이브 `proacl`과 `anon` 역할 호출 실증으로 재확인했으며, (3) Fable이 해당 선행 발견을 제공받지 않은 slice02 블라인드 Pass A에서 §4-6으로 다시 발견했다. 따라서 이 항목은 단일 리뷰어의 해석이 아니라 **ChatGPT Stage 11B → Cursor/Codex 실증 → Fable 블라인드 재발견**의 3중 확증을 가진다. 해결 여부와 처분은 Pass B/C에서 확정한다.

### `apply_no_show_transition()` 권한 하드닝 미적용 — 후속 워크패킷 후보

slice03 §4-4에서 `0161_mark_no_show_overload_and_redesign.sql`이 신규/재설계한 5개 SECURITY DEFINER 함수에 명시적 `REVOKE ... FROM PUBLIC`/`GRANT ... TO authenticated` 하드닝을 적용하지 않았음이 확인됐다. 특히 공유 내부 코어인 `apply_no_show_transition()`의 라이브 `proacl`은 NULL이며, 이는 `_record_waiting_call()`/`_resolve_dining_table_by_number()` 같은 내부 헬퍼에 대해 `0163`/`0167`이 적용한 owner-only 하드닝과 동일한 결함 클래스일 수 있다. 다만 현재 스키마 USAGE 때문에 실제 도달 범위는 slice03의 Confidence Notes대로 추가 검증이 필요하다. `0161`의 실제 Git 커밋은 `14e3ebc1`(2026-07-16)이며, 이 권한 경계 교정은 별도 후속 워크패킷 후보(가칭 `no_show_transition_acl_hardening`)로 기록하고 Pass B/C에서 범위와 처분을 확정한다.

## 4. Known Prior Finding — 직원 인증 다리 부재 (Pass A 입력 절대 금지)

> **caller_authorization_foundation gap (601210/601211/601212)**
> Visibility: **Withheld from Pass A. Available from Pass B or Pass C only.**

별도 프로그램 `601200_caller_authorization_foundation`의 워크패킷 `601210_caller_authorization_resolver_pilot`(문서: [601211_Overview](../601200_caller_authorization_foundation/601210_caller_authorization_resolver_pilot/601211_Overview_Caller_Authorization_Resolver_Pilot.md), [601212_Logic](../601200_caller_authorization_foundation/601210_caller_authorization_resolver_pilot/601212_Logic_Caller_Authorization_Resolver_Pilot.md))에서 이미 다음이 확정되었다: `catchmenu_common.staff_login()`의 커스텀 `auth_sessions` 세션 시스템과 Supabase Auth JWT/`current_actor_id()` 체계 사이에 코드베이스 어디에도 연결 다리가 없으며, 이 전제로 신원을 증명하는 메커니즘은 실제로 단 한 번도 작동한 적이 없다.

**⚠ 경고 — 이 섹션(및 601210/601211/601212 문서 전체)은 어떤 도메인의 Pass A 입력 패키지에도 절대 포함시키지 않는다.** Pass A는 순수 블라인드 역설계여야 하므로, 이 발견을 미리 알고 코드를 읽으면 블라인드 조건이 깨진다. 이 발견은 **Pass B(의도 비교) 또는 Pass C(확정 판정) 단계에서만** 참고 자료로 사용할 수 있다 — 특히 도메인 00(공통/인증)과 도메인 03(매장 관리자 콘솔)의 Pass B/C에서, Fable이 블라인드로 역설계한 "직원 인증이 이렇게 되어 있을 것"이라는 추정이 이 기지(旣知) 사실과 일치하는지 대조하는 데 쓴다.

## 5. Pass 불변성 원칙

Pass A와 Pass B의 결과 파일은 **저장 후 원문을 수정하지 않는다.** 이후 오류나 재해석이 필요한 경우에도 Pass A/B 원문은 그대로 두고, **Pass C에서만** 해당 항목에 대해 "철회(retract)" 또는 "재분류(reclassify)" 판정을 내려 기록한다 — Pass C 문서에 "원문 항목 X는 Y 사유로 철회/재분류함"의 형태로 남긴다. Pass A/B 파일 자체를 되돌아가 고쳐 쓰면 무엇이 실제 블라인드 결과였는지 사후에 구분할 수 없게 되므로 금지한다.

## 6. Modularization & Integration Plan — Entry Gate

`601390_Modularization_Integration_Plan.md`(Phase 4)는 아래 조건을 **전부** 만족하기 전까지 작성을 시작하지 않는다:

1. 6개 도메인 전부 Pass A / Pass B / Pass C가 `DONE` 상태일 것.
2. 6개 도메인 Findings 간 교차 중복(동일 근본 원인이 여러 도메인에서 별개 항목으로 잡힌 경우) 정리가 끝났을 것.
3. 심각도 `Critical`(=BLOCK) 또는 `High`로 확정된 발견 중, 여러 도메인에 걸쳐 충돌하는 판정이 있다면 그 충돌은 **Human(정영석)의 결정**을 받은 뒤에만 종결 처리할 것.

위 3가지가 모두 충족되기 전에는 이 파일에 어떤 실질적 내용도 채우지 않는다.

## 7. 사용 방법 (각 Pass 결과 저장)

1. Fable의 Pass A/B/C 응답을 받으면, 해당 도메인 폴더의 대응 파일(`601311`/`601312`/`601313` 등)을 **덮어써서** PLACEHOLDER 내용을 실제 결과로 교체한다.
2. 저장 직후 §2 추적표와 §3 메타데이터 표의 해당 셀을 갱신한다 (Evidence Complete %, Critical/High/Unknown 건수, Final State, Input Manifest, Fable Run ID, Pass A frozen git commit hash 등).
3. Pass A/B 저장 후에는 §5 불변성 원칙에 따라 원문을 다시 고치지 않는다 — 정정이 필요하면 Pass C에서 철회/재분류로 처리.
4. 6개 도메인 전부 Pass C `DONE` + §6 Entry Gate 3개 조건 충족 후에만 `601390_Modularization_Integration_Plan.md` 작성을 시작한다.

### Fable 사용 시 주의 — 안전필터 우회 아닌 명확한 바운더리 설정 (2026-07-18, 결제 도메인 Pass A 진행 중 학습)

Fable 5는 '공격적 사이버보안 기법(익스플로잇/멀웨어/공격도구)' 관련 요청을 자동 차단하고 Opus 4.8로 조용히 폴백시킨다(사용자 동의 없이, 같은 대화 안에서). 이번 프로그램처럼 '실제 시스템의 보안취약점을 찾아라'는 프레이밍은 정당한 자체 감사 목적이어도 이 필터에 걸릴 수 있다(공통/기반 도메인 Pass A에서 실제 발생 — Opus 4.8로 폴백되어 완료됨, 결과 품질 자체는 우수했음).

향후 Pass B/C, 그리고 4단계(시큐어코딩/모듈화 설계)에서 Fable을 다시 쓸 때는:

1. 프롬프트에 명시적 방어 목적 프레이밍을 넣을 것('공격 방법을 찾아라'가 아니라 '기존 접근권한 구조를 문서화하고 정책과의 불일치를 감사하라').
2. 자동전환이 되어도(Opus로) 결과 품질은 충분히 신뢰할 수 있음이 확인됨 — 차단을 두려워해서 프레이밍을 과도하게 순화하기보다, 폴백을 정상 경로로 받아들이고 Tracker에 어느 모델이 실제로 답했는지 기록하는 방식으로 대응.
3. Pass 결과의 파일 헤더(Reviewer 필드)는 원문 보존 원칙에 따라 수정하지 않되, Tracker의 메타데이터 표가 실제 수행 모델(Fable 5 / Opus 4.8 fallback)의 유일한 정확한 기록임을 유지.

## 8. Snapshot Decision

- 2026-07-18 (1차): 프로그램 번호(`601300`)를 확정하고 Master Tracker + 6개 도메인 폴더(각 3개 PassA/B/C 템플릿, 총 18개) + Phase 4 placeholder를 생성.
- 2026-07-18 (2차 정정): 사용자 지시로 PassA/B/C 빈 템플릿 파일 생성을 보류하고 폴더만 남김(Fable 응답 도착 시 직접 파일 생성 예정으로 전환).
- 2026-07-18 (3차 정정): ChatGPT의 9가지 정정사항 반영 — (1) 도메인별 10단위 블록 재배정(601310/601320/601330/601340/601350/601360, Modularization은 601390), (2) 당시 18개 Pass 파일을 강한 PLACEHOLDER 상태로 재생성, (3) 추적표에 Evidence Complete %/Critical/High/Unknown/Final State 컬럼 추가, (4) 도메인별 Input Manifest/Fable Run ID/Output File/Review Date/Files Omitted/Known Evidence Gaps/Pass A frozen git commit hash 메타데이터 표 추가, (5) 직원 인증 다리 부재 발견을 "Known Prior Finding"으로 명시하고 Pass A 입력에서 절대 제외한다는 경고 추가, (6) Pass 불변성 원칙(Pass A/B 원문 수정 금지, 정정은 Pass C 철회/재분류로만) 명시, (7) Modularization Entry Gate 3개 조건 명시, (8) 02_waiting_order 도메인의 Cursor 5-슬라이스 재분할 예정을 특이사항으로 기록, (9) 인덱스(000005/000007) 갱신. 당시에는 아직 Pass 결과가 저장되기 전이었다.
- 2026-07-18 (4차 정정): 공통/기반 Pass A(`601311`)와 결제 Pass A(`601321`) 원문 저장 및 Tracker 반영 완료. 전체 진행률은 2/18이며, 나머지 16개 표준 Pass 파일은 PLACEHOLDER (NOT_STARTED) 상태로 정정했다.
- 2026-07-18 (5차 정정): waiting_order slice 05 원문을 `601331_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice05.md`에 저장하고, waiting_order Pass A를 `PARTIAL — 1/5 슬라이스 완료`로 반영했다. 도메인 전체 Pass A는 미완료이며, 표준 Pass 기준 전체 진행률은 여전히 2/18이다.
- 2026-07-18 (6차 정정): waiting_order slice 01 원문을 `601332_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice01.md`에 저장하고, waiting_order Pass A를 `PARTIAL — 2/5 슬라이스 완료(slice05, slice01)`로 갱신했다. slice02~04가 남아 있어 도메인 전체 Pass A는 미완료이며, 표준 Pass 기준 전체 진행률은 여전히 2/18이다.
- 2026-07-18 (7차 정정): waiting_order slice 02 원문을 `601333_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice02.md`에 저장하고, waiting_order Pass A를 `PARTIAL — 3/5 슬라이스 완료(slice05, slice01, slice02)`로 갱신했다. `call_waiting_customer()` PUBLIC 노출의 3중 독립 확증(ChatGPT Stage 11B → Cursor/Codex 실증 → Fable 블라인드 재발견)을 특이사항으로 기록했다. slice03~04가 남아 있어 도메인 전체 Pass A는 미완료이며, 표준 Pass 기준 전체 진행률은 여전히 2/18이다.
- 2026-07-19 (8차 정정): waiting_order slice 03 원문을 `601334_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice03.md`에 저장하고, waiting_order Pass A를 `PARTIAL — 4/5 슬라이스 완료(slice05, slice01, slice02, slice03)`로 갱신했다. `apply_no_show_transition()` 권한 하드닝 미적용(slice03 §4-4)을 `0163`/`0167`과 동일 클래스일 수 있는 보안 공백으로 기록하고 별도 후속 워크패킷 후보로 이월했다. slice04가 남아 있어 도메인 전체 Pass A는 미완료이며, 표준 Pass 기준 전체 진행률은 여전히 2/18이었다.
- 2026-07-19 (9차 정정, 현재): waiting_order slice 04 원문을 `601335_PassA_Blind_Reverse_Engineering_Waiting_Order_Slice04.md`에 저장하고, waiting_order Pass A를 `COMPLETED — 5/5 슬라이스 완료` 및 `PASS_A_DONE`으로 확정했다. 표준 진행률은 3/18로 갱신했다. `pre_order_while_waiting()`의 phantom 컬럼+무효 enum+PUBLIC 노출 복합 결함과 사전주문 해피패스 상태게이트 모순을 잠정 Critical 2건으로 최상단 요약에 기록했다.
