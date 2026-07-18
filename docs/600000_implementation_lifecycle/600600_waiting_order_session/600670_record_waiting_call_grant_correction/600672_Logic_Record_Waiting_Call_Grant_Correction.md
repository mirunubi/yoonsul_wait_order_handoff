# 600672_Logic_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 설계 원칙 요약

`600671_Overview.md`의 확인 결과를 그대로 적용한다: (1) `_record_waiting_call()`은 완전 내부 전용 — `REVOKE ALL FROM PUBLIC`만, `authenticated`에도 GRANT하지 않는다(§1). (2) `call_next_waiting_customer()`는 역할상 `call_waiting_customer()`와 동등한 공개 진입점이지만, ACL은 `call_waiting_customer()`의 현재(불완전한) 상태를 복제하지 않는다 — `0163`의 REVOKE 문 형태(내부 헬퍼용 선례)와 `0050`의 공개 RPC용 GRANT 선례(`0050:714-719`)를 결합한 `REVOKE ALL FROM PUBLIC` + `GRANT EXECUTE TO authenticated` 패턴을 신규 적용한다(§2) — `0163` 자신은 REVOKE-only이며 `GRANT` 문을 포함하지 않는다. (3) `call_waiting_customer()`는 `authenticated` GRANT는 정상이나 `PUBLIC`이 한 번도 REVOKE된 적 없는 별도 성격의 갭이 있다 — 이번 워크패킷에서는 수정하지 않는다(§3). (4) `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했고, 그 함수의 ACL 교정만 범위 밖이다 — 이번 워크패킷도 손대지 않는다(§5).

## §1 `catchmenu_pos._record_waiting_call(...)` — REVOKE-only (완전 내부 전용)

### §1.1 실제 호출자 재확인 — `0160` 파일 내 정확히 2곳

```sql
-- 0160:226 (call_waiting_customer 내부)
return catchmenu_pos._record_waiting_call(...);

-- 0160:289 (call_next_waiting_customer 내부)
return catchmenu_pos._record_waiting_call(...);
```

파일 전체(`grep -n "_record_waiting_call"`) 재확인 결과 이 2곳 외 다른 호출자는 없다 — `_resolve_dining_table_by_number()`(`0163`)와 정확히 동일한 성격("같은 파일 내 신규 공개 함수 2곳에서만 호출되는 내부 헬퍼")이므로 그 선례를 그대로 적용한다.

### §1.2 GRANT/REVOKE 문 (신규 migration에 추가)

```sql
revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;
```

**파라미터 타입 목록은 `0160:37-54`의 실제 시그니처 순서를 그대로 따른다**: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_from_status text, p_wait_number int, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_has_pre_order boolean, p_pre_order_amount int, p_table_number text, p_expires_at timestamptz, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text` — 16개 전부 스칼라 타입, `record`/복합 타입 없음(`600671_Overview.md` §5.1 재확인).

`GRANT EXECUTE ... TO authenticated`는 추가하지 않는다 — `0163`의 `_resolve_dining_table_by_number()` 선례와 동일하게 `REVOKE`만으로 충분하다(`security definer`이므로 내부 호출자는 이 REVOKE와 무관하게 호출 가능).

## §2 `catchmenu_pos.call_next_waiting_customer(...)` — REVOKE + GRANT authenticated (공개 진입점)

### §2.1 GRANT/REVOKE 문 (신규 migration에 추가)

```sql
revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;
```

**파라미터 타입 목록**: `0160:240-246`의 실제 시그니처(`p_tenant_id uuid, p_store_id uuid, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`) — 5개, 전부 스칼라. `default` 절은 `REVOKE`/`GRANT` 문에는 영향을 주지 않는다(타입 목록만 일치하면 된다).

### §2.2 설계 근거 재확인 (`600671_Overview.md` §3의 3가지 증거 요약)

1. `600642_Logic.md` §2 Q1 결정 본문: "`call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출)를 별도 함수로 유지" — "두 개의 공개 함수"라는 정확한 문구 자체는 같은 문서 **§1.1(L21)**에 있다("Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로...").
2. 전신 `0050.call_next_waiting()`이 이미 `revoke all ... from public; grant execute ... to authenticated;`를 받고 있었다(`0050:714-719`).
3. `p_actor_type := 'STAFF'` 하드코딩(`0160:298`) — 사람(직원)이 직접 트리거하는 액션을 의미하는 이 코드베이스의 관례.

이 세 근거가 함께 `call_next_waiting_customer()`를 `_record_waiting_call()`과 다른 카테고리(공개 진입점)로 분류한다 — 단순히 "형제 결함이니 같은 패턴"으로 기계적으로 처리하지 않고, 각 함수의 실제 역할을 개별 판단한 결과다(사용자 지시사항 "확정된 범위" §2의 명시적 요구).

## §3 `catchmenu_pos.call_waiting_customer(...)` — 수정 없음(단, 완전히 안전한 상태는 아님)

`0115:1741-1744`에서 부여된 `authenticated` GRANT가 시그니처 불변 덕에 `0160`의 `CREATE OR REPLACE`까지 그대로 보존됐다(`600671_Overview.md` §4, 라이브 마이그레이션 이력으로 확정). **다만 같은 확인 결과, `PUBLIC`에 대한 `REVOKE`는 `0115`를 포함해 어떤 마이그레이션에서도 실행된 적이 없다** — `authenticated` GRANT와 무관하게 `PUBLIC`(및 `anon`)도 여전히 이 함수를 직접 호출할 수 있는 상태다. 이는 `call_next_waiting_customer()`/`_record_waiting_call()`의 결함(애초에 어떤 GRANT/REVOKE도 없이 신규 생성됨)과는 다른 범주 — `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리한다(`600671_Overview.md` §7 (e)). 따라서 이 함수는 이번 워크패킷에서 어떤 SQL 문도 추가/수정하지 않는다 — Stage 8 구현은 이 함수 정의 자체를 다시 선언(`CREATE OR REPLACE`)할 필요조차 없다(신규 migration은 §1.2/§2.1의 GRANT/REVOKE 문만 포함, 기존 함수 재선언 불필요).

## §4 마이그레이션 배치 (Stage 5/8 대상, 이번 문서는 설계만)

- Stage 5에서 `sql/migrations/` 다음 사용 가능 번호를 재확인해 확정한다(이 문서 작성 시점 기준 `0166`이 최신이나, `601034_ChangeContract.md` §14.5 Draft Migration 판단 대상이므로 이 워크패킷의 번호는 그와 무관하게 별도로 다음 순번을 확정해야 한다).
- 신규 migration은 `catchmenu_pos._record_waiting_call(...)`/`catchmenu_pos.call_next_waiting_customer(...)`에 대한 `REVOKE`/`GRANT` 문만 포함한다 — 두 함수의 본문(`CREATE OR REPLACE FUNCTION`)은 재선언하지 않는다(함수 로직 자체는 변경 대상이 아니므로, `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14 Operation Granularity Rule에 따라 GRANT/REVOKE만 최소 범위로 추가).
- `call_waiting_customer(...)`는 신규 migration에 어떤 문도 포함하지 않는다(§3).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`) 자체(파라미터 기본값)는 이미 `601140`이 수정했다 — 이번 워크패킷이 손대지 않는 것은 오직 그 함수의 ACL 교정뿐이며, `601140`이 이미 그 부분을 범위 밖으로 남긴 결정을 뒤집지 않는다(`600671_Overview.md` §2/§7 (a)).
- `call_waiting_customer()`의 `PUBLIC` REVOKE 누락은 별도 성격의 문제로 이번 워크패킷 범위 밖이다(§3, §6 (e)).
- `call_next_waiting_customer()`의 최종 명칭 확정, 실호출자 배선(Flutter/다른 RPC), 재시도/스케줄링 로직 설계는 다루지 않는다.
- 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§6 (b)).

## §6 Open Items (`600671_Overview.md` §7과 동일한 (a)-(e) 목록을 공유)

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — **정확한 구분**: `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했다. 범위 밖으로 남은 것은 오직 그 함수의 ACL(REVOKE/GRANT) 교정뿐이다. 별도 워크패킷 후보(가칭 `menu_core_grant_correction`), 이번 워크패킷 범위 밖.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료: `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL, `call_waiting_customer()`는 `authenticated=X/postgres`(GRANT)와 `=X/postgres`(PUBLIC EXECUTE 잔존)가 동시에 존재. 이 세션도 Docker 재연결 후 동일 쿼리로 독립 재확인해 일치를 확인했다(`600671_Overview.md` §7 (b) 상세).

(c) `call_next_waiting_customer()`의 실호출자 0건(고아 함수) — GRANT 부여 후에도 배선 전까지는 도달 불가능한 상태로 남는다. 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 "(가칭)" 명칭 미확정 — 이번 워크패킷은 다루지 않는다.

(e) **[신규, Stage 4 Critical tier 지적 반영]** `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE된 적 없다(§3) — `authenticated` GRANT와 별개의 보안 공백. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보로 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계 완료.** `_record_waiting_call()`은 `0163`의 `_resolve_dining_table_by_number()` 선례를 그대로 따라 `REVOKE ALL FROM PUBLIC`만 적용한다(§1) — 실제 16개 파라미터 전부가 스칼라 타입이라 문법적 문제가 없음을 확인했다. `call_next_waiting_customer()`는 형제 결함(같은 파일, 같은 원인)이지만 기계적으로 동일 패턴을 적용하지 않고 3가지 독립 근거(Human 결정 Q1, `0050` 전신의 실제 GRANT 이력, `p_actor_type='STAFF'` 하드코딩)로 "공개 진입점"임을 확정해 `0163`의 REVOKE 문 형태와 `0050`의 공개 RPC용 GRANT 선례를 결합한 패턴을 신규 적용하기로 설계했다(§2) — `call_waiting_customer()`의 현재(불완전한) ACL 상태를 복제하는 것도, `0163` 하나만으로 완전한 패턴을 확립하는 것도 아니다. `call_waiting_customer()` 자신은 `0115`에서 부여된 `authenticated` GRANT가 시그니처 불변으로 보존되어 왔음을 라이브 이력으로 확정했으나, 동시에 `PUBLIC`이 한 번도 REVOKE된 적 없다는 별도의 갭도 발견했다 — 이는 "형제 결함"과 다른 범주(레거시 관행)로 판단해 수정 대상에서 명시적으로 제외했다(§3, §6 (e)). `upsert_menu_core()` **자체**(파라미터 기본값)는 `601140`이 이미 수정했고, 범위 밖으로 남은 것은 그 함수의 ACL 교정뿐임을 `601144_ChangeContract.md`를 직접 재확인해 명확히 구분했다(§5, §6 (a)). 라이브 `pg_proc.proacl` 재확인은 Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§6 (b)). `.sql` 파일은 생성·수정하지 않았다.

**(2차 정정, 2026-07-18, Cursor+Codex 재검증)** 4가지 신규/잔존 불일치를 해소했다 — (1) [최우선] "`0163`이 완전한 REVOKE+GRANT를 확립했다"는 서술을 "`0163`의 REVOKE 문 형태 + `0050:714-719`의 공개 RPC용 GRANT 선례를 결합"으로 정정했다(§0/§2) — `_record_waiting_call()`은 여전히 `0163`의 REVOKE-only 패턴 그대로다(변경 없음). (2) `600671_Overview.md` §1.2 재확인 인용 위치를 정확한 하위섹션(`§5.1`)으로 정정했다. (3) §2.2의 "`600642_Logic.md` §2 Q1 결정" 인용에서, Q1 결정 본문은 §2가 맞지만 "두 개의 공개 함수" 정확한 문구는 §1.1(L21)에 있음을 구분해 명시했다. (4) Open Item (b)를 "Docker 연결 실패로 미완료"에서 "해소됨"으로 갱신했다 — Cursor+Codex 라이브 확인 결과를 이 세션도 Docker 재연결 후 독립적으로 재확인했다.
