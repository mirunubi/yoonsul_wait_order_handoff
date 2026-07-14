# 600511_Overview_Did_Display_State_Overload.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`did_display_state_overload_and_legacy_defect`

## §0 배경 (Cursor+Codex+안티 삼중 검증 완료, 재확인 불필요로 전제 — 원문은 이번 턴 재확인)

`catchmenu_store.get_did_display_state()`가 라이브에 두 오버로드로 공존한다: `0043`(3-param, `p_device_id`) — 매장 전체 집계, 본문에 nested aggregate 문법 오류로 호출 시 무조건 크래시. `0117`(4-param, `p_did_id`+`p_locale`) — 단일 DID 디바이스 큐 조회, 정상 작동, 실제 호출부 있음(`bootstrap_did_app()`). positional 3-arg 호출 시 모호성(`"is not unique"`) 실증 확인됨. named 호출은 파라미터명이 달라 분기되지만, 위험 요소로 남는다.

**투명 공개 — `600491_Overview.md`(직전 워크패킷)의 오류 정정**: 그 문서 §2.1은 이 두 오버로드를 "(a) `0043` → `p_did_id`+`p_locale`, (b) `0117` → `p_device_id`"로 서술했는데, 이번 턴 라이브 재확인 결과 **정반대**임이 확인됐다 — `0043` = `p_device_id`(3-param), `0117` = `p_did_id`+`p_locale`(4-param)이 맞다. 이번 배경 설명의 서술이 정확했고, 직전 문서의 서술이 틀렸다. `600491_Overview.md`는 이 문서 작성 범위 밖이라 소급 정정하지 않으나, 여기 명시해 향후 참조 시 혼동을 방지한다.

## §1 정확한 시그니처 재확인 (라이브)

```
(3-param, 0043) p_tenant_id uuid, p_store_id uuid, p_device_id uuid default null
(4-param, 0117) p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text default 'ko'
```

`0043`의 정의 위치: `sql/migrations/0043_create_did_display_rpc.sql` L13-16(`create or replace function catchmenu_store.get_did_display_state(p_tenant_id uuid, p_store_id uuid, p_device_id uuid default null)`).
`0117`의 정의 위치: `sql/migrations/0117_create_did_pipeline_rpc.sql` L300-305(`create or replace function catchmenu_store.get_did_display_state(p_tenant_id uuid, p_store_id uuid, p_did_id uuid, p_locale text default 'ko')`).

## §2 모호성 재현 (이번 턴 직접 실증)

positional 3개 인자(uuid, uuid, uuid) 호출 — `0043`의 3-param과 정확히 일치하지만, `0117`도 `p_locale`이 기본값을 가지므로 3개 인자만으로 매치 가능해 모호:

```sql
select catchmenu_store.get_did_display_state(
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  null::uuid
);
```

결과(BEGIN...ROLLBACK, 영구 반영 없음):

```
ERROR: function catchmenu_store.get_did_display_state(uuid, uuid, uuid) is not unique
HINT: Could not choose a best candidate function. You might need to add explicit type casts.
```

## §3 `0043`의 nested aggregate 크래시 — 정확한 위치와 원인 (이번 턴 직접 실증)

`p_device_id`를 명시적으로 지정한 named-argument 호출로 `0043`의 3-param 오버로드만 강제 지정해 재현:

```sql
select catchmenu_store.get_did_display_state(
  p_tenant_id := '...'::uuid,
  p_store_id := '...'::uuid,
  p_device_id := null::uuid
);
```

결과:

```
ERROR: aggregate function calls cannot be nested
LINE 5:         'cooking_count', count(*) filter (
CONTEXT: PL/pgSQL function get_did_display_state(uuid,uuid,uuid) line 102 at SQL statement
```

**정확한 원인**(`0043` 소스 L126-150, "cooking summary by kitchen zone" 블록): `jsonb_object_agg(...)`(집계 함수) 호출의 두 번째 인자로 `jsonb_build_object(...)`를 넘기는데, 그 안에 `count(*) filter (where ...)`(또 다른 집계 함수)를 직접 중첩시켰다:

```sql
select coalesce(
  jsonb_object_agg(
    coalesce(kt.kitchen_zone, 'GENERAL'),
    jsonb_build_object(
      'cooking_count', count(*) filter (where kt.kds_status = 'COOKING'),
      'ready_count', count(*) filter (where kt.kds_status = 'READY'),
      'hold_count', count(*) filter (where kt.kds_status in ('HOLD', 'CAPACITY_CHECKING'))
    )
  ),
  '{}'::jsonb
)
into v_cooking_summary
from catchmenu_kds.kds_tickets kt
where ...
```

PostgreSQL은 같은 쿼리 레벨에서 집계 함수를 다른 집계 함수 안에 직접 중첩하는 것을 허용하지 않는다(`jsonb_object_agg(...)` 안에 `count(*)`가 들어있음) — 이 SELECT 문은 **파싱조차 되지 않고** 즉시 실패한다. `0043`이 정의될 때부터(`create or replace function` 자체는 함수 본문 내부 SQL을 검증하지 않으므로) 존재했을 가능성이 높은 원천적 결함이며, 이번 세션에서 처음 실행 시도된 것으로 보인다(라이브 호출자 0건, 아래 §4 참고).

## §4 `bootstrap_did_app()` 호출부 정확한 인자 재확인 — 이번 워크패킷 수정과 무관함 확정

`sql/migrations/0117_create_did_pipeline_rpc.sql` L168-177:

```sql
-- 현재 DID 표시 상태
v_display_state :=
  catchmenu_store.get_did_display_state(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_did_id := v_did_device.id,
    p_locale := coalesce(
      p_locale, v_did_device.default_locale
    )
  );
```

**전부 named argument**이며, `p_did_id`/`p_locale`는 4-param(`0117`) 오버로드에만 존재하는 파라미터명이다 — PostgreSQL은 named argument 매칭 시 해당 이름을 가진 파라미터 목록을 가진 오버로드만 후보로 삼으므로, **이 호출은 현재도 전혀 모호하지 않고, `0043`을 어떻게 처리하든(DROP/유지/수정) 영향받지 않는다.** 이 함수 전체(`sql/migrations/*.sql`)에서 `get_did_display_state`를 실제로 호출하는 곳은 이 한 곳뿐임을 재확인했다(정의/grant/revoke/comment 제외, 전 파일 grep 재확인).

## §5 `0043`의 `p_device_id` — 미사용 파라미터 (신규 발견)

`0043`의 함수 본문 전체(L26-172)를 재확인한 결과, **`p_device_id`는 파라미터 선언(L16) 외에 함수 본문 어디에서도 참조되지 않는다.** 즉 이 함수는 이름과 시그니처가 "디바이스별 상태 조회"를 암시하지만 실제로는 `p_device_id` 값과 무관하게 항상 같은 매장 전체 집계(대기 세션, 호출된 세션, 픽업 준비 주문, 주방 구역별 조리 현황)를 반환한다 — 애초에 디바이스 스코핑이 구현된 적이 없는 것으로 보인다.

## §6 두 오버로드의 개념 비교

| | `0043`(3-param) | `0117`(4-param) |
|---|---|---|
| 조회 대상 테이블 | `catchmenu_pos.order_sessions`, `catchmenu_pos.orders`, `catchmenu_kds.kds_tickets` | `catchmenu_store.did_display_queue` |
| 반환 내용 | 매장 전체: 대기 세션, 호출된 세션, 픽업 준비 주문, 주방 구역별 조리 현황 | 특정 DID 디바이스의 현재 표시 중인 호출 큐(active_calls, current_display) |
| `p_device_id`/`p_did_id` 실제 사용 여부 | **미사용**(§5) | 사용됨(`where did_device_id = p_did_id`) |
| 라이브 호출자 | **0건** | 1건(`bootstrap_did_app()`, named argument) |
| 실행 시 결과 | **하드 크래시**(§3) | 정상 작동 |

두 오버로드는 겹치는 개념이 아니라 **서로 완전히 다른 조회 대상**(매장 전체 운영 현황 vs. 개별 디바이스 표시 큐)이다 — 이름만 같을 뿐 구현이 겹치지 않는다는 점에서 `authorize_kds_release()`(구조적으로 다른 두 유효한 개념)와 유사한 면이 있으나, `0043`이 크래시하고 자신의 핵심 파라미터를 쓰지도 않으며 호출자가 0건이라는 점에서 `confirm_payment_from_provider()`(잃을 기능 없음)와도 유사한 면이 있다 — `600512_Logic.md`에서 이 구분을 다룬다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000002_Naming_Rules.md`(2026-07-14 갱신분 — 600000 대역 파일명 제목 포함 규칙, 이 문서부터 적용)

### Full Rules Required

- `sql/migrations/0043_create_did_display_rpc.sql` — 3-param 오버로드 원본 정의, nested aggregate 결함의 유일한 근거.
- `sql/migrations/0117_create_did_pipeline_rpc.sql` — 4-param 오버로드 정의 및 유일한 실호출부(`bootstrap_did_app()`).
- `600480_confirm_payment_from_provider_overload_ambiguity/600481_Overview_...md`~`600487_...md` — 동일 계열(오버로드 모호성) 선례, Option A/B/C 비교 프레임워크 재사용.

### Domain Indexes

- 해당 없음.

### Excluded Rule Families

- `600491_Overview.md`의 0043/0117 서술 — §0에서 정정 확인, 이 문서의 근거로 사용하지 않음(오류였음).
- `mark_no_show()`/`mark_payment_uncertain()`/`authorize_kds_release()` — 별개의, 이미 다른 workpacket에서 다루는 오버로드 사례, 이번 범위 아님.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600512_Logic_Did_Display_State_Overload.md` 작성 진행 가능.
