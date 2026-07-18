# 600671_Overview_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 번호 확인 (라이브/인덱스 재확인)

`600600_waiting_order_session/` 산하 기존 워크패킷은 `600610`/`600620`/`600630`/`600640`/`600650`/`600660` 6개다 — 다음 "10단위" 슬롯 `600670`이 `docs/000005_Index_Document_Number.md`와 물리적 디렉터리 양쪽에서 미사용임을 재확인했다(`grep`/`ls` 0건). 이 도메인의 자체 백단위 공간(`600600`-`600699`)이 아직 소진되지 않았으므로, 이전 여러 워크패킷(`601020`/`601030`)에서 반복됐던 "다른 백단위 차용" 절차는 이번엔 필요 없다. 폴더 `600670_record_waiting_call_grant_correction/`, Overview `600671`, Logic `600672`로 배정한다.

## §1 배경 (Cursor 전수조사 완료, 재확인 불필요 — 단, GRANT 부재 자체는 정적 재확인함)

`sql/migrations/0160_call_waiting_customer_contract_recovery.sql` 파일 전체를 재확인한 결과(`grep -in "revoke\|grant" 0160...sql` → **0건**), 이 파일은 `REVOKE`/`GRANT` 문을 단 하나도 포함하지 않는다 — Cursor의 전수조사 결과와 일치. 이 파일이 생성/재선언하는 3개 함수의 현재 권한 상태:

| 함수 | 0160 내 REVOKE/GRANT | 현재 권한 상태(§7 (b), 2026-07-18 라이브 재확인 완료) |
|---|---|---|
| `catchmenu_pos._record_waiting_call(...)` | 없음(신규 CREATE) | `proacl` NULL 확정 — 한 번도 명시적 GRANT/REVOKE가 적용된 적 없어 PostgreSQL 스키마 기본 권한(PUBLIC EXECUTE) 그대로다. |
| `catchmenu_pos.call_next_waiting_customer(...)` | 없음(신규 CREATE) | 위와 동일 — `proacl` NULL 확정. |
| `catchmenu_pos.call_waiting_customer(...)` | 없음(`CREATE OR REPLACE`, 시그니처 불변) | **부분적 — `authenticated` GRANT는 있으나 `PUBLIC`이 한 번도 REVOKE된 적 없음**(§4에서 출처를 라이브 마이그레이션 이력으로 역추적 확정, 단 별도 성격의 결함으로 이번 워크패킷 범위 밖). |

**(2026-07-18 갱신 — 해소됨)** 라이브 `pg_proc.proacl` 직접 재확인은 이전 초안 작성 시점에 Docker 연결 실패로 완료하지 못했으나, 이후 Cursor+Codex가 라이브로 확인을 완료했고 이 세션도 Docker 재연결 후 독립적으로 재확인했다 — `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL(추정이 확정으로 전환), `call_waiting_customer()`는 `authenticated` GRANT와 `PUBLIC` EXECUTE 잔존이 동시에 확인됐다(§7 (b) 상세).

## §2 601140의 유사 사례와의 대조 — "proacl NULL이 실제 위험인가"

`601140_allergen_info_and_sibling_overwrite_correction` 워크패킷이 정확히 같은 유형의 문제를 다룬 선례다: Codex가 `upsert_menu_core()`의 `pg_proc.proacl`이 NULL임을 라이브로 확인했고(`601142_Logic.md` §1.2), 그 근거로 "wrapper(`upsert_menu()`)를 우회해 내부 헬퍼를 직접 호출할 수 있다"는 위험을 명시했다. **다만 그 워크패킷은 이 ACL 갭 자체를 닫는 REVOKE/GRANT 문을 실제로 추가하지 않았다** — `601144_ChangeContract.md` §3(Allowed Operations)을 직접 재확인한 결과, 승인된 변경은 `upsert_menu()`/`upsert_menu_core()`의 파라미터 기본값(default) 교정과 카테고리 `display_order` 로직뿐이며, ACL 문 추가는 그 목록 어디에도 없다 — proacl=NULL 사실은 "기본값 교정이 방어적 권장이 아니라 필수"라는 논거로만 쓰였을 뿐, ACL 자체를 닫는 작업은 명시적으로 이 워크패킷의 범위 밖으로 남았다. 이것이 이번 워크패킷의 배경에서 인용한 "601140이 이미 'proacl/REVOKE 추가는 Allowed Operations에 없음'이라고 결정한 사항"의 정확한 근거이며, 이번 워크패킷은 이 결정을 뒤집지 않는다(§6 스코프, §7 Open Item).

## §3 `call_next_waiting_customer()`의 설계 의도 — 순수 내부용이 아니라 "두 번째 공개 진입점"

**결론(라이브 설계문서 확인 완료)**: `call_next_waiting_customer()`는 순수 내부/배치 전용 함수가 아니라, `call_waiting_customer()`와 함께 "의도적으로 역할이 분리된 두 개의 공개(public) 진입점" 중 하나로 Human이 명시적으로 결정한 것이다.

**증거 1 — Human 결정 원문**(`600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` §2, "Q1 결정 요약", 재논의 금지로 이미 확정된 사항): "자동 큐 선택 기능은 병합하지 않는다. `call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭)를 **별도 함수로 유지**하되, 공통 로직(호출 기록/이벤트/알림)은 **내부 헬퍼**로 공유한다." 같은 문서 §1.1(L21)은 두 함수를 명시적으로 "두 개의 공개 함수"로 지칭하며("Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로..."), §2.1 도입부(L68)는 이를 "각 공개 함수(§2.2/§2.3)"로 재확인한다 — 오직 `_record_waiting_call()`만 "internal 헬퍼"로 구분된다.

**증거 2 — 레거시 전신의 실제 GRANT**: `call_next_waiting_customer()`는 `0050_create_waiting_queue_rpc.sql`의 `call_next_waiting()`(자동 선택 로직, `0160`에서 DROP됨)을 그대로 계승한다(`0160`의 자체 주석: `"0050:194-211 원문 로직 그대로"`, `600642_Logic.md` §2.3 표: `"0050.call_next_waiting()의 자동 선택 로직 이식"`). 라이브 재확인 결과, `0050:714-719`에서 그 전신 함수는 이미 명시적으로 `revoke all ... from public; grant execute ... to authenticated;`를 받고 있었다 — 즉 원래 설계 의도부터 `authenticated`가 직접 호출 가능한 공개 RPC였다.

**증거 3 — `p_actor_type` 하드코딩**: `call_next_waiting_customer()` 본문(`0160:298`)은 `p_actor_type := 'STAFF'`를 하드코딩한다 — 이 코드베이스 전반에서 `'STAFF'` 액터 타입은 일관되게 "사람(직원)이 직접 트리거한 액션"을 의미하며(예: `mark_no_show()`의 수동 경로 등), 순수 자동/배치 전용 함수라면 `'SYSTEM'`을 쓰는 것이 이 코드베이스의 다른 배치 함수들(`0118` cron 등)과의 관례에 맞다.

**결론에 대한 반대 증거는 없음**: 현재 라이브 SQL/Flutter 어디에도 `call_next_waiting_customer()`의 실제 호출자가 없다(고아 함수 상태, `600642_Logic.md` §2.4가 이미 확인한 사실 — "실호출자 0건"). 하지만 이는 "아직 배선되지 않았다"는 뜻이지 "내부 전용으로 설계됐다"는 뜻이 아니다 — 이 코드베이스에는 `bulk_commit_kds_tickets()`처럼 완성됐지만 아직 호출자가 배선되지 않은 공개 RPC가 이미 여러 건 확인된 바 있다(`601031_Overview.md` §3 등, 다른 워크패킷).

**따라서**: `call_next_waiting_customer()`는 `_resolve_dining_table_by_number()`(순수 내부, REVOKE-only) 패턴이 아니라 공개 진입점으로 취급해야 한다. **다만 이를 "`call_waiting_customer()`와 동일한 패턴을 적용한다"고 표현하는 것도, "`0163`이 확립한 완전한 패턴을 적용한다"고 표현하는 것도 둘 다 부정확하다** — `call_waiting_customer()`의 현재 상태는 §4에서 확인했듯 `GRANT`만 있고 `PUBLIC` `REVOKE`는 없는 **불완전한** 상태다. **`0163`은 REVOKE-only 선례일 뿐이다**(§5 — `_resolve_dining_table_by_number()`에 `GRANT` 문 자체가 없다, 내부 헬퍼용 패턴). 실제로 `REVOKE`+`GRANT`가 둘 다 있는 "완전한 공개 RPC" 선례는 `0050:714-719`(`call_next_waiting()`, §5.2 재확인)다. `call_next_waiting_customer()`에는 두 선례를 결합한 패턴 — `0163`의 REVOKE 문 형태 + `0050`의 공개 RPC용 GRANT 문 — 을 새로 적용한다(§5.1/§5.2/§6).

## §4 `call_waiting_customer()`의 현재 GRANT 출처 — 라이브 이력으로 확정(추정 아님), 그러나 완전히 안전하지는 않음

`call_waiting_customer()`는 `0115_create_waiting_pipeline_rpc.sql`에서 최초 생성됐다(`600642_Logic.md` §2.4 표: `"0115:419-599"`). `0115:1741-1744`를 직접 확인한 결과:

```sql
grant execute on function
  catchmenu_pos.call_waiting_customer(
    uuid, uuid, uuid, text, uuid, text, text
  ) to authenticated;
```

이 시그니처(`uuid, uuid, uuid, text, uuid, text, text` — 7개 파라미터)는 `0160`이 재선언한 `call_waiting_customer()`의 시그니처(`p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text default null, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`)와 타입 순서가 정확히 일치한다 — PostgreSQL은 `CREATE OR REPLACE FUNCTION`이 시그니처(파라미터 타입 목록)를 바꾸지 않는 한 기존 함수의 ACL(`proacl`)을 그대로 보존한다. 즉 `call_waiting_customer()`가 현재 `authenticated` 실행 권한을 갖고 있는 것은 우연이 아니라 `0115`에서 부여된 권한이 이후 모든 `CREATE OR REPLACE`(`0160` 포함, 그 사이 어떤 마이그레이션도 시그니처를 바꾸지 않음)를 통해 그대로 보존되어 온 것이다. **"추정"이 아니라 라이브 마이그레이션 이력으로 확정**된 사실이다.

**(Stage 4 Critical tier 정정)** 다만 이 사실만으로 "이미 안전하다"고 결론짓는 것은 부정확하다 — `0115:1732-1781`의 전체 grants 블록을 재확인한 결과, `call_waiting_customer()`를 포함해 이 블록이 부여하는 9개 함수 전부에 대해 `grant execute` 문만 있을 뿐 **`revoke all ... from public` 문이 단 하나도 없다**(파일 전체 `grep -in "revoke"` 재확인, 0건). 그리고 이 코드베이스 전체에서 `call_waiting_customer()`에 대한 `revoke`가 이후 어떤 마이그레이션에서도 실행된 적이 없다(`grep -rn "call_waiting_customer" sql/migrations/*.sql | grep -i revoke` → 0건). 즉 `call_waiting_customer()`는 `authenticated`에 명시적으로 GRANT돼 있으면서 **동시에 `PUBLIC`도 여전히 EXECUTE 권한을 갖고 있다**(PostgreSQL이 함수 생성 시 기본으로 `PUBLIC`에 EXECUTE를 부여하고, 명시적으로 REVOKE하지 않는 한 그대로 남는다) — 이는 `anon`을 포함한 어떤 역할이든 이 함수를 직접 호출할 수 있다는 뜻이며, 그 자체로 별도의 보안 공백이다.

**이번 워크패킷 범위에서 제외하는 이유**: 이 갭은 `call_next_waiting_customer()`/`_record_waiting_call()`의 결함(애초에 `0160`에서 어떤 GRANT/REVOKE도 없이 신규 생성된, "처음부터 잘못 설계된" 경우)과 성격이 다르다 — `call_waiting_customer()`의 경우는 `0115` 작성 당시 이 코드베이스의 여러 함수에 공통적으로 나타나는 "GRANT는 명시하되 PUBLIC REVOKE는 생략하는" 레거시 관행에 가깝다(같은 grants 블록의 나머지 8개 함수도 동일 패턴). 이는 이번 워크패킷이 다루는 "형제 결함"(같은 파일, 같은 원인)과는 다른 별도 범주의 문제이므로, 이번 워크패킷의 스코프에서 명시적으로 분리하고 별도 hardening 워크패킷 후보로 남긴다(§7 신규 Open Item).

## §5 두 종류의 GRANT/REVOKE 선례 — 각각 정확한 출처로 재확인 (Stage 4 Critical tier 정정)

**(정정, 2026-07-18)** 이전 초안은 "`0163`이 REVOKE+GRANT 완전 패턴을 확립했다"고 잘못 서술했다 — `0163`은 REVOKE-only 선례만 확립했을 뿐, `GRANT` 문 자체가 없다. 완전한 REVOKE+GRANT(공개 RPC용) 선례는 `0050`이다. 두 선례를 각각 정확히 재확인한다.

### §5.1 REVOKE-only 선례 — `0163`(`_resolve_dining_table_by_number()`, 내부 헬퍼용)

`600650_seat_waiting_customer_facade_correction`(`0163`)이 순수 내부 헬퍼 `_resolve_dining_table_by_number()`에 적용한 패턴을 라이브로 재확인했다(`0163:404-406`):

```sql
revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;
```

`GRANT`문 없이 `REVOKE ALL ... FROM PUBLIC`만 있다 — 이 패턴은 `REVOKE`/`GRANT` 대상 함수의 파라미터 타입 목록만 정확히 나열하면 되는 순수 문법이며, 파라미터 개수나 타입(스칼라 전용, `record`/복합 타입 없음)에 따른 제약이 전혀 없다. `_record_waiting_call()`의 16개 파라미터(전부 스칼라: `uuid`/`text`/`int`/`boolean`/`timestamptz`)에 그대로 적용 가능함을 확인했다 — 문법적 장애 없음. **`_record_waiting_call()`은 이 REVOKE-only 패턴 그대로를 적용한다 — 정정 대상 아님.**

### §5.2 REVOKE+GRANT 완전 선례 — `0050`(`call_next_waiting()`, 공개 RPC용)

`0050_create_waiting_queue_rpc.sql:714-719`를 직접 재확인했다(원문 그대로):

```sql
revoke all on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) from public;
grant execute on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) to authenticated;
```

`REVOKE ALL FROM PUBLIC` 다음 `GRANT EXECUTE TO authenticated`가 이어지는 완전한 조합이다 — 이 함수가 바로 `call_next_waiting_customer()`의 전신(§3 증거 2)이므로, `call_next_waiting_customer()`에 적용할 정확한 선례는 `0163`이 아니라 이 `0050` 패턴이다(§6).

## §6 확정된 범위

1. `_record_waiting_call()` — `0163`의 `_resolve_dining_table_by_number()` 선례 그대로: `REVOKE ALL ... FROM PUBLIC`만, `authenticated`에도 GRANT하지 않는다(완전 내부 전용 — 실제로 `0160` 파일 내 2곳: `call_waiting_customer()`/`call_next_waiting_customer()`에서만 호출됨을 재확인).
2. `call_next_waiting_customer()` — `0163`의 REVOKE 문 형태(§5.1)와 `0050`의 공개 RPC용 GRANT 선례(§5.2)를 결합한 `REVOKE ALL ... FROM PUBLIC` + `GRANT EXECUTE ... TO authenticated` 패턴을 신규 적용한다(§3의 설계 의도 판단에 따름). `call_waiting_customer()`의 현재 상태(GRANT만 있고 PUBLIC REVOKE 없음, §4)를 그대로 복제하는 것이 **아니다** — 이 함수보다 더 완전한 패턴을 새로 적용하는 것이다.
3. `call_waiting_customer()` — **수정 없음**. `authenticated` GRANT는 정상 존재하나, `PUBLIC`이 한 번도 REVOKE된 적 없는 별도의 보안 공백이 있다(§4) — 이는 "레거시 관행"에 가까운 다른 성격의 문제로 판단해 이번 워크패킷 범위에서 명시적으로 제외한다(§7 신규 Open Item).
4. `upsert_menu_core()`/`sync_menu_option_*_core()` 계열(`0110`) — **함수 자체는 `601140`의 핵심 수정 대상이었다**(파라미터 기본값 교정). 이번 워크패킷이 범위 밖으로 두는 것은 오직 그 함수의 **ACL(REVOKE/GRANT) 교정 작업**뿐이다 — `601140`도 이 ACL 작업은 명시적으로 제외했었다(§2). Open Item으로만 기록(§7 (a)).

## §7 Open Items

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — **정확한 구분**: `upsert_menu_core()` 자체는 `601140`의 핵심 수정 대상이었다(파라미터 기본값 교정, `601142_Logic.md` §1.2). `601140`이 발견했으나 닫지 않고 범위 밖으로 남긴 것은 오직 그 함수의 **ACL(REVOKE/GRANT) 교정 작업**뿐이다(§2). 별도 워크패킷 후보(가칭 `menu_core_grant_correction`)로 기록. 이번 워크패킷이 이 결정을 뒤집지 않는다.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료했고, 이 세션도 Docker 재연결 후 독립적으로 재확인했다:

```text
_record_waiting_call        | proacl = (NULL, 빈 값)
call_next_waiting_customer  | proacl = (NULL, 빈 값)
call_waiting_customer       | proacl = {=X/postgres,postgres=X/postgres,authenticated=X/postgres}
```

`_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL(§1의 추정이 확정으로 전환) — 명시적 GRANT/REVOKE가 한 번도 적용된 적 없다. `call_waiting_customer()`는 `authenticated=X/postgres`(§4의 GRANT 확정)와 함께 `=X/postgres`(역할명 없는 항목 — `PUBLIC`에 대한 `X`=EXECUTE 권한) 항목이 동시에 존재함을 확인했다 — `PUBLIC` EXECUTE가 여전히 잔존한다는 §4/§7 (e)의 결론과 정확히 일치한다.

(c) `call_next_waiting_customer()`의 실호출자가 현재 0건(고아 함수)이라는 사실 자체는 이번 워크패킷이 해소하지 않는다 — GRANT를 부여해도 실제로 호출할 클라이언트/RPC가 배선되기 전까지는 여전히 도달 불가능한 상태로 남는다. `600642_Logic.md` §6이 이미 이 사실을 기록했고, 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 최종 명칭이 아직 "(가칭)" 상태다(`600642_Logic.md` §6 item 4) — 이번 워크패킷은 이 이름을 그대로 사용하며 명칭 확정 여부를 다루지 않는다.

(e) **[신규, Stage 4 Critical tier 지적 반영]** `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE되지 않은 채 남아있다(§4) — `authenticated` GRANT와 별개로, `anon`을 포함한 임의의 역할이 이 함수를 직접 호출할 수 있는 상태다. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 9개 함수 전부가 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보(가칭 `waiting_pipeline_public_revoke_hardening` 또는 더 넓은 범위의 "0115 grants 블록 전체 PUBLIC REVOKE 감사")로 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `600672_Logic.md`로 이어짐.** `0160` 소스 파일 전체에 `REVOKE`/`GRANT` 문이 전혀 없음을 정적으로 재확인했고(§1), 그 결과 세 함수 중 `_record_waiting_call()`/`call_next_waiting_customer()`는 `proacl` NULL 확정(§7 (b), 2026-07-18 라이브 재확인 완료), `call_waiting_customer()`는 부분적(`authenticated` GRANT는 있으나 `PUBLIC` REVOKE 없음, §4)임을 확인했다. `call_next_waiting_customer()`의 설계 의도를 `600642_Logic.md`의 Human 결정(Q1: "두 개의 공개 함수") + `0050` 전신의 실제 GRANT 이력 + `p_actor_type='STAFF'` 하드코딩 3가지 근거로 "공개 진입점"으로 결론지었다(§3) — `_resolve_dining_table_by_number()`식 완전 내부 전용이 아니다. `0163`의 REVOKE-only 패턴(§5.1)과 `0050`의 REVOKE+GRANT 완전 패턴(§5.2)을 각각 정확한 출처로 재확인했다. `601140`이 `upsert_menu_core()` **자체**(파라미터 기본값)를 이미 수정했고, 범위 밖으로 남긴 것은 그 함수의 ACL 교정뿐임을 `601144_ChangeContract.md` 직접 재확인으로 정확히 구분했다(§2/§7 (a)). 라이브 `pg_proc.proacl` 직접 재확인은 Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§7 (b)).

**(Stage 4 Critical tier 정정 반영, 2026-07-18 — 1차 정정. 이 단락은 정정 이력 기록용이며, 아래 "2차 정정" 단락이 이 단락의 오류를 다시 바로잡았다. 최종 정확한 서술은 본문 §3/§5.1/§5.2/§6을 따를 것.)** Cursor+Codex가 지적한 4가지 서술 부정확성을 이 시점에 해소했다고 판단했다: (1) `call_waiting_customer()`의 "이미 안전하다" 서술을 "`authenticated` GRANT는 있으나 `PUBLIC` REVOKE는 없는 별도의 보안 공백"으로 정정하고 신규 Open Item (e)를 추가했다(§4/§7 (e)) — 이 정정은 이후로도 유효, 변경 없음. (2) ~~`call_next_waiting_customer()`의 GRANT 패턴을 "`call_waiting_customer()`와 동일"이 아니라 "`0163`의 완전한 REVOKE+GRANT 패턴을 신규 적용"으로 정정했다~~ **— 이 서술 자체가 오류였다(0163은 REVOKE-only일 뿐 GRANT 문이 없다). 아래 "2차 정정" 단락에서 다시 바로잡았다 — 최종 서술은 §5.1/§5.2/§3/§6 참고.** (3) "601140에서 upsert_menu_core() 제외" 표현을 "함수 자체는 601140의 핵심 수정 대상이었고, 제외된 것은 그 함수의 ACL 교정 작업뿐"으로 명확히 구분했다(§2/§6/§7 (a)) — 이 정정은 이후로도 유효, 변경 없음. (4) `600642_Logic.md`의 "두 개의 공개 함수" 인용 위치를 "§2.1 도입부"에서 실제 위치인 "§1.1(L21)"로 정정했다(§3) — 이 정정은 이후로도 유효, 변경 없음. **다만 "0160:298 → 0160:297" 정정 요청은 이 세션이 직접 재확인(Read 도구 + `grep -n` 독립 확인 2회)한 결과 `p_actor_type := 'STAFF'`가 실제로 298번째 줄에 있음을 확인해 반영하지 않았다** — 원래 인용(`0160:298`)이 정확하며, 이 불일치를 Human에게 투명하게 보고한다(재확인 요청 시 파일을 다시 확인할 것).

**(2차 정정, 2026-07-18, Cursor+Codex 재검증)** 1차 정정 자체에도 4가지 신규/잔존 불일치가 있었다 — (1) [최우선] "`0163`이 완전한 REVOKE+GRANT를 확립했다"는 서술이 여전히 틀렸다: `0163`은 REVOKE-only(내부 헬퍼용)만 확립했고, `GRANT` 문 자체가 없다 — 실제 완전한 REVOKE+GRANT(공개 RPC용) 선례는 `0050:714-719`(`call_next_waiting()`)다. 두 선례를 정확히 분리해 재서술했다(§5.1/§5.2, §3, §6). `_record_waiting_call()`은 여전히 `0163`의 REVOKE-only 패턴 그대로 유지한다(변경 없음, 원래도 맞았음). (2) §1/§2의 "§8 Open Item" 교차참조 오류를 실제 위치인 "§7"로 정정했다. (3) `600672_Logic.md` §2.2의 "600642_Logic.md §2 Q1 결정" 인용을 `600671_Overview.md`와 일치시켜 "§1.1(L21)"로 정정했다. (4) Open Item (b)를 "Docker 연결 실패로 미완료"에서 "해소됨 — Cursor+Codex 라이브 확인 완료, 이 세션도 Docker 재연결 후 `pg_proc.proacl`을 독립적으로 재확인(`_record_waiting_call`/`call_next_waiting_customer` 둘 다 NULL, `call_waiting_customer`는 `authenticated` GRANT+`PUBLIC` EXECUTE 잔존 동시 확인)"으로 갱신했다(§7 (b)).
