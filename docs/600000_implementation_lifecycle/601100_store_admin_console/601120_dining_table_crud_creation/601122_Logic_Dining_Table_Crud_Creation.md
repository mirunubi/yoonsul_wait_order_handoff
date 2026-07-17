# 601122_Logic_Dining_Table_Crud_Creation.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Store Admin Console
Last Updated: 2026-07-17

## Change ID

`dining_table_crud_creation`

## §0 설계 원칙 요약 (승계, `601121_Overview.md` §2 근거를 코드로)

세 함수(`upsert_dining_table()`/`set_dining_table_active()`/`get_dining_table_admin_list()`), 단일 신규 마이그레이션 파일, Store Admin Console 명명·에러응답(`build_error_response`+`message_catalog`) 관례, 오늘 이 세션의 두 가지 핵심 교훈 — (1) 부분 업데이트 생략 필드는 `default null`+`coalesce(p_x, x)`(`601142_Logic.md` §1), (2) 검증은 모든 DML보다 먼저(`601114_ChangeContract.md` §2.10.1) — 을 처음부터 반영한다.

## §1 `catchmenu_store.upsert_dining_table()`

### §1.1 시그니처

```sql
create or replace function catchmenu_store.upsert_dining_table(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid default null,
  p_table_code text default null,
  p_table_name text default null,
  p_capacity int default null,
  p_floor_zone text default null,
  p_table_section text default null,
  p_display_order int default null,
  p_kds_device_id uuid default null,
  p_did_device_id uuid default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_audit, catchmenu_pos, catchmenu_hq
as $$
```

`p_table_id`가 분기 셀렉터(`601121_Overview.md` §2.3) — 생략(NULL)이면 생성, 값이 있으면 수정. `table_status`/`qr_code`/`nfc_tag_id`/`current_session_id`/`occupied_since`/`last_cleaned_at`는 이 시그니처에 **없다** — `601121_Overview.md` §2.5/§3의 결정을 그대로 반영. `kds_device_id`/`did_device_id`는 **포함한다**(`601121_Overview.md` §2.4 2026-07-17 갱신 — 단순 nullable FK pass-through라 QR/NFC와 달리 별도 함수로 분리할 복잡성이 없다는 재분류 근거).

**`table_id`/`table_code` 역할 고정 (`601121_Overview.md` §0.2)**: 이 함수의 반환값·다른 함수와의 연계는 전부 `table_id`(불변 PK)를 통해서만 이뤄진다. `table_code`는 §1.4가 편집 가능하게 설계했지만, 그 편집이 안전한 이유는 정확히 이 원칙 때문이다 — 시스템 어디에도 `table_code`를 조인/조회 키로 쓰는 곳이 없다(`order_sessions`/`orders`의 FK는 전부 `table_id`).

`set_search_path`에 `catchmenu_pos`를 추가했다 — §1.4a의 활성 세션 이중 확인이 `catchmenu_pos.order_sessions`를 참조하기 때문이다(아래).

### §1.2 검증 — 모든 DML보다 먼저 (`601114_ChangeContract.md` §2.10.1 교훈 선제 적용)

```sql
declare
  v_is_new boolean;
  v_existing record;
  v_table_id uuid;
  v_has_active_session boolean;
begin
  v_is_new := p_table_id is null;

  -- 1. 수정 경로: 대상 행 존재 확인 (읽기 전용, DML 없음) — 이번 갱신에서
  --    §1.4a 가드에 필요한 capacity/table_name/current_session_id도 함께 읽는다.
  if not v_is_new then
    select id, capacity, table_name, current_session_id
    into v_existing
    from catchmenu_store.dining_tables
    where id = p_table_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    if v_existing.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'table_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'upsert_dining_table'
      );
    end if;

    -- 활성 세션 이중 확인 (`601121_Overview.md` §2.8) — current_session_id
    -- 프로젝션 컬럼만 믿지 않고 order_sessions.session_status를
    -- 재확인한다(update_table_status()의 기존 가드, 0048:73-94와 동일 패턴).
    v_has_active_session := (
      v_existing.current_session_id is not null
      and exists (
        select 1 from catchmenu_pos.order_sessions
        where id = v_existing.current_session_id
          and session_status not in (
            'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
          )
      )
    );
  end if;

  -- 2. 생성 경로: table_code 필수 (읽기 전용)
  if v_is_new and p_table_code is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_code_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table'
    );
  end if;

  -- 3. table_code 중복 검사 (양쪽 경로, 읽기 전용) — uq_dining_table_store_code의
  --    사용자 친화적 사전 확인. 수정 경로에서는 자기 자신을 제외한다(§1.4의
  --    table_code 편집 허용 결정과 짝을 이룸).
  if p_table_code is not null and exists (
    select 1 from catchmenu_store.dining_tables
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and table_code = p_table_code
      and (v_is_new or id <> p_table_id)
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_code_duplicate',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table'
    );
  end if;

  -- 4. 수정 경로, 활성 세션 존재 시: capacity 축소 금지 (읽기 전용)
  --    (`601121_Overview.md` §2.8 항목 2 — 늘리는 것은 막지 않는다.)
  if not v_is_new
    and v_has_active_session
    and p_capacity is not null
    and p_capacity < v_existing.capacity
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'capacity_reduction_blocked_active_session',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table'
    );
  end if;

  -- 여기까지 어떤 INSERT/UPDATE도 실행되지 않았다 — 네 검증 모두 통과해야
  -- §1.3/§1.4의 DML이 실행된다. 601114_ChangeContract.md §2.10.1이 고친
  -- "검증이 DML보다 뒤에 있어 실패해도 부작용이 남는" 결함 클래스를
  -- 신규 코드에서 원천적으로 만들지 않는다.
```

### §1.3 INSERT 절 (신규 생성)

```sql
  if v_is_new then
    insert into catchmenu_store.dining_tables (
      tenant_id, store_id,
      table_code, table_name,
      capacity, floor_zone, table_section,
      display_order, kds_device_id, did_device_id
    ) values (
      p_tenant_id, p_store_id,
      p_table_code, p_table_name,
      coalesce(p_capacity, 4),
      p_floor_zone, p_table_section,
      coalesce(p_display_order, 0),
      p_kds_device_id, p_did_device_id
    )
    returning id into v_table_id;
```

`table_status`(스키마 기본값 `'AVAILABLE'`)와 `is_active`(스키마 기본값 `true`)는 컬럼 목록에서 아예 제외했다 — 컬럼을 INSERT 문에서 완전히 생략하면 PostgreSQL이 스키마 DEFAULT를 그대로 적용한다(`601142_Logic.md` §4.0이 확인한 "명시적으로 NULL을 넣는 것"과의 차이 — 여기서는 애초에 값 자체를 안 준다). `capacity`/`display_order`는 `coalesce(p_x, <스키마 기본값>)`으로 명시했다 — 스키마 DEFAULT와 결과는 같지만, 파라미터가 생략(NULL)됐을 때의 의도를 코드에서 명확히 드러낸다(`price`의 `coalesce(p_price, 0)` 관례, `601142_Logic.md` §1 point 4).

### §1.4 UPDATE 절 (부분 수정 — 생략 필드 보존)

```sql
  else
    update catchmenu_store.dining_tables
    set
      table_code = coalesce(p_table_code, table_code),
      table_name = coalesce(p_table_name, table_name),
      capacity = coalesce(p_capacity, capacity),
      floor_zone = coalesce(p_floor_zone, floor_zone),
      table_section = coalesce(p_table_section, table_section),
      display_order = coalesce(p_display_order, display_order),
      kds_device_id = coalesce(p_kds_device_id, kds_device_id),
      did_device_id = coalesce(p_did_device_id, did_device_id),
      updated_at = now()
    where id = p_table_id;

    v_table_id := p_table_id;

    -- 성공-경로 예방적 감사 (`601121_Overview.md` §2.8 항목 3) — 활성 세션이
    -- 걸린 테이블의 table_name이 실제로 바뀐 경우에만 기록. 실패 시에만
    -- 도는 §1.5의 EXCEPTION 핸들러 감사와는 별개로, 이 호출은 항상
    -- (성공 경로에서) 조건이 맞으면 실행된다.
    if v_has_active_session
      and p_table_name is not null
      and p_table_name is distinct from v_existing.table_name
    then
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'system',
        p_audit_type := 'dining_table_name_changed_during_active_session',
        p_audit_category := 'OPERATIONAL',
        p_actor_type := 'STAFF',
        p_actor_id := p_actor_id,
        p_subject_type := 'dining_table',
        p_subject_id := p_table_id,
        p_decision := 'COMPLETED',
        p_before_state := jsonb_build_object('table_name', v_existing.table_name),
        p_after_state := jsonb_build_object('table_name', p_table_name),
        p_decision_payload := jsonb_build_object(
          'current_session_id', v_existing.current_session_id
        )
      );
    end if;
  end if;
```

**`table_code`를 UPDATE SET 절에 포함한 것은 `upsert_menu_core()`의 기존 관례와의 의도적 차이다** — `upsert_menu_core()`의 UPDATE 절에는 `menu_code`가 없다(생성 후 불변). 반면 `table_code`는 물리적으로 테이블에 인쇄/부착된 라벨이므로 재배치·재인쇄 등으로 나중에 바꿔야 할 현실적 필요가 있다고 판단해 편집 가능하게 설계했다. `601121_Overview.md` §0.2가 확정했듯 `table_code`는 시스템 내부 조인/조회 키가 아니므로(그 역할은 전적으로 `table_id`) 이 편집이 참조 무결성을 위협하지 않는다. 이 판단이 실제 운영 요구와 맞는지는 Open Item(§8)으로 남긴다 — 만약 불변으로 확정되면 이 한 줄과 §1.2의 "자기 자신 제외" 조건만 제거하면 된다(다른 로직에 영향 없음).

**세 번째 가드(이름 변경 감사)가 `p_table_name is distinct from v_existing.table_name`을 조건으로 넣은 이유**: `coalesce(p_table_name, table_name)`은 `p_table_name`이 생략(NULL)되면 항상 기존값을 그대로 쓰므로 실질적 변경이 없다 — 매 UPDATE 호출마다(값이 바뀌지 않았어도) 감사 기록을 남기면 노이즈만 커진다. "실제로 다른 값이 들어왔을 때만" 기록하도록 명시적으로 비교한다.

### §1.5 EXCEPTION 핸들러 (`000701_Guide_Controlled_AI_Development_Pipeline.md` §41 적용)

```sql
  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'table_id', v_table_id,
      'is_new', v_is_new
    ),
    'message_code', case
      when v_is_new then 'table_created'
      else 'table_updated'
    end
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'system',
      p_audit_type := 'dining_table_upsert_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'dining_table',
      p_subject_id := p_table_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_code', p_table_code
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'dining_table_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_dining_table',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**(2026-07-17 정정, Stage 6 Critical tier(Cursor+Codex) 지적 — 이전 버전은 `raise;`였다)** 이전 버전은 감사 기록 후 `raise;`(원본 예외 재발생)로 끝났으나, 이번 턴 라이브 실증으로 이 조합이 **감사 기록 자체를 무효화한다**는 것을 확인했다: `append_audit_record()`는 `dblink`/`pg_background` 같은 autonomous transaction 메커니즘이 전혀 없는 평범한 PL/pgSQL 함수이고(`sql/migrations/0023_create_append_audit_rpc.sql` 직접 확인), PL/pgSQL의 `EXCEPTION` 블록은 실패한 부분만 암묵적 SAVEPOINT로 되돌릴 뿐 핸들러 자체의 코드(`append_audit_record()` 호출 포함)는 별도로 격리되지 않는다 — 이 함수가 단일 최상위 문(Supabase RPC 호출의 일반적인 형태, autocommit)으로 호출되면, 핸들러 안에서 방금 기록한 감사 행까지 포함해 문 전체가 원자적으로 롤백된다. 이번 턴 직접 재현(임시 함수로 `append_audit_record()` 호출 후 `raise exception`, 단일 최상위 `select`로 호출)한 결과 감사 행이 **실제로 남지 않음**을 확인했다.

`000701` §41.1은 "기록 후 원래 에러를 재발생시키거나(`RAISE`) **적절한 에러 응답을 반환한다**"고 두 가지 선택지를 명시한다 — 위 실증 결과, 감사 기록이 실제로 영구히 남으려면 **후자(에러 응답 반환)만 유효한 선택**이다: `RAISE`를 쓰면 그 문장 자체가 요구하는 "영구 기록"이 구조적으로 불가능해진다. 따라서 `build_error_response()`를 통한 구조화된 에러 응답 반환으로 변경했다 — 신규 에러 키 `dining_table_operation_failed`를 §5에 추가한다(§5 갱신 참고).

`p_audit_domain := 'system'`을 선택한 근거는 `601140` Slice 1이 `menu_price_changed` 이벤트에 `'system'`을 선택한 것과 동일하다(`601114_ChangeContract.md` §2.7) — 테이블 마스터데이터 등록은 주문/결제 같은 트랜잭션 이벤트가 아니라 카탈로그 설정 행위이기 때문이다. `p_audit_category := 'OPERATIONAL'`은 `register_table_qr()`의 `'SECURITY'`(§2.5, QR/NFC는 물리적 보안 앵커)와 의도적으로 다르다 — 이 함수는 순수 메타데이터 CRUD이지 보안 이벤트가 아니다. `catchmenu_ledger.audit_records.chk_audit_domain`(`'system'` 포함)/`chk_audit_category`(`'OPERATIONAL'` 포함) 둘 다 라이브 확인해 유효한 값임을 확인했다.

## §2 `catchmenu_store.set_dining_table_active()`

`601121_Overview.md` §2.6의 권장안(양방향)을 채택한 설계. 최종 채택 여부는 Open Item(`601121_Overview.md` §6 (a))으로 남아 있으나, 이 문서는 그 권장안을 기준으로 구체화한다 — 단방향(`deactivate_dining_table()`)으로 확정되면 `p_is_active` 파라미터를 제거하고 함수 본문에서 `false` 고정, 재활성화 경로는 별도 미결 사안으로 남기면 된다(구조 변경 미미).

```sql
create or replace function catchmenu_store.set_dining_table_active(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_id uuid,
  p_is_active boolean,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_audit, catchmenu_pos, catchmenu_hq
as $$
declare
  v_table record;
  v_has_active_session boolean;
begin
  select id, table_code, is_active, current_session_id
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_table.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active'
    );
  end if;

  -- 활성 세션 이중 확인 — §1.2의 v_has_active_session과 동일한 패턴
  -- (`601121_Overview.md` §2.8, update_table_status()의 0048:73-94 가드와 동일).
  v_has_active_session := (
    v_table.current_session_id is not null
    and exists (
      select 1 from catchmenu_pos.order_sessions
      where id = v_table.current_session_id
        and session_status not in (
          'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
        )
    )
  );

  -- 진행 중인 세션이 있는 테이블은 비활성화할 수 없다. 물리 삭제가
  -- 아니므로 FK 위반은 없지만, 활성 세션이 걸린 테이블을 목록에서
  -- 숨기면 스태프가 진행 중인 세션을 놓칠 위험이 있다.
  if p_is_active = false and v_has_active_session then
    return catchmenu_common.build_error_response(
      p_error_key := 'table_has_active_session',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active'
    );
  end if;

  if v_table.is_active = p_is_active then
    return jsonb_build_object(
      'success', true,
      'data', jsonb_build_object(
        'table_id', p_table_id,
        'is_active', p_is_active
      ),
      'message_code', 'table_active_unchanged'
    );
  end if;

  update catchmenu_store.dining_tables
  set is_active = p_is_active, updated_at = now()
  where id = p_table_id;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'is_active', p_is_active
    ),
    'message_code', case
      when p_is_active then 'table_activated'
      else 'table_deactivated'
    end
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'system',
      p_audit_type := 'dining_table_active_toggle_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'dining_table',
      p_subject_id := p_table_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'requested_is_active', p_is_active
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'dining_table_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_dining_table_active',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**(2026-07-17 정정)** §1.5와 동일한 이유로 `raise;`를 `build_error_response()` 반환으로 변경했다 — 근거/실증은 §1.5를 그대로 참조.

물리 DELETE는 이 함수에도, 다른 어떤 함수에도 제공하지 않는다 — `601121_Overview.md` §1.3의 FK(`order_sessions.table_id`/`orders.table_id`, `ON DELETE NO ACTION`)가 이를 요구한다. `is_active = false`가 이 코드베이스에서 유일하게 안전한 "삭제"다.

## §3 `catchmenu_store.get_dining_table_admin_list()`

```sql
create or replace function catchmenu_store.get_dining_table_admin_list(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_tables jsonb;
  v_active_count int;
  v_inactive_count int;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'table_code', t.table_code,
        'table_name', t.table_name,
        'capacity', t.capacity,
        'floor_zone', t.floor_zone,
        'table_section', t.table_section,
        'display_order', t.display_order,
        'table_status', t.table_status,
        'qr_code', t.qr_code,
        'nfc_tag_id', t.nfc_tag_id,
        'kds_device_id', t.kds_device_id,
        'did_device_id', t.did_device_id,
        'is_active', t.is_active,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      )
      order by t.floor_zone, t.display_order, t.table_code
    ),
    '[]'::jsonb
  )
  into v_tables
  from catchmenu_store.dining_tables t
  where t.store_id = p_store_id
    and t.tenant_id = p_tenant_id;
    -- is_active 필터 없음 — get_table_floor_map()과의 핵심 차이
    -- (601121_Overview.md §2.7).

  select
    count(*) filter (where is_active = true),
    count(*) filter (where is_active = false)
  into v_active_count, v_inactive_count
  from catchmenu_store.dining_tables
  where store_id = p_store_id and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'tables', v_tables,
      'table_count', jsonb_array_length(v_tables),
      'active_count', v_active_count,
      'inactive_count', v_inactive_count
    ),
    'message_code', 'dining_table_admin_list_loaded'
  );
end;
$$;
```

**포함/제외 근거**: `table_status`/`qr_code`/`nfc_tag_id`는 읽기 전용으로 노출한다(관리자가 현재 무엇이 할당돼 있는지 봐야 하므로) — 하지만 이 값들을 **쓰는** 경로는 여전히 각각 `update_table_status()`/`register_table_qr()`뿐이다(§1.1이 이 함수의 파라미터에서 이미 제외). `current_session_id`/`occupied_since`/`last_cleaned_at`은 완전히 제외했다 — 이 함수는 마스터데이터 관리 목적이지 실시간 플로어 현황 목적이 아니며, 후자는 이미 `get_table_floor_map()`이 전담한다(`601121_Overview.md` §1.2/§3).

이 함수는 `stable`(읽기 전용)이므로 §1.5/§2의 `EXCEPTION`+`append_audit_record()` 패턴을 넣지 않았다 — `get_table_floor_map()`/`get_menu_admin_list()` 등 기존 읽기 전용 함수들도 동일하게 이 패턴이 없다(라이브 확인, 조회 실패에 대한 감사 기록 관례가 이 코드베이스에 없음). `000701` §41.1이 "모든 RPC 함수"라고 쓴 것과는 표면적으로 다를 수 있어 Open Item(§8)으로 남긴다.

## §4 GRANT/REVOKE

```sql
do $$
begin
  revoke all on function catchmenu_store.upsert_dining_table(
    uuid, uuid, uuid, text, text, int, text, text, int,
    uuid, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_store.upsert_dining_table(
    uuid, uuid, uuid, text, text, int, text, text, int,
    uuid, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.set_dining_table_active(
    uuid, uuid, uuid, boolean, uuid, text
  ) from public;
  grant execute on function catchmenu_store.set_dining_table_active(
    uuid, uuid, uuid, boolean, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_dining_table_admin_list(
    uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_store.get_dining_table_admin_list(
    uuid, uuid, text
  ) to authenticated;
end;
$$;
```

`0048`의 4개 함수 전부가 이 명시적 `REVOKE ALL FROM PUBLIC` + `GRANT ... TO authenticated` 패턴을 쓴다(`0048:617-647`) — `601142_Logic.md` §1.2/§3(a)가 `upsert_menu_core()`의 `proacl`이 NULL(= 명시적 REVOKE가 없어 PUBLIC 기본 실행 권한이 그대로 열려 있던 결함)이었음을 지적한 바로 그 문제를 신규 함수 3개 전부에서 처음부터 차단한다.

## §5 `message_catalog` / `error_codes` i18n 등록

```sql
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('table_created', 'ko', '테이블이 등록되었습니다'),
('table_created', 'en', 'Table created'),
('table_updated', 'ko', '테이블 정보가 수정되었습니다'),
('table_updated', 'en', 'Table updated'),
('table_activated', 'ko', '테이블이 활성화되었습니다'),
('table_activated', 'en', 'Table activated'),
('table_deactivated', 'ko', '테이블이 비활성화되었습니다'),
('table_deactivated', 'en', 'Table deactivated'),
('dining_table_admin_list_loaded', 'ko', '테이블 목록이 로드되었습니다'),
('dining_table_admin_list_loaded', 'en', 'Table list loaded'),
('table_not_found', 'ko', '테이블을 찾을 수 없습니다'),
('table_not_found', 'en', 'Table not found'),
('table_code_required', 'ko', '테이블 코드는 필수입니다'),
('table_code_required', 'en', 'Table code is required'),
('table_code_duplicate', 'ko', '이미 사용 중인 테이블 코드입니다'),
('table_code_duplicate', 'en', 'Table code already in use'),
('table_has_active_session', 'ko', '진행 중인 세션이 있어 비활성화할 수 없습니다'),
('table_has_active_session', 'en', 'Cannot deactivate a table with an active session'),
('capacity_reduction_blocked_active_session', 'ko', '진행 중인 세션이 있어 정원을 줄일 수 없습니다'),
('capacity_reduction_blocked_active_session', 'en', 'Cannot reduce capacity while an active session is bound to this table'),
('dining_table_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
('dining_table_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7105, 'table_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7106, 'table_code_required',
  'STORE', 'INVALID_INPUT', 400, 'WARNING'),
(7107, 'table_code_duplicate',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7108, 'table_has_active_session',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7109, 'capacity_reduction_blocked_active_session',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7110, 'dining_table_operation_failed',
  'STORE', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;
```

**(2026-07-17 정정, §1.5/§2의 EXCEPTION 핸들러가 `raise;`에서 `build_error_response()` 반환으로 바뀌면서 신규 추가)** `dining_table_operation_failed`(7110)는 `upsert_dining_table()`/`set_dining_table_active()`의 `EXCEPTION` 핸들러가 반환하는 범용 내부 오류 키다 — `sqlerrm`/`sqlstate`는 사용자 메시지에 노출하지 않고 감사 기록(`decision_payload`)과 `build_error_response()`의 `p_details`(진단용, `catchmenu_common.log_diagnostic()` 경유)에만 남긴다.

**(2026-07-17 정정, Codex 검증 지적)** `error_category`는 최초 `'INTERNAL_ERROR'`로 썼으나, 라이브 `chk_error_category` 제약을 이번 턴 재확인한 결과 허용값은 `NOT_FOUND`/`CONFLICT`/`INVALID_INPUT`/`PERMISSION`/`BUSINESS_RULE`/`TECHNICAL`/`TIMEOUT`/`CAPACITY`/`FINANCIAL`/`SECURITY`/`INTEGRATION`/`RECOVERABLE`뿐이다 — `'INTERNAL_ERROR'`는 이 목록에 없어 그대로 삽입하면 제약 위반으로 실패했을 것이다. `'TECHNICAL'`로 정정한다 — 이 에러는 요청 자체의 문제(입력 검증 실패, 충돌 등)가 아니라 처리 중 예기치 못한 시스템 예외(`chk_dining_table_capacity` 같은 방어되지 않은 제약 위반 등)를 가리키므로, 나열된 값 중 `'TECHNICAL'`이 가장 근접한 의미다.

**(중요, Stage 5/8 재확인 필요)** `code` 7105-7110은 이번 턴 라이브 확인한 `select max(code) from catchmenu_common.error_codes where error_domain='STORE'` = `7104`를 기준으로 다음 번호를 잠정 배정한 것이다 — `0110`이 등록한 7040-7044보다 큰 것은 그 사이 다른 워크패킷(`601110`/`601140`)이 이미 이 범위에 번호를 추가했기 때문으로 추정된다(이번 턴 원인까지는 추적하지 않음). 이 문서 작성 시점과 Stage 8 구현 시점 사이에 값이 달라질 수 있으므로 구현 직전 재조회해 확정한다. `error_domain := 'STORE'`는 `0110`의 기존 5개 코드(`7040`-`7044`)와 동일 도메인을 그대로 따른다 — 이 함수들도 `catchmenu_store` 스키마의 Store Admin Console 소속이기 때문이다.

`message_catalog`는 `0110`의 관례(자신이 새로 쓰는 키만 `ko`/`en` 2개 로케일로 등록, `0093`처럼 6개 전체 로케일을 등록하지 않음)를 그대로 따랐다 — 신규 로케일 확장이 필요하면 별도 워크패킷 몫이다.

## §6 마이그레이션 파일 배치

파일: `sql/migrations/0162_create_dining_table_admin_rpc.sql`(잠정, `601121_Overview.md` §2.2/§6 (b) 참고 — Stage 5에서 번호 재확인).

헤더는 `0048`/`0110`의 형식을 따른다:

```sql
-- 0162_create_dining_table_admin_rpc.sql
-- Purpose: Dining table admin CRUD RPCs (create/edit/activate-deactivate/list).
--          0048_create_table_management_rpc.sql의 운영 RPC(상태/QR/해제)와
--          역할이 다르다 — 이 파일은 테이블 마스터데이터 등록/관리 전담.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0161_mark_no_show_overload_and_redesign.sql
-- Creates:
--   function catchmenu_store.upsert_dining_table(...)
--   function catchmenu_store.set_dining_table_active(...)
--   function catchmenu_store.get_dining_table_admin_list(...)
```

`Depends on`은 잠정(§2.2와 동일한 사유로 구현 직전 재확인).

## §7 TestPlan 영향 확인

- 신규 함수 3개이므로 기존 회귀 대상 자체가 없다(`601121_Overview.md` §5).
- `0 diff` 경계: `0048`(4개 함수)과 `0050`의 `estimate_wait_time()` — 이 문서의 어떤 SQL도 그 함수들의 본문을 참조/수정하지 않는다.
- 최소 커버리지(TestPlan 단계에서 확정할 후보): §1.2의 네 검증(존재/필수/중복/활성세션 정원축소) 각각의 실패 케이스, §1.4의 8개 필드(`kds_device_id`/`did_device_id` 포함) 각각의 부분 업데이트 보존, `table_code` 자기-자신-제외 중복 검사(같은 코드로 재저장해도 에러 안 남), §2의 활성 세션 비활성화 가드, §2의 멱등 재호출(`table_active_unchanged`), §3의 비활성 포함 전체 목록 vs `get_table_floor_map()`의 활성만 필터 대조, `capacity <= 0` 시도(스키마 CHECK 위반 → `EXCEPTION` 핸들러 경유 확인 — **2026-07-17 정정**: 핸들러가 이제 `raise;`가 아니라 `build_error_response()`를 반환하므로, 이 테스트는 호출 자체가 클라이언트 레벨에서 에러로 실패하는 것이 아니라 `success:false`, `error.key = 'dining_table_operation_failed'`를 정상적으로 반환하는지, 그리고 **그 반환이 정상 완료되기 때문에** `catchmenu_ledger.audit_records`의 `FAILED` 행이 실제로 영구 기록되는지까지 함께 확인해야 한다 — `raise;` 방식이었다면 이 감사 행은 구조적으로 남을 수 없었다, §1.5 참고). **(신규, §1.4/§2.8)** 활성 세션 중 `capacity` 축소 시도 거부(늘리는 것은 허용 확인 포함), 활성 세션 중 `table_name` 변경 성공 + 예방적 감사 기록 생성 확인(`append_audit_record` 호출 여부를 `catchmenu_ledger.audit_records`에서 직접 조회), `current_session_id`는 채워져 있지만 대응 `order_sessions.session_status`가 이미 종료 상태(`COMPLETED` 등)인 "프로젝션 드리프트" 케이스에서 가드가 오작동하지 않는지(§1.2/§2의 이중 확인 로직이 실제로 이 케이스를 올바르게 처리하는지).

## §8 Open Items

(a) `601121_Overview.md` §6 (a) — `set_dining_table_active()`(양방향, 이 문서가 구체화한 안) vs `deactivate_dining_table()`(단방향) 최종 채택, Human 결정.
(b) `table_code`를 UPDATE 절에서 편집 가능하게 설계한 것(§1.4, `upsert_menu_core()`의 `menu_code` 불변 관례와의 의도적 차이)이 실제 운영 요구와 맞는지 — Human 검토 필요.
(c) `get_dining_table_admin_list()`에 `EXCEPTION`+`append_audit_record()`를 넣지 않은 것(§3 말미)이 `000701` §41.1("모든 RPC 함수")과 표면적으로 어긋나는지, 아니면 기존 읽기 전용 함수 관례(`get_table_floor_map()`/`get_menu_admin_list()` 등)를 따르는 것이 맞는지 — Human/ChangeContract 단계에서 명확한 해석 필요.
(d) `error_codes`의 `code` 값(7105-7110)과 마이그레이션 파일 번호(`0162`)는 잠정 — Stage 5/8에서 라이브 재조회 후 확정(§5/§6).
(e) `601121_Overview.md` §6의 (c)/(d)/(e) — `get_dining_table_admin_list()` 반환 구조 최종 확정(이 문서 §3이 1차 구체화), `0044`류 고객 대면 경로의 `dining_tables` 참조 여부 미확인, `capacity` 기본값 UX 적합성 — 전부 이 문서에서 이어받아 그대로 유효.
(f) `601121_Overview.md` §6 (f) — "Staff Seating And Table Assignment Orchestration Contract" 후속 워크패킷 Open Item, 이 문서에서도 승계. `upsert_dining_table()`/`set_dining_table_active()`가 만드는 `table_id`가 그 후속 워크패킷의 앵커가 된다는 점만 이 문서에서 재확인한다 — 조사/설계는 하지 않는다.
(g) **[신규]** §1.4/§2.8의 "capacity 축소 제한"이 정확히 `p_capacity < 기존 capacity`인 경우만 막는데, 활성 세션의 실제 `guest_count`(착석 인원)보다 낮게 줄이는 것까지 막아야 하는지, 아니면 기존 capacity 값 자체를 기준으로 막는 지금 설계로 충분한지는 근거 없이 후자로 단순화했다 — 실제 운영 요구에 따라 `order_sessions.guest_count`를 참조하는 정교한 버전으로 바뀔 수 있다.
(h) **[신규, 2026-07-17, Stage 6 Critical tier 지적 — TestPlan 실패-경로 감사 테스트 작성 중 발견, 라이브 실증 완료]** §1.5/§2의 `EXCEPTION` 핸들러를 `raise;`에서 `build_error_response()` 반환으로 변경했다 — `append_audit_record()`가 autonomous transaction 메커니즘이 없는 평범한 함수이고, 단일 최상위 문 호출(일반적인 RPC 호출 형태) 안에서 감사 기록 후 `raise;`하면 그 감사 INSERT까지 통째로 롤백됨을 라이브로 재현해 확인했다(임시 함수로 직접 재현, 감사 행 0건 확인). 이 정정으로 신규 에러 키 `dining_table_operation_failed`(§5, 코드 7110)가 추가됐다 — 클라이언트는 이제 원본 Postgres 예외 대신 구조화된 `success:false` 응답을 받는다. 이 패턴이 이 세션의 다른 워크패킷(`601140` 등)에도 동일하게 적용되는 `EXCEPTION`+`RAISE` 조합에 잠재하는지는 이번 턴에 조사하지 않았다 — 다만 `601140`의 `upsert_menu_core()`는 애초에 `EXCEPTION` 핸들러 자체가 없어(§41 확정 이전 작성) 이 특정 문제와는 무관하다(§1.5 참고).

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, TestPlan/ChangeContract 단계로 진행 가능.** §1-§3에서 세 함수(`upsert_dining_table()`/`set_dining_table_active()`/`get_dining_table_admin_list()`) 전체를 실제 SQL 수준으로 설계했다 — 검증-선행 순서(§1.2), `default null`+`coalesce(p_x, x)` 부분 업데이트 보존(§1.4), `000701` §41 예외 처리(§1.5/§2), GRANT/REVOKE(§4), i18n 등록(§5), 마이그레이션 파일 배치(§6)까지 포함한다. `kds_device_id`/`did_device_id`를 CRUD 파라미터로 포함시켰고(§1.1), `table_id`/`table_code` 역할 고정을 명시했으며(§1.1), 활성 세션 이중 확인 로직(`current_session_id` + `order_sessions.session_status` 재확인, §1.2/§2)과 이를 적용한 세 가드(비활성화 금지/`capacity` 축소 제한/`table_name` 변경 시 예방적 감사, §1.2/§1.4/§2)를 구체적 SQL로 설계했다.

**(2026-07-17 정정, Stage 6 Critical tier 지적 — 라이브 실증 완료)** §1.5/§2의 `EXCEPTION` 핸들러를 `raise;`에서 `build_error_response()` 반환으로 정정했다 — `append_audit_record()` 후 `raise;`하면 단일 최상위 문 호출 시 그 감사 기록까지 함께 롤백된다는 것을 임시 함수로 직접 재현해 확인했고(§8 (h)), 신규 에러 키 `dining_table_operation_failed`(§5, 코드 7110)를 추가했다.

`table_code` 편집 가능 여부(§1.4)와 양방향 활성화 토글 채택 여부(§2)는 근거를 제시하되 최종 확정은 Human 결정으로 명시적으로 남겼다(§8). `.sql` 파일은 생성·수정하지 않았다.
