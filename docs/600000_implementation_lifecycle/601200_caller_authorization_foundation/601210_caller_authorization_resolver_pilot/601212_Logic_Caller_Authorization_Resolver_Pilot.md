# 601212_Logic_Caller_Authorization_Resolver_Pilot.md

Status: **Stage 4 완료, Stage 5 이후 보류** — 결정적 선행조건 발견으로 재설계 필요, 후속 Human 결정 대기 (2026-07-18)
Lifecycle: Logic
Stage: 1.5 → 4 완료, Stage 5 착수 보류
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`caller_authorization_resolver_pilot`

## ⚠ 최종 상태 — 이 워크패킷은 여기서 멈춘다 (2026-07-18)

`601211_Overview.md`의 동일 배너 참고. 이 문서(§1/§2)가 설계한 `resolve_store_staff_actor()`와 그 파일럿 적용은 **삭제되지 않았다 — "직원 인증 다리 부재"(§4 (g), 신규 최우선/CRITICAL Open Item, `601211_Overview.md` §8 (f)와 동일 내용)가 해결되기 전까지 구현 보류 상태로 남는다.** 대안(택1) 설계는 오늘 진행하지 않는다.

## §0 설계 원칙 요약

`601211_Overview.md`의 확인 결과를 그대로 적용한다: (1) 이 프로젝트에는 이미 신뢰 가능한 JWT 기반 신원 원시 함수(`catchmenu_common.current_actor_id()`, Supabase `auth.uid()`와 기능적으로 동일)가 존재하며, 신규로 발명하지 않고 재사용한다(§1). (2) `resolve_store_staff_actor()`는 boolean이 아니라 canonical actor context를 반환하는 resolver로 설계한다(§1). (3) 조회의 신뢰 근거는 항상 JWT에서 해석한 값이며, 호출자가 파라미터로 보낸 `requested_actor_id`는 조기 불일치 차단에만 쓰이고 조회 키로는 쓰이지 않는다(§1.2). (4) `call_next_waiting_customer()` 1곳만 파일럿 적용한다(§2). (5) 나머지는 전부 Open Item이다(§4).

## §1 `resolve_store_staff_actor()` — 신규 공용 함수 전체 설계 — **[보류: 전제조건 미충족, §4 (g)]**

**이 설계는 삭제되지 않았다 — 구현 보류 상태다.** 아래 §1.1-§1.3의 SQL 설계 자체는 여전히 "JWT `sub`가 실제로 `staff.id`와 일치한다면" 유효한 로직이지만, 그 전제 자체가 이 프로젝트에서 실제로 성립한다는 증거가 없음이 이후 조사에서 밝혀졌다(§4 (g)) — `staff_login()`/`auth_sessions`(커스텀 세션)와 Supabase JWT/`current_actor_id()` 사이에 아무 연결이 없다. 지금 이대로 구현하면 실제 스태프 로그인 시나리오에서 항상(또는 우연에 의해서만) 실패/성공하는 함수가 된다 — 선행조건 해결 후 재검토 필요.

### §1.1 시그니처

```sql
create or replace function catchmenu_common.resolve_store_staff_actor(
  requested_tenant_id uuid,
  requested_store_id uuid,
  requested_actor_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common, catchmenu_store, pg_catalog
as $$
```

**스키마 배치 근거**: `catchmenu_common`에 배치한다 — `current_tenant_id()`/`current_store_id()`/`current_actor_id()` 등 이 함수가 직접 재사용하는 JWT 원시 함수들이 전부 이 스키마에 있고(`0022`), 이 resolver 자체도 특정 도메인(waiting/kds/payment)에 속한 개념이 아니라 어느 RPC에서든 재사용될 범용 인증 유틸리티이기 때문이다 — 이 코드베이스의 "스키마는 호출 계기가 아니라 함수의 성격을 따른다"는 관례 중에서도, `current_*()` 계열과 정확히 같은 범주(범용 보안 유틸리티)에 속한다.

`stable`(not `volatile`)로 선언한다 — 이 함수는 어떤 테이블도 변경하지 않고 오직 조회만 한다.

### §1.2 본문

```sql
declare
  v_jwt_tenant_id uuid;
  v_jwt_store_id uuid;
  v_jwt_actor_id uuid;
  v_staff record;
begin
  v_jwt_tenant_id := catchmenu_common.current_tenant_id();
  v_jwt_store_id := catchmenu_common.current_store_id();
  v_jwt_actor_id := catchmenu_common.current_actor_id();

  -- 리소스 정합성(A) — 요청 스코프가 JWT 스코프와 일치해야 한다.
  -- 0143의 1단계와 동일한 원칙(601211_Overview.md §3/§5.2).
  if v_jwt_tenant_id is distinct from requested_tenant_id
     or v_jwt_store_id is distinct from requested_store_id then
    return jsonb_build_object(
      'success', false,
      'error_key', 'actor_context_mismatch'
    );
  end if;

  -- 호출자가 자기 자신이 아닌 다른 actor_id를 "주장"하려는 시도를 조기 차단한다.
  -- requested_actor_id가 null이면(0160의 call_next_waiting_customer()처럼 파라미터
  -- 자체를 생략하는 경우) 이 검사는 건너뛰고 JWT만으로 계속 진행한다 — "호출자가
  -- 주장하는 게 아니라 시스템이 해석한다"는 원칙의 핵심(601211_Overview.md §5.2).
  if requested_actor_id is not null
     and requested_actor_id is distinct from v_jwt_actor_id then
    return jsonb_build_object(
      'success', false,
      'error_key', 'requested_actor_mismatch'
    );
  end if;

  if v_jwt_actor_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_not_found_or_inactive'
    );
  end if;

  -- 신원(B) — *** v_jwt_actor_id로 조회한다, requested_actor_id가 아니다 ***.
  -- 이 시스템의 신뢰 근거는 항상 JWT에서 해석한 값이다(601211_Overview.md §3.2 —
  -- staff.id 자체가 1행=1매장 고용 기록이므로 별도의 "다대다 소속 조회"는 불필요하다).
  select id, staff_role, authority_level
  into v_staff
  from catchmenu_store.staff
  where id = v_jwt_actor_id
    and tenant_id = requested_tenant_id
    and store_id = requested_store_id
    and staff_status = 'ACTIVE'
    and is_active = true;

  if v_staff.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'staff_not_found_or_inactive'
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'actor_id', v_jwt_actor_id,
    'employee_id', v_staff.id,
    'tenant_id', requested_tenant_id,
    'store_id', requested_store_id,
    'staff_role', v_staff.staff_role,
    'authority_level', v_staff.authority_level,
    'authorization_source', 'JWT_STAFF_MEMBERSHIP'
  );
end;
$$;
```

**`error_key` 3종을 구분하는 이유**: `actor_context_mismatch`(요청 스코프 자체가 JWT와 다름 — 클라이언트 버그이거나 스코프 조작 시도), `requested_actor_mismatch`(호출자가 다른 사람인 척함 — 명백한 스푸핑 시도), `staff_not_found_or_inactive`(정상적으로 로그인했고 스코프도 맞지만 그 매장의 활성 직원이 아님 — 예: 손님 계정, 퇴사자, 다른 매장 직원). 셋을 하나로 뭉뚱그리지 않는 이유는 향후 이 resolver를 호출하는 RPC들이 서로 다른 사용자 메시지/로깅 정책을 적용할 수 있게 하기 위함이다 — 다만 `0143`처럼 클라이언트에 노출되는 최종 에러는 뭉뚱그려도 무방하다(보안상 세부 사유를 클라이언트에 노출하지 않는 것이 오히려 안전할 수 있음, §3 Open Item 참고).

**`employee_id`가 `actor_id`와 동일한 이유**: `601211_Overview.md` §3.2/§5.1 — 이 아키텍처에서 `staff.id`가 이미 "이 사람의 이 매장에서의 고용 기록" ID이므로 현재는 두 값이 항상 같다. 반환에 둘 다 포함하는 것은 향후 스키마가 "사람 고유 ID"와 "고용 기록 ID"를 분리하는 방향으로 바뀔 경우를 대비한 호출자 계약 안정성이며, 지금 당장 스키마를 바꾸자는 제안이 아니다.

### §1.3 GRANT/REVOKE

```sql
revoke all on function catchmenu_common.resolve_store_staff_actor(
  uuid, uuid, uuid
) from public;

grant execute on function catchmenu_common.resolve_store_staff_actor(
  uuid, uuid, uuid
) to authenticated;
```

`authenticated`에게 GRANT하는 이유: 이 resolver 자체는 "당신이 스태프인지 확인해 달라"는 요청에 응답하는 함수이므로, 스태프가 아닌 `authenticated` 사용자(고객 등)가 호출해도 안전하다 — 그 경우 그냥 `{success:false, error_key:'staff_not_found_or_inactive'}`를 돌려받을 뿐이다. `0163`/`0167`이 확립한 "내부 전용 헬퍼는 REVOKE-only" 원칙과 다른 이유는, 이 함수가 내부 헬퍼가 아니라 여러 공개 RPC가 자신의 본문 안에서 호출할 **공용 유틸리티**이기 때문이다 — 다만 이 함수를 직접 클라이언트가 호출할 실질적 이유는 없으므로(호출해도 실행 여부 확인 외에는 아무 부작용이 없는 순수 조회 함수), `authenticated` GRANT는 위험이 아니라 관례적 배치일 뿐이다.

## §2 `call_next_waiting_customer()`(`0160:240-302`) 파일럿 적용 — **[보류: §1과 동일한 전제조건 미충족]**

**§1이 보류 상태이므로 이 파일럿 적용 설계도 함께 보류된다** — §4 (g) 해결 전까지 아래 변경을 실제로 구현하지 않는다.

### §2.1 변경 범위 — 시그니처 불변, 본문 맨 앞에 resolver 호출 추가

`600671_Overview.md`/`600672_Logic.md`(`600670` 워크패킷)가 이미 확정한 시그니처를 그대로 유지한다: `p_tenant_id uuid, p_store_id uuid, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`. 함수 본문의 기존 첫 줄(자동 선택 쿼리, `0160:257`) **직전**에 다음을 추가한다:

```sql
declare
  v_session record;
  v_expire_at timestamptz;
  v_actor_context jsonb;  -- 신규 선언
begin
  -- (신규) 파일럿: resolver로 호출자 신원을 해석한다 — p_actor_id를 그대로
  -- 신뢰하지 않는다(601211_Overview.md §5/§6).
  v_actor_context := catchmenu_common.resolve_store_staff_actor(
    requested_tenant_id := p_tenant_id,
    requested_store_id := p_store_id,
    requested_actor_id := p_actor_id
  );

  if not coalesce((v_actor_context->>'success')::boolean, false) then
    return catchmenu_common.build_error_response(
      p_error_key := coalesce(v_actor_context->>'error_key', 'unauthorized_caller'),
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_next_waiting_customer'
    );
  end if;

  -- 기존 로직은 그대로 이어진다 (0050:194-211 원문 로직 그대로 — WAITING만 대상)
  select os.id, os.wait_number, os.session_status, ...
```

**`p_actor_id` 사용 지점 변경**: 함수 후반부, `_record_waiting_call()` 호출(`0160:289-300`)의 `p_actor_id := p_actor_id` 인자를 `p_actor_id := (v_actor_context->>'actor_id')::uuid`로 교체한다 — 이제 감사기록/이벤트에 기록되는 `actor_id`는 호출자가 주장한 값이 아니라 resolver가 JWT에서 해석해 검증한 값이다(`601211_Overview.md` §1 (3)의 감사 원장 무결성 문제를 이 파일럿이 직접 해소한다).

### §2.2 `build_error_response()` 함수 존재 확인 필요 (Stage 5 이전 재확인 항목)

위 설계는 `catchmenu_common.build_error_response(p_error_key, p_locale, p_tenant_id, p_store_id, p_rpc_name)`가 존재한다고 가정한다 — 이 세션은 다른 여러 함수(`call_waiting_customer()` 등, `0160:198-204`)에서 이 함수가 실제로 쓰이는 것을 확인했으나, 정확한 파라미터 목록과 반환 형태는 Stage 5에서 라이브 재확인이 필요하다(§4 Open Item).

## §3 `resolve_store_staff_actor()`가 실패를 감사기록으로 남겨야 하는가 — 설계 옵션만 제시 (Open Item, 이번 파일럿의 필수 요구사항 아님)

**옵션 A(남긴다)**: 실패 분기(특히 `requested_actor_mismatch` — 명백한 스푸핑 시도)에서 `catchmenu_audit.append_audit_record()`를 호출해 `audit_domain := 'security'`(단, `chk_audit_domain`에 `'security'` 값이 실제 존재하는지는 이 세션 초반 기록에 따르면 존재함 — 재확인 필요), `audit_category := 'SECURITY'`(`chk_audit_category`에 이미 존재 확인됨), `decision := 'REJECTED'`로 남긴다. 장점: 무단 시도 자체가 추적 가능해짐(침입 탐지/사후 분석 근거). 단점: `resolve_store_staff_actor()`는 `stable`로 선언했는데(§1.1) 감사기록 INSERT는 데이터를 변경하는 작업이므로 `stable` 선언과 모순된다 — `volatile`로 바꿔야 하며, 이는 이 함수가 Postgres 쿼리 플래너에 의해 최적화(예: 같은 트랜잭션 내 반복 호출 캐싱)될 가능성을 없앤다.

**옵션 B(남기지 않는다, 호출하는 쪽 RPC가 필요시 직접 남긴다)**: resolver 자신은 순수 조회 함수로 남기고(`stable` 유지), 실패를 감사할지 여부는 이 resolver를 사용하는 각 RPC(예: `call_next_waiting_customer()`)가 자신의 판단으로 결정한다. 장점: resolver의 책임 범위가 명확(신원 해석만), `stable` 선언 유지 가능. 단점: 여러 RPC가 각자 감사 로직을 반복 구현하게 될 수 있음.

**이번 파일럿의 결정**: **옵션 B를 채택한다** — `resolve_store_staff_actor()` 자신은 `stable`로 유지하고 감사기록을 남기지 않는다. `call_next_waiting_customer()`(§2.1)도 이번 파일럿에서는 실패 시 별도 감사기록을 추가하지 않는다(기존 `0160`이 실패 응답에 감사기록을 남기는 관례가 없었으므로 이 파일럿이 새로 도입하지 않는다, 최소 변경 원칙). 이후 확장 시(§4 Open Item) 재검토 가능하다.

## §4 Open Items (`601211_Overview.md` §8의 (a)-(e) 공유 + 이 문서 고유 (f) + 신규 최우선 (g))

(a) waiting 나머지 5함수 + 오늘 신규 4워크패킷 RPC 확장 — 파일럿 검증 후 Human이 확장 여부/순서 결정.

(b) `staff_status`(`ON_LEAVE`/`SUSPENDED`/`TERMINATED`)와 `is_active`의 정확한 상호관계 미확정.

(c) `0143` 리팩터링 여부 — 이 신규 resolver로 대체할지, 현행 유지할지.

(d) resolver 실패 시 감사기록 여부 — §3에서 옵션 A/B를 제시하고 B를 채택했으나, Human이 A를 원할 경우 `stable`→`volatile` 재선언 필요.

(e) 여러 매장에 걸쳐 일하는 직원을 위한 UX(로그인 후 매장 선택/전환)가 1행=1매장 모델과 어떻게 상호작용하는지 — 이번 조사 범위 밖.

(f) `catchmenu_common.build_error_response()`의 정확한 시그니처/반환 형태 라이브 재확인 필요(§2.2) — Stage 5 착수 전 필수.

(g) **[신규, 2026-07-18, 최우선/CRITICAL — `caller_authorization_foundation` 프로그램 전체의 진짜 선행조건, `601211_Overview.md` §8 (f)와 동일 내용]** 직원 인증 다리(bridge) 부재. Claude Code와 Cursor가 완전 독립적으로 재확인해 결론이 일치했다: `staff_login()`(`0097`)의 커스텀 세션 시스템(`auth_sessions`)과 Supabase JWT/`current_actor_id()`(`0022`) 사이에 아무 연결이 없다. `auth_sessions`는 라이브 확인 결과 0행(세션 기록 자체가 한 번도 없음). `0143`(현재 `current_actor_id()`를 쓰는 유일한 함수)은 라이브 감사기록 재확인 결과 0건 — 역사상 한 번도 실행된 적이 없다. `staff_login()`을 호출하는 클라이언트 코드는 `catchmenu_app`/`apps/staff-web/` 어디에도 없다(실호출자 0건). `supabase/config.toml`의 `auth.hook.custom_access_token`은 의도적 비활성이 아니라 Supabase CLI 기본 템플릿 그대로(한 번도 구현되지 않음). 즉 §1의 `resolve_store_staff_actor()`가 전제하는 "JWT `sub` = `staff.id`" 연결은 이 프로젝트 어디에도 실제로 존재하지 않는다. 해결 방법(택1, 오늘은 설계하지 않음): (1) `staff` 테이블에 `auth.users.id` 연결 컬럼 추가 + 실제 로그인 흐름 설계, (2) `auth.hook.custom_access_token` 훅 실제 구현, (3) resolver를 `auth_sessions` 기반으로 재설계. 이 Open Item의 해결이 §1/§2뿐 아니라 (a)의 향후 확장 전체의 진짜 선행조건이다.

## §5 마이그레이션 배치 (Stage 5/8 대상, 이번 문서는 설계만)

- Stage 5에서 `sql/migrations/` 다음 사용 가능 번호를 재확인해 확정한다(`0167`이 이 문서 작성 시점 기준 최신).
- 신규 migration은 `catchmenu_common.resolve_store_staff_actor(...)`를 신규 `CREATE OR REPLACE FUNCTION`으로 생성하고, `catchmenu_pos.call_next_waiting_customer(...)`를 §2.1의 변경사항만 반영해 재선언(`CREATE OR REPLACE FUNCTION`)한다 — `0160` 원본 파일은 수정하지 않는다(`600670` 워크패킷이 확립한 "새 migration에서만 변경, 원본 파일은 그대로" 관례를 그대로 따름).
- `call_next_waiting_customer()`의 나머지 로직(자동 선택 쿼리, 만료시각 계산, `_record_waiting_call()` 호출의 다른 인자들)은 `p_actor_id` 인자 교체(§2.1) 외에는 전혀 변경하지 않는다.

## §6 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- `0143` 수정 금지.
- waiting 나머지 5함수, 오늘 신규 4워크패킷 RPC 실제 수정 금지 — 설계 문서에서 "향후 확장 대상"으로만 언급.
- `staff` 테이블 스키마 변경 금지(예: 다대다 조인 테이블 신설) — 이번 워크패킷은 기존 1행=1매장 모델을 그대로 전제한다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계 완료.** `catchmenu_common.resolve_store_staff_actor()`를 `catchmenu_common` 스키마에 신규 `stable` 함수로 설계했다 — JWT 원시 함수(`current_tenant_id()`/`current_store_id()`/`current_actor_id()`)를 재사용해 리소스 정합성(A)과 신원(B)을 모두 검사하고, `staff` 테이블 조회는 항상 JWT에서 해석한 `actor_id`로 수행하며 호출자가 파라미터로 보낸 `requested_actor_id`는 조기 스푸핑 차단에만 사용한다(§1). `call_next_waiting_customer()`의 시그니처는 바꾸지 않고 본문 맨 앞에 이 resolver 호출을 추가하며, 하위 `_record_waiting_call()` 호출의 `actor_id` 인자를 resolver가 반환한 검증된 값으로 교체해 감사 원장 무결성 문제도 함께 해소한다(§2). resolver 자신의 실패-감사기록 여부는 옵션 A/B를 모두 제시하고 이번 파일럿은 B(감사 없음, `stable` 유지)를 채택했다(§3). 나머지 waiting 5함수와 오늘 신규 4워크패킷의 RPC 전부, `0143` 리팩터링 여부, `staff_status`/`is_active` 관계 등은 전부 명시적 Open Item으로 이월했다(§4). `.sql` 파일은 생성·수정하지 않았다.

**(최종 정정, 2026-07-18 — 이 워크패킷은 여기서 멈춤)** 위 §1/§2 설계 완료 이후, Claude Code와 Cursor가 완전 독립적으로 "직원 인증 다리 부재" 문제를 재확인해 결론이 일치했다 — `staff_login()`/`auth_sessions`와 Supabase JWT/`current_actor_id()` 사이에 이 프로젝트 어디에도 연결이 없으며, `0143`조차 역사상 한 번도 실행된 적 없다(감사기록 0건, `auth_sessions` 0행, 실호출자 0건). §1/§2의 resolver/파일럿 설계는 **삭제되지 않았다 — 이 선행조건이 해결되기 전까지 구현 보류 상태로 남는다**(신규 Open Item (g), 최우선/CRITICAL). 이 발견 이후 이 세션은 대안 설계를 오늘 진행하지 않고 여기서 멈추며, Fable(장문맥 모델)을 이용한 전체 시스템 블라인드 역설계 논의로 전환됐다.
