# 601031_Overview_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 번호 확인 — 번호 충돌 발견 및 해소 경위 (라이브 재확인)

**최초 시도(`600593`)가 잘못됐음을 스스로 발견해 정정한다.** `600500_payment_confirmation/` 산하 직전 워크패킷 `600590_confirm_payment_from_provider_kds_commit_correction/`은 이미 `600591`(Overview)/`600592`(Logic)를 썼고, `600602_NavigationMap`... 정정: 이 도메인의 `600502_NavigationMap_Payment_Confirmation.md`에 이 문서를 작성한 세션 자신이 "`600591_Overview...` -> `600592_Logic...` -> (TestPlan/ChangeContract pending)"라고 이미 기록해 `600593`(TestPlan)/`600594`(ChangeContract)/`600595`(Module) 슬롯을 사실상 예약해 놓은 상태였다 — 처음 이 워크패킷을 `600593`/`600594`/`600595`로 만들려던 시도는 **그 예약과 직접 충돌**하는 것이었고, 파일 생성 직후 자체 재검토로 발견해 즉시 삭제했다.

**대안 탐색**: `600500_payment_confirmation/`의 다음 "10단위" 슬롯은 관례상 `600600`이지만, 이는 **완전히 다른 도메인**(`600600_waiting_order_session/`)이 이미 점유하고 있어(`ls docs/600000_implementation_lifecycle/` 재확인) 쓸 수 없다 — 즉 `600500` 도메인은 자신의 "백단위" 번호 공간(`600500`-`600599`)을 사실상 전부 소진한 상태다(`600510`/`600540`/`600550`/`600560`/`600570`/`600580`/`600590` 7개 워크패킷 + `600590` 자신의 예약 슬롯).

**해소 — 기존 선례 재사용**: `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/`가 이미 정확히 같은 상황의 선례다 — 이 워크패킷은 물리적으로 `600400_kds_did_implementation/` 폴더 안에 있지만, 문서 번호는 `600400`대가 아니라 `601020`대를 쓴다. 즉 **이 프로젝트의 워크패킷 번호는 물리적 폴더 위치의 "백단위"와 반드시 일치할 필요가 없다**는 것이 이미 확립된 관례다. 이 선례를 그대로 따라, `601030`-`601039` 구간이 라이브 어디에도 쓰이지 않음을 재확인한 뒤(`find`/`000005_Index_Document_Number.md` 재검색, 0건) 이 워크패킷을 `601030`(폴더)/`601031`(Overview)/`601032`(Logic)로 배정한다. 폴더는 논리적 연관성(직전 워크패킷 `600590`, 결제확인 도메인)에 따라 `600500_payment_confirmation/` 안에 물리적으로 둔다.

## §0.1 배경 (Cursor 조사 완료 - `601024`가 명시적으로 남긴 Open Item, 재확인 불필요)

`601024`(`0157`의 승인 근거)는 시간 제약으로 `confirm_payment()`(POS 경로, `0098`)만 게이트 우회(`release_kds_after_payment()`가 `check_kds_capacity()`를 정보성으로만 쓰고 무조건 커밋)로 재설계했고, "웹훅/VAN 경로(`0027`)는 여전히 깨진 채 남을 것이며 후속 워크패킷이 필요하다"고 스스로 기록해뒀다(`600591_Overview.md` §1.4/§1.5가 이미 라이브로 재확인한 내용과 정확히 일치). `commit_kds_ticket()`(7조건 게이트)/`evaluate_kds_capacity()`는 `0028`에서 이미 완성되어 라이브에 존재하지만 실질적 호출자가 없는 고아 함수 상태다 — `authorize_kds_release()`가 `0157`에서 DROP되기 전과 동일한 패턴("완성됐지만 아무도 안 씀")이 `commit_kds_ticket()`/`bulk_commit_kds_tickets()`에도 반복되고 있다.

## §0.2 확정된 방향 (ChatGPT+제미나이 교차검증, Human 최종 결정, 재논의 금지)

1. 신규 공용 함수 `request_kds_release_after_payment()` 설계 — `evaluate_kds_capacity()`/`commit_kds_ticket()`를 실제로 호출하는 경로를 만든다.
2. `confirm_payment_from_provider()`(`0027`)가 이 신규 함수를 호출하도록 수정 — 현재 하드코딩된 `kds_release_authorized=false`+JSON 플래그만 찍는 부분을 실제 게이트 연동으로 교체.
3. `confirm_payment()`(POS, `0098`)는 이번 워크패킷에서 손대지 않는다 — "POS도 같은 공용 함수로 연결"은 최우선 후속 워크패킷 후보로만 기록.
4. `resolve_payment_uncertain()`은 완전히 별도(원장 도메인 결함) — 이번엔 다루지 않는다.

## §1 `evaluate_kds_capacity()`/`commit_kds_ticket()` 정확한 현재 시그니처/반환값 (라이브 재확인, 2026-07-18)

```sql
-- 라이브 재확인
evaluate_kds_capacity(p_tenant_id uuid, p_store_id uuid, p_kitchen_zone text default null)
  returns jsonb  -- {cooking_count, hold_count, ready_count, capacity_ok, threshold, kitchen_zone}

commit_kds_ticket(p_tenant_id uuid, p_store_id uuid, p_ticket_id uuid, p_conditions jsonb default '{}'::jsonb, p_correlation_id text default null)
  returns jsonb
  -- 성공(전이): {success:true, ticket_id, kds_status:'COMMITTED', conditions_met, committed_at, kitchen_zone, audit_id, message_code:'kds_committed'}
  -- 성공(대기): {success:true, ticket_id, kds_status:'CAPACITY_CHECKING', conditions_met, all_conditions_met:false, missing_conditions:{...}, capacity_detail, message_code:'kds_conditions_pending'}
  -- 실패(입력검증): {success:false, error_key:'ticket_id_required'|'conditions_must_be_object'|'ticket_not_found'|'ticket_not_holdable'}

bulk_commit_kds_tickets(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_force_conditions jsonb default null, p_correlation_id text default null)
  returns jsonb
  -- {success:true, order_id, committed_count, pending_count, skipped_count, total_processed, all_committed, ticket_results:[...], message_code}
  -- {success:false, error_key:'kds_release_not_authorized', message, order_id}  -- payment_ledger.kds_release_authorized가 false인 주문의 모든 티켓에 대해
```

**핵심 발견 — `commit_kds_ticket()`은 `CAPACITY_CHECKING` 결과도 `success:true`로 반환한다.** 즉 "용량 부족으로 즉시 커밋되지 못함"은 이 함수 자신의 계약에서 이미 **에러가 아니라 유효한 정상 결과**로 설계돼 있다(`0028:339-373`, 라이브 재확인) — §2의 "결제확정 성공과 KDS 방출 실패를 구분해야 한다"는 원칙이 이 계층에서는 이미 자연스럽게 지켜지고 있다. 신규 함수는 이 계약을 그대로 이어받아야 한다.

`bulk_commit_kds_tickets()`는 `commit_kds_ticket()`을 주문의 `HOLD`/`CAPACITY_CHECKING` 티켓 전부에 대해 이미 순회 호출하며(`0039:56-101`, 라이브 재확인), `payment_ledger.kds_release_authorized`를 사전 확인한다 — 즉 **신규 함수가 직접 `commit_kds_ticket()`을 호출할 필요가 없다.** `bulk_commit_kds_tickets()`를 재사용하면 이미 검증된 순회/집계 로직을 중복 구현하지 않아도 된다(§3 근거 참고).

## §2 결제확정 성공 ≠ KDS 방출 실패 — 원칙 반영 확인 (ChatGPT 지적)

**원칙**: "결제 성공 + KDS 대기(`CAPACITY_CHECKING`)"는 유효한 상태여야 하며, 결제 확정 자체의 실패와 혼동되면 안 된다.

**라이브 확인 결과**: 이 원칙은 이미 두 지점에서 부분적으로 지켜지고 있다 — (1) `commit_kds_ticket()` 자신의 반환 계약(위 §1), (2) `confirm_payment_from_provider()`의 `payment_ledger` INSERT는 이미 KDS 관련 코드보다 **먼저** 실행되고 완결된다(`0027:262-289`). 문제는 신규 함수를 **어떻게 호출하느냐**에 있다 — PL/pgSQL에서 함수 A가 함수 B를 호출하고 B가 처리되지 않은 예외를 던지면, A 자신의 그 시점까지의 모든 변경(이미 완료된 `payment_ledger` INSERT 포함)도 함께 롤백된다는 것은 이 세션이 `600652_Logic.md` §9.2에서 이미 실증한 사실이다(`bind_table_to_session()`의 예시와 구조적으로 동일).

**적용**: 신규 함수 `request_kds_release_after_payment()` 자신이 **모든 내부 오류를 스스로 처리하고 절대 예외를 재전파(RAISE)하지 않는** 설계를 채택해야 한다(`600592_Logic.md` §0/`600652_Logic.md` §1.5가 이미 확립한 "raise 대신 build_error_response류 반환" 패턴을 그대로 적용) — 이렇게 하면 `confirm_payment_from_provider()`는 이 함수 호출로부터 예외를 받을 일이 원천적으로 없어지고, `payment_ledger` INSERT가 KDS 쪽 오류로 인해 함께 롤백되는 경로 자체가 봉쇄된다. 상세 설계는 `601032_Logic.md` §1/§3.

## §3 `CAPACITY_CHECKING` 재시도 메커니즘 — 존재 여부 확인 및 스코프 판단 근거

**라이브 재확인 결과: 재시도 메커니즘이 전혀 없다.**

- `bulk_commit_kds_tickets()`(`0039`)의 SQL 레벨 호출자를 전수 검색한 결과 **0건**(정의/GRANT/주석 줄만 매치) — `commit_kds_ticket()`과 동일한 고아 함수 상태다.
- `pg_cron`/`cron.schedule(...)` 전체 사용처를 확인한 결과, KDS/capacity/bulk_commit 관련 스케줄 작업은 **0건**(`0072_create_pg_cron_schedules.sql`의 유일한 `cron.schedule(` 호출은 무관한 작업).
- 즉 어떤 티켓이 `CAPACITY_CHECKING`에 머물게 되면, 지금 시점에는 **아무것도 그 티켓을 다시 확인하지 않는다** — 주방 담당자가 수동으로 뭔가를 누르지 않는 한(그런 UI/RPC가 있는지도 SQL 레이어에서는 확인 불가, §5 스코프 한정) 영원히 `CAPACITY_CHECKING`에 머문다.

**스코프 판단 근거**: 재시도 메커니즘(주기적 재평가, 또는 주방 여유 발생 시 이벤트 기반 트리거)을 설계하려면 (1) 폴링 주기/트리거 조건 결정, (2) `pg_cron` 신규 작업 등록, (3) 스토어별/전체 스캔 방식 결정 등 **이번 워크패킷(결제확인→KDS 방출 배선)과는 다른 차원의 설계**가 필요하다. 이번 워크패킷의 핵심은 "결제 확인 시점에 게이트를 1회 정확히 통과시키는 것"이며, "그 이후 상황이 바뀌었을 때 재평가하는 것"은 별개 문제다 — 오늘 이 세션이 반복 적용한 "다른 개념이면 쪼갠다" 원칙을 그대로 적용하면 **분리 대상**이다. 이번 워크패킷은 재시도 메커니즘을 설계하지 않고, `CAPACITY_CHECKING` 상태가 "정상적으로 도달 가능하지만 이번 워크패킷 이후에도 여전히 해소 방법이 없는 상태"임을 Open Item으로 명시한다(§6 (a)).

## §4 신규 함수의 스키마 위치 — `catchmenu_payment` (근거)

**결정 근거**: 이미 존재하는 정확히 같은 성격의 선례가 있다 — `release_kds_after_payment()`(`0098`이 호출, `0157`이 최근 재설계)는 KDS 테이블(`kds_tickets`)을 직접 UPDATE하는 함수이면서도 `catchmenu_kds`가 아니라 **`catchmenu_payment`**에 위치한다. 이 코드베이스의 기존 관례는 "이 함수가 어느 테이블을 건드리는가"가 아니라 **"이 함수를 누가, 어떤 계기로 호출하는가"**로 스키마를 결정한다 — `release_kds_after_payment()`는 결제 확인이 계기이므로 `catchmenu_payment`, `commit_kds_ticket()`/`bulk_commit_kds_tickets()`는 KDS 운영(주방 화면 조작 등)이 계기가 될 수도 있어 `catchmenu_kds`에 남아있다.

신규 함수 `request_kds_release_after_payment()`도 정확히 `release_kds_after_payment()`와 동일한 성격(결제 확인이 유일한 계기, "payment→kds" 방향의 단방향 오케스트레이션)이므로 **`catchmenu_payment`**에 배치하는 것이 기존 관례와 가장 잘 맞는다 — 이름도 `release_kds_after_payment()`와 짝을 이루는 형태(`request_` 접두어로 "요청은 하되 즉시 확정을 보장하지 않는다"는 `CAPACITY_CHECKING` 가능성을 이름에서부터 구분).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- `confirm_payment()`(`0098`)는 손대지 않음 — Open Item으로만 기록(§6 (b)).
- `resolve_payment_uncertain()` 관련 작업 안 함.
- `bulk_commit_kds_tickets()`의 실제 UI/Flutter 호출자 존재 여부는 SQL 레이어 조사 범위 밖(§3에서 SQL 레벨 0건만 확인).
- `CAPACITY_CHECKING` 재시도 메커니즘 설계 안 함(§3).
- `start_cooking()`의 호출자 부재(`601024_ChangeContract.md` §5.4) — 별개, 참고만.

## §6 Open Items

**(Stage 4 Critical tier — Cursor+Codex 지적사항 반영, `601032_Logic.md` §6과 완전히 동일한 목록을 공유하도록 정리함)**

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 이번 워크패킷 이후에도 미해소, 별도 워크패킷 후보(가칭 `kds_capacity_retry_scheduler`).
(b) `confirm_payment()`(POS, `0098`)를 동일한 신규 공용 함수로 연결 — 최우선 후속 워크패킷 후보로 명시 기록(Human 방향 결정 §0.2 (3) 재확인).
(c) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — `600591_Overview.md` §4에서 이미 별도 워크패킷 권고, 이번에도 재확인.
(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정.
(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오에서의 신규 함수 동작 확인 필요성 — 상세 설계는 `601032_Logic.md` §4. **격상 근거**: Cursor와 Codex 둘 다 독립적으로 "이번 워크패킷 스코프 제외 자체는 타당하나, 실제 운영 환경에서의 위험도는 낮지 않다"고 지적했다 — Toss/VAN이 동일 웹훅을 재전송하는 것은 드문 예외가 아니라 정상적으로 발생하는 시나리오이며, §1.2의 0-티켓 `result_code` 수정(item 1)이 바로 이 시나리오와 직접 연관된 방어 조치였다는 사실 자체가 멱등성 문제의 실질적 위험도를 뒷받침한다. 스코프에서는 제외하되, 후속 워크패킷 우선순위를 (b)보다 낮지 않게 배정할 것을 권고.
(f) **[번호 관련]** `600500_payment_confirmation/` 도메인의 "백단위" 번호 공간이 사실상 소진됐다(§0) — 향후 이 도메인에 워크패킷이 더 필요하면 매번 `601020`류의 "번호 차용" 판단이 반복될 것. 도메인 번호 재편(예: 601000대의 별도 서브도메인 확정) 여부는 Human 결정 필요, 이 워크패킷 범위 밖.
(g) `601032_Logic.md` §3의 `pg_temp` 라이브 재현 3건(정상 경로/KDS 예외/0-티켓)은 **이 세션이 직접 수행**한 것이지만, "이 세션이 검증을 완료했다"는 것이 "Stage 5(TestPlan)/Stage 8-9(구현·독립검증)가 자체 재현을 생략해도 된다"는 뜻은 아니다 — 각 Stage는 자기 자신의 새 fixture로 동일 시나리오를 독립적으로 재현해 확인해야 한다(이 세션의 결과를 그대로 재신뢰 금지). Stage 4 Critical tier가 지적한 §3/§6/Snapshot 간 표현 불일치를 해소하며 신설된 항목.

(h) **[신규, 2026-07-18, `p_decision='PENDING'` 결함 수정 중 부수적으로 발견 — canonical 위치는 `601034_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `catchmenu_audit.append_audit_record()`를 호출하는 다른 기존 라이브 함수 **7개 파일**에서도 `chk_audit_decision`(`0008:105-119`)의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — 리터럴 개수로는 **8개**(타겟 grep 기준 — 전수조사 아님, 그 이상일 수 있음): `0084`(`'RESOLVED'`), `0085`(`'PUBLISHED'`), `0086`(`'PUBLISHED'`), `0087`(`'ROLLED_BACK'`), `0091`(`'GO_LIVE_AUTHORIZED'`), `0098`(`'REFUND_PENDING'`), `0100`(같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개 — 이 파일이 리터럴 수를 파일 수보다 1개 더 많게 만드는 원인). 실행되면 이번 워크패킷에서 고친 것과 동일한 방식(제약 위반 → INSERT 크래시)으로 실패할 가능성이 높다. 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며, 별도의 독립 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 최신·상세 버전은 `601034_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `601034`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `601032_Logic.md`로 이어짐.** 번호 배정 과정에서 `600500` 도메인의 자체 백단위 공간이 소진됐음을 발견하고, 이미 확립된 `601020` 선례(물리적 폴더 위치와 문서 번호의 백단위가 다를 수 있음)를 그대로 적용해 `601030`대로 재배정했다(§0). `evaluate_kds_capacity()`/`commit_kds_ticket()`/`bulk_commit_kds_tickets()` 정확한 라이브 시그니처·반환 계약을 재확인했고(§1), `commit_kds_ticket()` 자신이 이미 `CAPACITY_CHECKING`을 `success:true`로 취급하는 설계임을 확인해 §2 원칙(결제확정 성공≠KDS 방출 실패)이 신규 함수의 예외 미전파 설계로 이어져야 함을 근거와 함께 제시했다. `CAPACITY_CHECKING` 재시도 메커니즘이 SQL/cron 레벨에서 전혀 존재하지 않음을 실증했고(§3), 이를 근거로 이번 워크패킷 범위에서 제외하도록 권고했다. 신규 함수의 스키마 위치는 `release_kds_after_payment()`의 기존 선례("호출 계기" 기준)를 근거로 `catchmenu_payment`로 결정했다(§4).

**(Stage 4 Critical tier 정정 반영, 2026-07-18)** Cursor+Codex 검토에서 지적된 3가지 결함을 `601032_Logic.md`에서 해소했다 — 0-티켓 시나리오(committed=pending=skipped=0)를 `PAYMENT_CONFIRMED_KDS_COMMITTED`와 명확히 구분하는 신규 `result_code`(`PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`)를 추가하고 `pg_temp`로 재검증했으며, `confirm_payment_from_provider()` 반환값의 `kds_release_authorized` 하드코딩을 `result_code` 파생 값으로 교체했다. 웹훅 멱등성 Open Item을 **High priority**로 격상했고(§6 (e)), 이 문서와 `601032_Logic.md`의 §6 Open Items 목록을 (a)-(g) 동일 목록으로 동기화했다.
