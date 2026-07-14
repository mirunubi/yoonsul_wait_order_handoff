# 600441_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`kds_status_committed_unification`

## §0 Human 결정 재확인 (2026-07-11, 재논의 금지)

KDS 상태명을 `COMMITTED`로 통일한다(`READY_TO_COMMIT` 폐기). 근거:
1. `900101`/`900102`/`900160`/`900161` 등 특허/설계 문서 전체가 `COMMITTED`만 사용, `READY_TO_COMMIT`은 0건.
2. 실제 특허 출원 문서(3개 HTML 파일) 직접 확인 결과, "COMMITTED"라는 영문 용어 자체는 청구항에 없고 한국어 "확정" 개념으로만 서술됨 — 어느 쪽으로 통일해도 특허 문구와 직접 충돌 위험은 낮음이 확인됨. 이 조건 하에서 900시리즈 내부 설계 문서와의 일관성을 우선하기로 결정.

이번 산출물(Stage 1.5)은 문서만 — `.sql` 파일은 이번 턴에 생성/수정하지 않는다.

## §1 대상 파일과 총 치환 건수

**13개 파일, 46건**(이번 턴 `grep -c "READY_TO_COMMIT"` 전수 재계산, `chk_kds_status` 제약 정의 자체 1건 포함. `0151`은 Human 결정(2026-07-11, 재논의 금지)으로 13번째 파일로 신규 포함됨 — §3 참고):

| 파일 | 건수 |
|---|---:|
| `0016_create_kds_tickets.sql` | 7 |
| `0024_create_store_bootstrap_rpc.sql` | 1 |
| `0026_create_order_rpc.sql` | 1 |
| `0028_create_kds_capacity_commit_rpc.sql` | 12 |
| `0029_create_kds_cooking_rpc.sql` | 7 |
| `0039_create_kds_bulk_commit_rpc.sql` | 2 |
| `0044_create_menu_management_rpc.sql` | 1 |
| `0045_create_daily_summary_rpc.sql` | 1 |
| `0051_create_pre_order_rpc.sql` | 1 |
| `0070_create_flutter_bootstrap_rpc.sql` | 3 |
| `0081_create_customer_app_rpc.sql` | 2 |
| `0143_add_no_payment_kds_release_policy.sql` | 7 |
| `0151_create_check_kds_capacity_function.sql`(13번째, 신규 포함) | 1 |
| **합계** | **46** |

## §2 파일별 정확한 위치 (함수명/라인/성격)

### `0016_create_kds_tickets.sql` (테이블 DDL, 함수 없음)

| 라인 | 위치 | 성격 |
|---|---|---|
| L90 | `constraint chk_kds_status check (kds_status in (...))` | **실제 DDL — CHECK 제약값 목록 원소** |
| L129 | `idx_kds_tickets_store_zone` 부분 인덱스 `where ... and kds_status in ('READY_TO_COMMIT', 'COOKING')` | **실제 DDL — 부분 인덱스 predicate.** CHECK 제약과 별개 객체이므로, 제약만 바꾸고 인덱스 predicate를 안 바꾸면 인덱스가 더 이상 존재하지 않는 값을 참조하는 채로 남는다(에러는 안 나지만 의미상 stale). |
| L146 | `idx_kds_tickets_device` 부분 인덱스 `where ... and kds_status in ('READY_TO_COMMIT', 'COOKING', 'READY')` | **실제 DDL — 부분 인덱스 predicate**, L129와 동일 성격 |
| L165, L173, L182, L192 | 컬럼/제약 `comment on column ...` 서술문 4곳 | **COMMENT — 실행되는 메타데이터, 로직 영향 없음** |

### `0024_create_store_bootstrap_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L154 | `catchmenu_common.get_store_bootstrap(...)` | **실제 SQL — `count(*) filter (where kds_status in ('COOKING', 'READY_TO_COMMIT'))`** |

### `0026_create_order_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L585 | `catchmenu_pos.cancel_order(...)` | **실제 SQL — UPDATE WHERE 절 `kds_status in ('HOLD', 'CAPACITY_CHECKING', 'READY_TO_COMMIT')`**(취소 가능한 상태 판정) |

### `0028_create_kds_capacity_commit_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L4 | (파일 상단 헤더 주석) | 주석, 로직 영향 없음 |
| L35 | `catchmenu_kds.evaluate_kds_capacity(...)` | **실제 SQL — `where kds_status in ('COOKING', 'READY_TO_COMMIT')`**(용량 계산 대상 판정) |
| L154 | `catchmenu_kds.commit_kds_ticket(...)` | 주석(로직 설명) |
| L180 | 〃 | **실제 DDL — `else` 분기 주석**(로직 아님, 바로 아래 SET문 앞) |
| L183 | 〃 | **실제 SQL — `update ... set kds_status = 'READY_TO_COMMIT'`**(상태 전환 SET) |
| L203 | 〃 | **실제 SQL — `kds_events` INSERT, `to_status` 컬럼값** |
| L228 | 〃 | **실제 SQL — `catchmenu_ledger.events` INSERT, `to_state` 컬럼값** |
| L262 | 〃 | **실제 SQL — 감사로그 `p_after_state` jsonb의 `'kds_status'` 키 값** |
| L275 | 〃 | **실제 SQL — RPC 반환 jsonb의 `'kds_status'` 키 값** |
| L467 | `catchmenu_kds.authorize_kds_release(...)` | **실제 SQL — `where kds_status in ('READY_TO_COMMIT', 'CAPACITY_CHECKING')`**(릴리즈 가능 티켓 카운트) |
| L593, L609 | `comment on function catchmenu_kds.commit_kds_ticket(...)`/`authorize_kds_release(...)` | **COMMENT ON FUNCTION — 실행되는 메타데이터, 로직 영향 없음** |

### `0029_create_kds_cooking_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L3 | (파일 상단 헤더 주석) | 주석, 로직 영향 없음 |
| L57 | `catchmenu_kds.start_cooking(...)` | **실제 SQL — `if v_ticket.kds_status <> 'READY_TO_COMMIT' then`**(선행 상태 검증, 가드) |
| L81 | 〃 | 주석 |
| L108, L137 | 〃 | **실제 SQL — `kds_events`/`catchmenu_ledger.events` INSERT의 `from_status`/`from_state` 컬럼값** |
| L167 | 〃 | **실제 SQL — 감사로그 `p_before_state` jsonb의 `'kds_status'` 키 값** |
| L708 | `comment on function catchmenu_kds.start_cooking(...)` | **COMMENT ON FUNCTION** |

### `0039_create_kds_bulk_commit_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L80, L97 | `catchmenu_kds.bulk_commit_kds_tickets(...)` | **실제 SQL — `if (v_commit_result->>'kds_status') = 'READY_TO_COMMIT' then`(카운트 분기), 및 `coalesce(..., (v_commit_result->>'kds_status') = 'READY_TO_COMMIT')`(all_conditions_met 대체값 계산)**. `commit_kds_ticket()`의 반환 jsonb를 파싱하는 소비자 쪽이므로, `0028`의 L275 변경과 반드시 짝을 맞춰야 함(하나만 바꾸면 이 비교가 항상 false가 되어 `v_committed_count`가 조용히 0으로 집계됨). |

### `0044_create_menu_management_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L107 | `catchmenu_pos.update_menu_status(...)` | **실제 SQL — `kt.kds_status in ('CAPACITY_CHECKING', 'READY_TO_COMMIT')`**(메뉴 품절 처리 시 영향받는 티켓 판정) |

### `0045_create_daily_summary_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L688 | `comment on function catchmenu_kds.get_kds_performance(...)` | **COMMENT ON FUNCTION** — `avg_hold_minutes` 지표 설명문(실제 계산 로직에는 리터럴 없음, 함수 본문 자체에서는 `READY_TO_COMMIT` 미사용 — 이번 턴 확인) |

### `0051_create_pre_order_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L907 | `comment on function catchmenu_pos.confirm_pre_order_arrival(...)` | **COMMENT ON FUNCTION** |

### `0070_create_flutter_bootstrap_rpc.sql`

**Codex 발견(정정) — L292/L301과 L586은 "우연히 같은 패턴"이 아니라 base+wrapper 관계**: `bootstrap_kds_app()`(L586 소속)은 내부에서 `v_base := catchmenu_common.bootstrap_app(...)`로 `bootstrap_app()`(L292/L301 소속)을 직접 호출한다(이번 턴 소스 직접 재확인, "base bootstrap" 주석과 함께 확인). 즉 `bootstrap_app()`은 base 함수이고 `bootstrap_kds_app()`은 그 위에 얹힌 wrapper 함수다 — 두 함수가 각자 독립적으로 동일한 정렬 CASE 패턴을 우연히 반복 작성한 게 아니라, wrapper가 base를 합성(compose)하는 관계이므로 **base 함수(`bootstrap_app`)를 먼저 수정하고, wrapper 함수(`bootstrap_kds_app`)도 반드시 함께 수정해야 하며, 라이브 재실행도 두 함수 모두 필요**하다(자세한 근거는 `600442_Logic.md` §4.10).

| 라인 | 함수 | 성격 |
|---|---|---|
| L292 | `catchmenu_common.bootstrap_app(...)`(**base 함수**) | **실제 SQL — `case kds_status when 'READY_TO_COMMIT' then 1 ...` 정렬 순서** |
| L301 | 〃 | **실제 SQL — `filter (where kds_status in ('COOKING', 'READY', 'READY_TO_COMMIT', 'CAPACITY_CHECKING'))`** |
| L586 | `catchmenu_common.bootstrap_kds_app(...)`(**wrapper 함수 — L292/L301의 `bootstrap_app()`을 내부에서 호출**) | **실제 SQL — 자체 KDS 티켓 조회 쿼리 내 동일한 `case kds_status when 'READY_TO_COMMIT' then 1 ...` 정렬 순서**(`v_base` 호출 결과에서 상속되는 게 아니라 `bootstrap_kds_app()` 자신의 별도 쿼리) |

### `0081_create_customer_app_rpc.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L1056 | `catchmenu_store.track_takeout_order(...)` | **실제 SQL — `'ready_count', count(*) filter (where kds_status in ('READY', 'READY_TO_COMMIT'))`** |
| L1066 | 〃 | **실제 SQL — `'all_ready', bool_and(kds_status in ('READY', 'READY_TO_COMMIT', 'COMPLETED', 'SERVED'))`** |

### `0143_add_no_payment_kds_release_policy.sql`

| 라인 | 함수 | 성격 |
|---|---|---|
| L119 | `catchmenu_kds.release_kds_ticket_no_payment(...)` | **실제 SQL — `if v_ticket.kds_status = 'READY_TO_COMMIT'`**(이미 전환된 티켓인지 가드) |
| L180 | 〃 | **실제 SQL — `update ... set kds_status = 'READY_TO_COMMIT'`** |
| L221, L266 | 〃 | **실제 SQL — `kds_events`/`catchmenu_ledger.events` INSERT의 상태 컬럼값** |
| L308, L324 | 〃 | **실제 SQL — jsonb 출력의 `'kds_status'` 키 값(감사로그 + RPC 반환)** |
| L344 | 〃 | **COMMENT ON FUNCTION 문자열 안** |

### `0151_create_check_kds_capacity_function.sql`(13번째, 신규 포함)

| 라인 | 함수 | 성격 |
|---|---|---|
| L74 | `catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id)`, `UNASSIGNED` zone 분기 내부 | **실제 SQL — `count(*) filter (where kds_status in ('COOKING', 'READY_TO_COMMIT'))`**(활성/조리 중 티켓 카운팅용 IN 조건, `v_unassigned_cooking` 산출) |

## §3 `0151`(check_kds_capacity) — **해결됨: Human 결정으로 13번째 파일로 포함 확정**

**원래 절대 하지 말 것 지시("0151... 이미 완료된 파일 건드리지 말 것, COMMITTED로 이미 되어 있어 그대로 둠")를 재확인 목적으로 직접 `grep`한 결과, 이 전제가 사실과 다르다는 것을 발견했었다** — `0151_create_check_kds_capacity_function.sql` L74에 다음 코드가 여전히 존재했다:

```sql
where kds_status in ('COOKING', 'READY_TO_COMMIT')
```

- 이 파일은 `600410_kds_capacity_gate_and_status_reconciliation` 워크패킷에서 오늘 생성되고 Stage 6 ACCEPT까지 완료됐다(`600417_Audit.md`).
- `check_kds_capacity()`는 "kds_status 값을 직접 다루지 않을 것"이라는 애초 작업 지시의 예상과 달리, **`evaluate_kds_capacity()`를 호출하지 않는 별도 zone 순회 로직(`UNASSIGNED` 분기) 내부에서 직접 `kds_status in (...)`로 조리 중/커밋 완료 티켓을 카운트한다.**
- **결과적 함의(수정 없을 경우)**: 이번 변경으로 `chk_kds_status` CHECK 제약과 `kds_status` 컬럼에 실제로 저장되는 값이 `READY_TO_COMMIT`에서 `COMMITTED`로 바뀌면, `0151`의 L74는 더 이상 어떤 행과도 매치되지 않는 죽은 조건이 된다 — `COMMITTED` 상태의 티켓이 "조리 중" 카운트에서 조용히 누락되어 `check_kds_capacity()`의 용량 판단이 실제보다 낮게 계산되는 새로운 silent undercount 결함이 발생한다(하드 에러 없음, 이번 세션에서 반복적으로 다뤄온 바로 그 실패 유형).

**Human 결정(2026-07-11, 재논의 금지)**: `0151`을 이번 배치의 13번째 파일로 포함한다. L74의 `'COOKING', 'READY_TO_COMMIT'` → `'COOKING', 'COMMITTED'`로 함께 치환한다. §1/§2에 반영 완료(위 §1 표, §2 `0151` 서브섹션).

**이미 Stage 6 Audited(ACCEPT)된 파일을 재오픈하는 것에 대한 입장**: 이번 포함은 `600417_Audit.md`의 ACCEPT 판정 자체를 무효화하는 것이 아니다 — `600417_Audit.md` 작성 시점에는 `READY_TO_COMMIT`이 900시리즈 설계 문서와 불일치한다는 이번 워크패킷의 전제 자체가 존재하지 않았으므로(그 판정은 그 시점 기준으로 정당했다), 이번 포함은 "감사 판정이 틀렸었다"가 아니라 "감사 완료 이후 별도로 발생한 새 Human 결정(COMMITTED 통일)에 따라 파생적으로 필요해진 후속 수정"이다. 이 구분과 `600417_Audit.md`로의 교차 참조 필요성은 `600442_Logic.md`의 Open Item으로 명시한다.

## §4 `600410`/`600420`/`600910`에서 이미 처리된 부분과의 경계

- **`0098`/`0099`/`0106`/`0116`**: 이번 턴 직접 재확인 결과 이 4개 파일은 `kds_status`에 `'COMMITTED'`를 **이미** 사용하고 있으며(`READY_TO_COMMIT` 0건), `READY_TO_COMMIT` 문자열이 전혀 등장하지 않는다. `600420`/`600910` 배치가 이들을 이미 정상 상태로 만들어뒀다는 전제는 **이번 재확인으로 사실 확인됨** — 이 4개 파일은 이번 변경의 대상이 아니며 손대지 않는다.
- **`0151`**: 정반대 사례다. "이미 COMMITTED로 되어 있어 손댈 필요 없다"는 애초 전제가 **틀렸음이 이번 재확인으로 드러났고**, Human 결정으로 13번째 파일로 포함이 확정됐다(§3).
- **대조 요약**: `0098`/`0099`/`0106`/`0116`은 "이미 클린하다는 전제 → 재확인으로 사실 확인됨 → 그대로 제외"인 반면, `0151`은 "이미 클린하다는 전제 → 재확인으로 반증됨 → 발견된 잔여 문제로서 이번 배치에 새로 포함"이다 — 같은 "이미 완료된 워크패킷 소속 파일"이라도 재확인 결과에 따라 정반대 결론(제외 vs 포함)에 도달한 두 사례를 나란히 두어, "이미 처리됐다"는 전제를 검증 없이 받아들이지 않는다는 이번 세션의 원칙을 이 문서 안에서도 그대로 보여준다.

## §5 `committed_at` 컬럼과의 관계 — 참고 (변경 대상 아님)

`0016`의 `kds_tickets` 테이블에는 이미 `committed_at timestamptz` 컬럼과 `chk_kds_committed_after_created`/`chk_kds_cooking_after_committed` 제약이 존재한다(L61, L104, L108) — 컬럼/제약 **이름 자체가 이미 "committed" 표기를 쓰고 있다.** 이는 이번 Human 결정(COMMITTED 통일)과 자연스럽게 부합하는 기존 설계이며, 이번 변경이 `READY_TO_COMMIT` → `COMMITTED`로 통일하는 것은 **컬럼/제약 이름이 아니라 `kds_status` 컬럼에 저장되는 문자열 값 자체**다 — `committed_at` 컬럼명 자체는 이번 변경 대상이 아니다(이미 올바름).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` — KDS release/handoff 계열의 상위 ChangeContract 후보이며, 본문 §0의 900시리즈 설계 일관성 근거에 포함된다.

### Full Rules Required

- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` — 본문 §0에서 `COMMITTED` 사용 현황 근거로 언급된 900시리즈 설계 문서.
- `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` — 본문 §0에서 `COMMITTED` 사용 현황 근거로 언급된 900시리즈 경계 문서.
- `900160_Overview_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` — 본문 §0에서 `COMMITTED` 사용 현황 근거로 언급된 특허/설계 문서.
- `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` — 본문 §0에서 `COMMITTED` 사용 현황 근거로 언급된 특허/설계 문서.

### Domain Indexes

- 해당 없음 — 본문에 KDS 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- `0098`/`0099`/`0106`/`0116` — 본문 §4에서 이미 `COMMITTED` 상태로 클린함을 재확인하여 이번 변경 대상에서 제외.
- `committed_at` 컬럼/제약명 변경 — 본문 §5에서 이미 올바른 이름으로 확인되어 변경 대상이 아니라고 명시.
- `600417_Audit.md` 판정 무효화 — 본문 §3에서 이번 변경은 기존 ACCEPT를 무효화하는 것이 아니라 후속 Human 결정에 따른 파생 수정이라고 명시.

### External Evidence (repo 밖)

- **특허 출원 HTML 3개 파일**(`bm_order_handoff_patent_summary_v2.html` 등) — **정정(이번 턴)**: 이 3개 파일은 repo 안에 존재하지 않는다. Human이 채팅에 직접 업로드한 외부 첨부파일이며, `600441_Overview.md` §0 작성 시점에 직접 대조·확인한 근거 자료였다. 애초 "정확한 경로/파일명이 확인되지 않는다"는 것은 검색 누락이 아니라 **애초부터 repo 파일이 아니었기 때문**임을 이번 턴에 확인했다 — 따라서 `Full Rules Required`(repo 내 파일에 대한 항목)에서 제거하고 이 별도 소항목으로 이동한다. `Full Rules Required`/`Master Anchor`는 repo 안에서 재열람 가능한 파일만 담는 것으로 정의를 유지하며, 이 3개 HTML은 그 정의에 해당하지 않는 외부 근거로 분류를 정정한다.

**Open Question 해결됨**: "Stage 2/후속 문서에서 실제 파일 경로를 명시할 것"이라는 이전 Open Question은 해소되었다 — 경로가 확인되지 않았던 이유는 파일이 애초에 repo 밖에 있었기 때문이며, repo 내 경로는 존재하지 않는다(존재할 수 없다). 후속 문서에서 이 3개 HTML을 다시 인용할 필요가 있다면 repo 경로가 아니라 "Human 업로드, 2026-07-13, 채팅 첨부"로 출처를 표기한다.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600442_Logic.md` 작성 진행 가능 — 단, §3의 `0151` 상충은 Logic.md에서도 Open Question 1순위로 유지한다.
