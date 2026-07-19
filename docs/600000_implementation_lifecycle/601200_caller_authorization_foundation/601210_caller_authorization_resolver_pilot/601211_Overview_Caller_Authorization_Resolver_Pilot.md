# 601211_Overview_Caller_Authorization_Resolver_Pilot.md

Status: **Stage 4 완료, Stage 5 이후 보류** — 결정적 선행조건 발견으로 재설계 필요, 후속 Human 결정 대기 (2026-07-18)
Lifecycle: Overview
Stage: 1.5 → 4 완료, Stage 5 착수 보류
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`caller_authorization_resolver_pilot`

## ⚠ 최종 상태 — 이 워크패킷은 여기서 멈춘다 (2026-07-18)

**Claude Code + Cursor의 완전 독립 재확인으로 결론이 일치했다**: 이 문서(§5/§6)가 설계한 `resolve_store_staff_actor()`는 **삭제되지 않았다 — "직원 인증 다리(bridge) 부재"라는 선행조건이 해결되기 전까지 구현 보류 상태로 남는다.** `staff_login()`(`0097`)의 커스텀 세션 시스템(`auth_sessions`)과 Supabase JWT/`current_actor_id()`(`0022`) 사이에 이 프로젝트 어디에도 연결이 없다는 것이 확인됐다 — §5가 전제한 "JWT의 `sub` = `staff.id`"라는 가정 자체가 현재 이 코드베이스에서 성립할 근거가 없다(신규 Open Item (f), 최우선/CRITICAL). 이 발견 이후 이 워크패킷은 resolver 설계를 더 진행하지 않고 여기서 멈춘다 — 대안(택1) 설계는 오늘 하지 않는다.

## §0 번호 확인 — 신규 프로그램 배정

이 워크패킷은 waiting 도메인(`600600`) 하나에 국한되지 않는 cross-cutting 프로그램(호출자 권한 검증 기반 전체 RPC 표면에 적용될 원칙)이므로, 기존 프로그램 폴더에 종속 워크패킷으로 넣지 않고 **신규 최상위 프로그램**으로 배정한다. `docs/600000_implementation_lifecycle/`의 현재 최상위 프로그램 목록(`600100`-`601100`, `604000`)을 재확인한 결과 `601200`이 인덱스(`000005`)/전체 디렉터리 맵(`000007`)/물리 디렉터리 전부에서 미사용임을 확인했다 — 폴더 `601200_caller_authorization_foundation/`을 신규 프로그램으로, 그 첫 워크패킷을 `601210_caller_authorization_resolver_pilot/`(Overview `601211`, Logic `601212`)로 배정한다. `601100_store_admin_console/`의 기존 관례(`X100`=Readme, `X102`=NavigationMap, 첫 워크패킷 `X110`)를 따르되, 프로그램 레벨 Readme/NavigationMap 작성은 이번 턴의 Output 범위(Overview/Logic만) 밖이므로 별도 후속 작업으로 남긴다.

## §1 배경 — Cursor 2단계 전수조사 (재확인 불필요, 단 핵심 발견은 이 세션도 직접 재확인함)

Cursor의 전수조사: 486개 RPC 중 `auth.uid()` 리터럴 사용 0건, `current_*()`/`p_*` 파라미터 대조 패턴 1건(`0143`만), `staff` 테이블 조회 패턴 ~30건. Waiting 도메인 6개 함수 + 오늘 신규 4개 워크패킷(`600670`/`601030` 등)의 RPC 전부가 "리소스 정합성(A, 예: `tenant_id`/`store_id`가 요청 스코프와 일치하는지)은 확인하지만 호출자 신원(B, 이 요청을 보낸 사람이 실제로 그 `tenant_id`/`store_id`에 소속된 자격 있는 직원인지)은 확인하지 않는" 패턴이다. `call_next_waiting_customer()`는 그중에서도 가장 심각하다 — `session_id`조차 요구하지 않고 `p_tenant_id`+`p_store_id` 범위만으로 실행되며(`0160:240-246`, `600670` 워크패킷이 이미 확인한 시그니처), `tenant_id`/`store_id`는 이 아키텍처에서 QR코드/매장선택 UI로 고객에게 그대로 노출되는 사실상 공개 식별자다(비밀로 기능하지 않음) — 이 함수를 호출할 수 있는 조건이 사실상 "그 매장의 `tenant_id`/`store_id`를 안다"뿐이라는 뜻이다.

**이 세션이 직접 재확인한 사실(라이브)**:

1. `call_next_waiting_customer()`의 라이브 정의(`pg_get_functiondef`)를 재확인한 결과, 본문 어디에도 `catchmenu_common.current_tenant_id()`/`current_store_id()`/`current_actor_id()`에 대한 참조가 **전혀 없다** — `0143`이 최소한 수행하는 "JWT tenant/store와 요청값 대조"조차 이 함수는 하지 않는다. 리소스 정합성(A)조차 없는, `600671_Overview.md`가 다룬 ACL 문제(누가 호출 자체를 실행할 수 있는가)와는 별개의 완전히 독립적인 갭이다.
2. `600670_record_waiting_call_grant_correction` 워크패킷(오늘 완료)이 `call_next_waiting_customer()`의 실행 권한을 `PUBLIC`(누구나) → `authenticated`(로그인한 사용자만)로 좁혔지만, **`authenticated`는 스태프 전용 역할이 아니다** — 고객 앱으로 로그인한 일반 고객도 `authenticated` 역할을 갖는다. 즉 오늘의 ACL 수정은 "익명 접근"을 막았을 뿐 "고객이 직원 전용 액션을 트리거하는 것"은 여전히 막지 못한다 — 이번 워크패킷이 다루는 문제가 그 ACL 수정과는 다른 층위임을 명확히 한다.
3. `p_actor_id`(`call_next_waiting_customer()`→`_record_waiting_call()`로 그대로 전달됨)는 현재 아무 검증 없이 감사기록(`kds_events.caused_by_id`, `catchmenu_ledger.events.caused_by_id` 계열)에 그대로 기록된다 — 즉 이 갭은 "권한 없는 호출" 문제일 뿐 아니라 "감사 기록 자체에 임의의 `actor_id`를 주입할 수 있는" 문제이기도 하다(감사 원장 무결성 침해, 특허4 원칙 위반).

## §2 확정된 설계 방향 (ChatGPT+제미나이 교차검증 반영, 재논의 금지)

1. `0143`의 3단계 패턴("검증된 전사표준"으로 가정하지 않고 재검증, §3)을 근거로 삼되, 그대로 복사하지 않는다 — boolean 하나(`is_store_staff()`)가 아니라 **canonical actor context를 반환하는 resolver**로 설계한다.
2. `resolve_store_staff_actor(requested_tenant_id, requested_store_id, requested_actor_id optional)` → `actor_id`/`employee_id`/`tenant_id`/`store_id`/`role`/`authorization_source`를 반환.
3. 핵심 원칙: **호출자가 `actor_id`를 주장하는 게 아니라, 시스템이 인증정보(JWT)에서 `actor_id`를 해석한다.** `requested_actor_id`는 파라미터로 남기되(하위호환/명시적 의도 전달용), 조회 키로는 절대 쓰지 않는다 — 조회는 항상 JWT에서 해석한 실제 신원으로 한다.
4. `call_next_waiting_customer()`를 최우선 파일럿으로 지정 — 신규 resolver를 실제로 적용하는 유일한 함수(이번 워크패킷 범위).
5. 나머지 waiting 5함수(`call_waiting_customer()`/`register_waiting()`/`confirm_arrival()`/`seat_waiting_customer()`/`cancel_waiting()`/`mark_no_show()` 등, `600602_NavigationMap.md` 재확인 필요) + 오늘 신규 4개 워크패킷의 RPC 전부는 Open Item으로 이월 — 파일럿 검증 후 확장 여부를 Human이 판단.

## §3 `0143`(`release_kds_ticket_no_payment`) 재검증 — "검증된 전사표준"으로 가정하지 않고 라이브로 재확인

**전체 함수 본문을 다시 읽었다**(`sql/migrations/0143_add_no_payment_kds_release_policy.sql:18-331`). 실제 3단계 패턴:

```sql
-- 1단계: JWT 컨텍스트와 요청값 3중 대조 (리소스 정합성 A + 부분적 신원 확인)
if catchmenu_common.current_tenant_id() is distinct from p_tenant_id
   or catchmenu_common.current_store_id() is distinct from p_store_id
   or catchmenu_common.current_actor_id() is distinct from p_actor_id then
  return jsonb_build_object('success', false, 'error_key', 'release_context_mismatch');
end if;

-- 2단계: staff 테이블에서 활성 직원 조회 (신원 B — 단, p_actor_id로 조회함에 유의, §3.1)
select s.id, s.staff_role, s.authority_level, s.can_override_kds
into v_staff
from catchmenu_store.staff s
where s.id = p_actor_id and s.tenant_id = p_tenant_id and s.store_id = p_store_id
  and s.staff_status = 'ACTIVE' and s.is_active = true;

if v_staff.id is null or not coalesce(v_staff.can_override_kds, false) then
  return jsonb_build_object('success', false, 'error_key', 'unauthorized_release');
end if;

-- 3단계: 매장별 정책 플래그 확인 (payment_required_for_kds_release = false)
```

### §3.1 `staff` 테이블이 authoritative source인가 — 예, 확인됨

`catchmenu_store.staff`는 다른 어떤 테이블도 아닌 이 테이블 하나가 직원 신원/권한의 유일한 출처다 — 라이브 스키마 전체 재확인 결과 `staff_role`(`OWNER`/`MANAGER`/`SUPERVISOR`/`STAFF`/`PART_TIME`/`TRAINEE`), `authority_level`(1-10), `can_override_kds`/`can_approve_refund`/`can_manage_menu`/`can_manage_staff`/`can_view_reports`/`can_change_store_mode`/`can_observe` 7개의 개별 boolean 권한 플래그, `staff_status`(`ACTIVE`/`ON_LEAVE`/`SUSPENDED`/`TERMINATED`), 별도의 `is_active` boolean이 이 테이블에 직접 존재한다. `staff_isolation`이라는 RLS 정책도 이미 존재(`tenant_id = current_tenant_id() and store_id = current_store_id()`) — 다만 이 프로젝트의 "직접 테이블 GRANT 없음, 전부 SECURITY DEFINER RPC 경유" 관례상 RLS는 2차 방어선일 뿐이다.

### §3.2 직원이 여러 매장에 소속 가능한가 — 아니오, 1행=1매장 (many-to-many 아님)

`catchmenu_store.staff`의 `tenant_id`/`store_id`는 테이블 자체의 `NOT NULL` 컬럼이자 각각 `catchmenu_hq.tenants`/`catchmenu_hq.stores`로의 단일 FK다 — 별도의 `staff_store_assignments` 류 다대다 조인 테이블은 라이브 스키마 전수 검색(`catchmenu_store` 스키마의 `staff`로 시작하는 모든 relation, 32개) 결과 **존재하지 않는다**. 즉 이 아키텍처에서 "한 사람이 여러 매장에서 일한다"는 개념은 **여러 개의 별도 `staff` 행**(각 행이 서로 다른 `id`)으로 표현된다 — `staff.id` 하나는 "이 사람"이 아니라 "이 사람의 이 매장에서의 고용 기록"을 가리킨다. Resolver 설계에 직접적인 함의: `resolve_store_staff_actor()`는 "이 JWT 신원이 이 특정 `tenant_id`/`store_id`에 대한 활성 `staff` 행을 갖고 있는가"를 물어야지, "이 JWT 신원에 연결된 모든 `staff` 행을 찾은 뒤 그중 하나가 이 매장과 일치하는가"를 물을 필요가 없다 — 스코프 자체가 이미 매장별로 분리돼 있다.

### §3.3 정지/퇴사/임시근무 상태를 어떻게 처리하는가

`chk_staff_status` 제약은 정확히 4개 값만 허용: `ACTIVE`/`ON_LEAVE`/`SUSPENDED`/`TERMINATED`. `0143`은 이 중 `staff_status = 'ACTIVE'`만 통과시킨다 — `ON_LEAVE`/`SUSPENDED`/`TERMINATED` 전부 동일하게 차단된다(세분화된 에러 메시지 없이 뭉뚱그려 `unauthorized_release`로 응답). 이와 **별개로** `is_active` boolean이 하나 더 있다 — 두 플래그(`staff_status`/`is_active`) 사이의 정확한 관계(예: `is_active=false`인데 `staff_status='ACTIVE'`인 행이 실제로 존재할 수 있는지, 둘이 항상 동기화되는지)는 라이브 스키마만으로는 확정할 수 없다 — 별도 트리거/애플리케이션 로직 검색이 필요하며, 이번 조사 범위에서는 **"안전한 쪽으로" 두 플래그를 모두 확인하는 `0143`의 방식을 그대로 채택**한다(Open Item §7 (c)).

### §3.4 JWT claim과 DB membership 중 무엇이 우선인가

`0143`의 코드는 **둘 다 요구**한다 — JWT claim(`current_actor_id() = p_actor_id`)이 일치하지 **않으면** 즉시 거부(1단계), 일치해도 DB의 `staff` 행이 없거나 비활성이면 역시 거부(2단계). 즉 "OR" 관계가 아니라 "AND" — 어느 한쪽만으로는 충분하지 않다. 이는 이 프로젝트의 아키텍처 원칙과 정합적이다: JWT는 "누가 로그인했는가"만 증명하고, DB의 `staff` 행은 "그 사람이 지금도 이 매장에서 일하는 활성 직원인가"를 증명한다 — 로그인 상태와 고용 상태는 서로 다른 사실이며 둘 다 필요하다(예: 어제 해고된 직원의 JWT는 여전히 유효할 수 있지만 `staff_status`가 `TERMINATED`로 바뀌어 있어야 한다).

## §4 `catchmenu_common.current_actor_id()`가 실제로 신뢰 가능한가 — 라이브로 확인 완료

`current_actor_id()`(`0022_create_rls_policies.sql:49-61`)의 실제 정의:

```sql
create or replace function catchmenu_common.current_actor_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select nullif(
    current_setting('request.jwt.claims', true)::jsonb ->> 'sub',
    ''
  )::uuid;
$$;
```

**Supabase 자체 내장 `auth.uid()`와 직접 대조한 결과(라이브 `pg_get_functiondef('auth.uid()'::regprocedure)`)**:

```sql
CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql STABLE
AS $function$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$function$
```

**두 함수는 기능적으로 동일하다** — 둘 다 JWT의 `sub` 클레임(RFC 7519 표준, Supabase Auth가 발급하는 JWT의 사용자 고유 ID)을 `request.jwt.claims` GUC 설정에서 읽는다. `auth.uid()`는 레거시 호환을 위해 `request.jwt.claim.sub`(단수, 비-JSON 경로)도 폴백으로 확인하지만, 이 프로젝트의 실제 JWT 발급 방식에서는 두 함수가 동일한 값을 반환한다. `current_actor_id()`는 이미 `security definer` + `set search_path = pg_catalog`로 안전하게 구현돼 있다 — `search_path`를 `pg_catalog`로 고정하는 것은 이 함수가 호출되는 컨텍스트의 로컬 객체에 의해 셰도잉/하이재킹되는 것을 막는 표준적인 방어 기법이다.

**결론**: 이 프로젝트는 이미 `auth.uid()`와 동등한, 안전하게 구현된 자체 래퍼(`current_actor_id()`)를 갖고 있다 — Cursor의 "486개 RPC 중 `auth.uid()` 리터럴 사용 0건"이라는 관찰은 정확하지만, "이 프로젝트에 신뢰 가능한 JWT 기반 신원 확인 수단이 전혀 없다"는 뜻으로 오독하면 안 된다 — 그 수단은 **존재하지만 거의 안 쓰인다**(라이브 재확인: `current_actor_id()`를 실제로 호출하는 파일은 전체 마이그레이션 중 `0143` 단 하나뿐, `grep -rl "current_actor_id()" sql/migrations/*.sql` → 정의 파일(`0022`) + 소비 파일(`0143`) 2건). Resolver 설계는 이 기존의 신뢰 가능한 원시 함수를 재사용해야 하며, 새로운 신원 확인 메커니즘을 발명할 필요가 없다(§5).

## §5 Resolver 설계 — `resolve_store_staff_actor()` — **[보류: 전제조건 미충족, §8 (f)]**

**이 섹션의 설계는 삭제되지 않았다 — "직원 인증 다리 부재"(§8 (f)) 문제가 해결되기 전까지 구현으로 진행할 수 없는 상태로 보류된다.** 이하 §5.1-§5.3의 설계 자체는 그 당시(§4까지의 확인 결과 기준) 유효한 논리적 귀결이었으나, 이후 추가 조사(Claude Code + Cursor 완전 독립 재확인, ⚠ 최종 상태 참고)에서 "JWT의 `sub` = `staff.id`"라는 이 설계의 핵심 전제 자체가 이 코드베이스에서 실제로 성립한다는 증거가 없음이 밝혀졌다 — `current_actor_id()`가 신뢰 가능하다는 §4의 결론은 여전히 유효하지만(`current_actor_id()` 자체는 정확히 JWT `sub`를 반환한다), **그 `sub` 값을 특정 `staff.id`로 연결하는 로그인 흐름이 이 프로젝트 어디에도 없다.** 즉 §5의 resolver가 실행될 실제 운영 환경에서는, 정상적으로 로그인한 스태프의 JWT `sub`가 애초에 그 사람의 `staff.id`와 같은 값일 이유가 없다 — 이 설계를 지금 구현하면 "항상 실패하거나(스태프가 존재하지 않는 것처럼 보임) 우연의 일치로만 성공하는" 함수가 된다.

### §5.1 시그니처와 반환 계약

```text
resolve_store_staff_actor(
  requested_tenant_id uuid,
  requested_store_id uuid,
  requested_actor_id uuid default null
) returns jsonb
```

반환(성공): `{success:true, actor_id, employee_id, tenant_id, store_id, staff_role, authority_level, authorization_source:'JWT_STAFF_MEMBERSHIP'}` — `actor_id`와 `employee_id`는 이 아키텍처에서 사실상 동일한 값이다(§3.2 — `staff.id` 자체가 "이 사람의 이 매장에서의 고용 기록" ID이므로 별도의 "사람 고유 ID"와 "고용 기록 ID"가 분리돼 있지 않다). 둘 다 반환에 포함하는 이유는 향후(다른 워크패킷에서) 사람 고유 ID와 고용 기록 ID가 분리되는 스키마 변경이 있을 경우를 대비한 호출자 계약 안정성이다.

반환(실패): `{success:false, error_key: 'actor_context_mismatch' | 'staff_not_found_or_inactive' | 'requested_actor_mismatch'}` — 셋을 구분하는 이유는 §5.2 참고.

### §5.2 내부 로직 — JWT가 유일한 신원 출처

```text
1. v_jwt_tenant_id := catchmenu_common.current_tenant_id()
   v_jwt_store_id  := catchmenu_common.current_store_id()
   v_jwt_actor_id  := catchmenu_common.current_actor_id()

2. if v_jwt_tenant_id is distinct from requested_tenant_id
      or v_jwt_store_id is distinct from requested_store_id
   then return {success:false, error_key:'actor_context_mismatch'}
   -- (0143의 1단계와 동일한 "리소스 정합성" 검사 — 요청 스코프가 JWT 스코프와 일치해야 함)

3. if requested_actor_id is not null
      and requested_actor_id is distinct from v_jwt_actor_id
   then return {success:false, error_key:'requested_actor_mismatch'}
   -- 호출자가 자기 자신이 아닌 다른 actor_id를 "주장"하려는 시도를 명시적으로 거부한다.
   -- p_actor_id를 아예 생략(null)하면 이 검사는 건너뛰고 4단계로 바로 진행한다.

4. select id, staff_role, authority_level, can_override_kds, ...
   into v_staff
   from catchmenu_store.staff
   where id = v_jwt_actor_id            -- *** v_jwt_actor_id다, requested_actor_id가 아니다 ***
     and tenant_id = requested_tenant_id
     and store_id = requested_store_id
     and staff_status = 'ACTIVE'
     and is_active = true

5. if v_staff.id is null
   then return {success:false, error_key:'staff_not_found_or_inactive'}

6. return {success:true, actor_id: v_jwt_actor_id, employee_id: v_staff.id,
           tenant_id: requested_tenant_id, store_id: requested_store_id,
           staff_role: v_staff.staff_role, authority_level: v_staff.authority_level,
           authorization_source: 'JWT_STAFF_MEMBERSHIP'}
```

**핵심 설계 결정(원칙 3의 직접 구현)**: 4단계의 `staff` 조회는 `v_jwt_actor_id`(시스템이 JWT에서 해석한 값)로 하지, `requested_actor_id`(호출자가 파라미터로 보낸 값)로 하지 **않는다**. 3단계는 "호출자가 다른 사람인 척하려 하면 즉시 거부"하는 조기 차단일 뿐, 실제 신뢰의 근거(4단계)는 항상 JWT다. `requested_actor_id`를 아예 생략해도(현재 `call_next_waiting_customer()`의 `p_actor_id default null`처럼) 시스템은 JWT만으로 완전히 동작한다 — 이것이 "호출자가 주장하는 게 아니라 시스템이 해석한다"는 원칙의 정확한 의미다.

### §5.3 `resolve_store_staff_actor()`와 `0143`의 관계 — 대체가 아니라 상위 공용화

`0143` 자체는 이번 워크패킷에서 수정하지 않는다(범위 밖, §7 확정 범위). 향후(별도 워크패킷) `0143`을 이 신규 resolver를 호출하도록 리팩터링할 수 있다는 가능성만 Open Item으로 남긴다 — 지금은 순수 신규 함수 설계 + `call_next_waiting_customer()` 1곳 파일럿 적용만 확정한다.

## §6 파일럿 적용 대상 — `call_next_waiting_customer()`만 — **[보류: §5와 동일한 전제조건 미충족으로 진행 불가]**

**§5가 보류 상태이므로 이 파일럿 적용도 함께 보류된다.** 아래 설계는 §5의 resolver가 실제로 신뢰 가능해질 때(§8 (f)의 세 가지 대안 중 하나가 결정·구현된 이후)까지 적용할 수 없다.

`600670_record_waiting_call_grant_correction`이 이미 이 함수의 실제 라이브 시그니처를 확정했다(`p_tenant_id uuid, p_store_id uuid, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`) — 시그니처 자체는 바꾸지 않는다(하위호환, §6.1). 함수 본문 맨 앞에서 `resolve_store_staff_actor(p_tenant_id, p_store_id, p_actor_id)`를 호출하고, 실패 시 즉시 그 `error_key`를 반환한다. 성공 시 resolver가 반환한 `actor_id`(JWT 기반, 호출자가 주장한 값이 아님)를 이후 `_record_waiting_call()` 호출의 `p_actor_id` 인자로 사용한다.

### §6.1 호환성 부담 — 낮음(라이브 재확인)

`600672_Logic.md` §6 Open Item (c)가 이미 확인한 대로 `call_next_waiting_customer()`의 실호출자는 현재 0건(고아 함수, SQL/Flutter 어디서도 호출되지 않음). 즉 이 함수의 동작을 이번 워크패킷에서 강하게(호출자에게 스태프 신원을 강제) 바꿔도 깨질 기존 호출자가 없다 — 호환성 부담이 사실상 없는 이상적인 파일럿 대상이다.

## §7 확정된 범위

**포함**:
1. `resolve_store_staff_actor()` 신규 함수 설계(§5).
2. `call_next_waiting_customer()`에 이 resolver를 적용하는 설계(§6) — 이 함수 하나만.

**명시적으로 범위 밖(Open Item으로만 기록)**:
(a) waiting 도메인의 나머지 5개 함수(`call_waiting_customer()`/`register_waiting()`/`confirm_arrival()`/`seat_waiting_customer()`/`cancel_waiting()`/`mark_no_show()` — 정확한 목록은 `600602_NavigationMap_Waiting_Order_Session.md` 재확인 필요, 6개 중 1개가 파일럿이므로 5개가 이월 대상).
(b) 오늘(2026-07-18) 신규 생성된 4개 워크패킷(`600670`/`601030` 등)이 다루는 RPC들.
(c) `staff_status`/`is_active` 두 플래그의 정확한 관계(트리거 유무, 동기화 보장 여부) — 라이브 스키마만으로 확정 불가.
(d) `0143` 자신을 신규 resolver로 리팩터링할지 여부 — 별도 워크패킷 후보.
(e) `resolve_store_staff_actor()`가 인증 실패 시 자체적으로 `append_audit_record()`를 호출해 무단 시도 자체를 감사 기록으로 남길지 여부 — Logic.md에서 설계 옵션으로만 제시, 이번 파일럿의 필수 요구사항인지는 Human 판단 필요(§8).

## §8 Open Items

(a) waiting 나머지 5함수 + 오늘 신규 4워크패킷 RPC 확장 — 파일럿 검증 후 Human이 확장 여부/순서 결정.

(b) `staff_status`(`ON_LEAVE`/`SUSPENDED`/`TERMINATED`)와 `is_active`의 정확한 상호관계 미확정 — §3.3.

(c) `0143` 리팩터링 여부 — §5.3.

(d) resolver 실패 시 감사기록 남길지 여부 — §7 (e). 남긴다면 `audit_type`(예: `caller_authorization_denied`)과 `audit_category`(`SECURITY`? — `chk_audit_category`에 이미 `SECURITY` 값이 존재함, 이 세션 초반에 확인된 사실) 확정 필요.

(e) 여러 매장에 걸쳐 일하는 실제 직원을 위한 UX(로그인 후 매장 선택/전환 방식)가 이 1행=1매장 모델과 어떻게 상호작용하는지는 이번 조사 범위 밖 — Flutter/스태프 앱 설계 문서 확인 필요.

(f) **[신규, 2026-07-18, 최우선/CRITICAL — `caller_authorization_foundation` 프로그램 전체의 진짜 선행조건]** 직원 인증 다리(bridge) 부재. Claude Code와 Cursor가 완전 독립적으로 재확인해 결론이 일치했다:

- `staff_login()`(`0097`)은 커스텀 세션 시스템(무작위 hex `session_token`/`refresh_token`, `catchmenu_common.auth_sessions`에 해시 저장)을 구현하지만, Supabase Auth의 JWT/`request.jwt.claims`/`auth.uid()` 어디와도 연결되지 않는다 — `0097` 전체 어디에도 그런 참조가 없다.
- `catchmenu_common.auth_sessions` 테이블은 라이브 확인 결과 **0행**(어떤 종류의 세션도 이 DB에 한 번도 기록된 적 없음).
- `0143`(이 프로젝트에서 `current_actor_id()`를 실제로 쓰는 유일한 함수)은 라이브 감사기록(`catchmenu_ledger.audit_records where audit_type='kds_no_payment_policy_released'`) 재확인 결과 **0건** — 이 함수 자체가 역사상 단 한 번도 실행된 적이 없다. 즉 "JWT `sub`가 `staff.id`와 일치한다"는 이 함수의 전제 자체가 실전에서 단 한 번도 검증된 적이 없다.
- `staff_login()`을 호출하는 클라이언트 코드는 `catchmenu_app`(Flutter, 실제 소스 14개 파일 전수 확인)과 `apps/staff-web/`(내용물 없음, `.gitkeep`만 존재) 어디에도 없다 — 실호출자 0건.
- `supabase/config.toml`의 `[auth.hook.custom_access_token]`은 의도적으로 끈 것이 아니라 Supabase CLI가 생성하는 기본 템플릿 그대로(전체 커밋 이력 중 이 파일을 건드린 커밋은 "CLI-generated" 라벨의 단 1건뿐, `custom_access_token`을 언급하는 커밋 메시지/설계문서 0건) — 즉 "한 번도 구현되지 않은 상태"이지 "결정 후 비활성화"가 아니다.

**결론**: `resolve_store_staff_actor()`(§5)가 전제하는 "JWT `sub` = `staff.id`" 연결은 이 프로젝트 어디에도 실제로 존재하지 않는다. **해결 방법은 최소 3가지 대안 중 하나(또는 조합)이며, 이번 조사는 판단/설계를 하지 않고 사실만 기록한다**:
1. `staff` 테이블에 Supabase `auth.users.id`를 가리키는 연결 컬럼을 추가하고, 실제 로그인 시(예: Supabase `signInWithPassword`/`signInAnonymously` 등)이 컬럼을 채우는 흐름을 설계한다.
2. `auth.hook.custom_access_token` 훅을 실제로 구현해, 로그인 시점에 `staff.id`(또는 그 매핑)를 JWT의 커스텀 클레임으로 주입한다.
3. Resolver 자체를 `auth_sessions`(커스텀 세션 시스템) 기반으로 재설계해, Supabase JWT를 아예 경유하지 않고 이 프로젝트 자체 토큰 체계로 신원을 해석한다.

이 Open Item의 해결이 `caller_authorization_foundation` 프로그램 전체(이 파일럿 워크패킷뿐 아니라 향후 확장될 나머지 waiting 5함수 + 오늘 신규 4워크패킷 RPC 전부, Open Item (a))의 진짜 선행조건이다 — 이 문제를 해결하지 않고는 어떤 resolver 설계도 실전에서 의미 있게 작동하지 않는다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `601212_Logic.md`로 이어짐.** `0143`의 3단계 패턴을 "검증된 전사표준"으로 가정하지 않고 전체 본문을 다시 읽어 재검증했다(§3) — `staff` 테이블이 유일한 authoritative source임을 확인했고(§3.1), 직원-매장 관계가 다대다가 아니라 1행=1매장(별도 조인 테이블 없음)임을 라이브 스키마 전수 검색으로 확인했으며(§3.2), `staff_status`(4개 값) + 별도 `is_active`의 이중 비활성화 플래그 존재를 확인했고(§3.3), JWT claim과 DB membership이 "AND" 관계(둘 다 필요)임을 확인했다(§3.4). `catchmenu_common.current_actor_id()`가 Supabase 자체 `auth.uid()`와 기능적으로 동일함을 라이브 함수 정의 직접 대조로 확인했다 — 이 프로젝트에 이미 신뢰 가능한 JWT 기반 신원 확인 원시 함수가 존재하지만 거의 쓰이지 않고 있었을 뿐이다(§4). 이를 재사용하는 `resolve_store_staff_actor()` resolver를 설계했다 — 호출자가 주장하는 `requested_actor_id`가 아니라 JWT에서 해석한 `actor_id`로 `staff` 조회를 수행하는 것이 핵심 원칙이다(§5). `call_next_waiting_customer()`를 유일한 파일럿 적용 대상으로 확정했고, 실호출자 0건이라 호환성 부담이 없음을 재확인했다(§6). 나머지 5개 waiting 함수와 오늘 신규 4워크패킷의 RPC들은 전부 Open Item으로 명시적으로 이월했다(§7/§8). `.sql` 파일은 생성·수정하지 않았다.

**(최종 정정, 2026-07-18 — 이 워크패킷은 여기서 멈춤)** 위 §5/§6 설계 완료 이후, Claude Code와 Cursor가 완전 독립적으로 "직원 인증 다리 부재" 문제를 재확인해 결론이 일치했다 — `staff_login()`/`auth_sessions`(커스텀 세션 시스템)와 Supabase JWT/`current_actor_id()` 사이에 이 프로젝트 어디에도 연결이 없으며, `0143`조차 역사상 한 번도 실행된 적 없다(감사기록 0건, `auth_sessions` 0행). §5/§6의 resolver/파일럿 설계는 **삭제되지 않았다 — 이 선행조건이 해결되기 전까지 구현 보류 상태로 남는다**(신규 Open Item (f), 최우선/CRITICAL). 이 발견 이후 이 세션은 대안 설계(택1: staff-auth.users 연결 컬럼, custom_access_token 훅 구현, 또는 auth_sessions 기반 재설계)를 오늘 진행하지 않고 여기서 멈추며, Fable(장문맥 모델)을 이용한 전체 시스템 블라인드 역설계 논의로 전환됐다.
