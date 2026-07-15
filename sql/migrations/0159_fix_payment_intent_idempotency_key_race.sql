-- 0159_fix_payment_intent_idempotency_key_race.sql
-- Purpose: Close the observed payment_intents race condition by enforcing
--          deterministic idempotency_key uniqueness and making the shared
--          resolver return the surviving row under concurrent inserts.
-- Depends on:
--   0158_confirm_payment_intent_linkage_fix.sql
-- Background:
--   600560_payment_intent_race_condition_fix confirmed that concurrent
--   resolve_or_create_payment_intent() calls can create duplicate observed
--   payment_intents rows with the same deterministic idempotency_key.
--   Stage 4 prechecks reconfirmed the known loser row has no FK references.
-- Human decision:
--   2026-07-16 Human Boundary Approval for
--   600564_ChangeContract.md, option (a).
-- Non-goals:
--   Does not modify confirm_payment(), confirm_payment_from_provider(),
--   0098/0103/0109/0130/0142 source files, payment ledger schema,
--   advisory lock behavior, or orders locking behavior.

delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';

alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);

create or replace function catchmenu_payment.resolve_or_create_payment_intent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_requested_amount int,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_intent_origin text,
  p_origin_reference jsonb default '{}'::jsonb,
  p_intent_id uuid default null,
  p_session_id uuid default null,
  p_locale text default 'ko'
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_intent_id uuid;
  v_candidate_count int;
  v_session_id uuid;
  v_business_day date;
  v_timezone text;
  v_payment_method text;
  v_payment_channel text;
  v_provider_type text;
  v_origin_reference jsonb;
begin
  if p_intent_origin not in (
    'PREAUTHORIZED',
    'POS_SYNTHESIZED',
    'MANUAL_ENTRY',
    'VAN_SYNTHESIZED',
    'IMPORTED'
  ) then
    return null;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  v_business_day := (
    timezone(coalesce(v_timezone, 'Asia/Seoul'), now())
  )::date;

  select session_id into v_session_id
  from catchmenu_pos.orders
  where id = p_order_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  v_session_id := coalesce(p_session_id, v_session_id);
  v_origin_reference := coalesce(p_origin_reference, '{}'::jsonb);

  v_payment_method := case
    when p_payment_method in (
      'CARD',
      'SIMPLE_PAY_KAKAO',
      'SIMPLE_PAY_NAVER',
      'SIMPLE_PAY_TOSS',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'VOUCHER',
      'MIXED'
    ) then p_payment_method
    when p_payment_method in ('CREDIT_CARD', 'DEBIT_CARD') then 'CARD'
    else 'CARD'
  end;

  v_payment_channel := case
    when p_payment_channel in (
      'KIOSK_CARD',
      'KIOSK_QR',
      'TABLE_QR',
      'CUSTOMER_APP',
      'STAFF_POS',
      'COUNTER_CARD',
      'ONLINE'
    ) then p_payment_channel
    else 'STAFF_POS'
  end;

  v_provider_type := case
    when p_provider_type in (
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'KAKAO_PAY',
      'NAVER_PAY',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'INTERNAL'
    ) then p_provider_type
    when p_provider_type in ('NICE', 'NICE_VAN') then 'VAN_NICE'
    when p_provider_type in ('KIS', 'KIS_VAN') then 'VAN_KIS'
    when p_provider_type in ('KICC', 'KICC_VAN') then 'VAN_KICC'
    else 'INTERNAL'
  end;

  if p_intent_id is not null then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where id = p_intent_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id;

    if v_intent_id is null then
      return null;
    end if;

    update catchmenu_payment.payment_intents
    set
      intent_origin = coalesce(intent_origin, p_intent_origin),
      origin_reference = coalesce(origin_reference, v_origin_reference),
      updated_at = now()
    where id = v_intent_id;

    return v_intent_id;
  end if;

  select count(*)
  into v_candidate_count
  from catchmenu_payment.payment_intents
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and intent_origin = p_intent_origin
    and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
    and intent_status in (
      'CREATED',
      'PENDING',
      'PROCESSING',
      'CONFIRMED'
    );

  if v_candidate_count > 1 then
    raise exception
      'payment_intent_resolution_conflict: tenant=%, store=%, order=%, origin=%',
      p_tenant_id, p_store_id, p_order_id, p_intent_origin
      using errcode = 'P0001';
  end if;

  if v_candidate_count = 1 then
    select id into v_intent_id
    from catchmenu_payment.payment_intents
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and order_id = p_order_id
      and intent_origin = p_intent_origin
      and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
      and intent_status in (
        'CREATED',
        'PENDING',
        'PROCESSING',
        'CONFIRMED'
      )
    order by created_at desc
    limit 1;

    return v_intent_id;
  end if;

  insert into catchmenu_payment.payment_intents (
    tenant_id,
    store_id,
    order_id,
    session_id,
    intent_status,
    payment_method,
    payment_channel,
    requested_amount,
    currency,
    provider_type,
    provider_order_id,
    idempotency_key,
    business_day,
    business_timezone,
    intent_origin,
    origin_reference
  ) values (
    p_tenant_id,
    p_store_id,
    p_order_id,
    v_session_id,
    'CONFIRMED',
    v_payment_method,
    v_payment_channel,
    p_requested_amount,
    'KRW',
    v_provider_type,
    null,
    'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
      || substr(md5(v_origin_reference::text), 1, 12),
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    p_intent_origin,
    v_origin_reference
  )
  on conflict (idempotency_key) do update
  set updated_at = now()
  returning id into v_intent_id;

  return v_intent_id;
end;
$$;

revoke all on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) from public;

grant execute on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) to authenticated;

comment on function catchmenu_payment.resolve_or_create_payment_intent(
  uuid, uuid, uuid, int, text, text, text, text, jsonb, uuid, uuid, text
) is
  'Shared payment_intents resolver for PREAUTHORIZED and observed payment confirmation paths. Validates explicit PREAUTHORIZED ids, reuses an existing matching intent, or creates one observed intent for POS_SYNTHESIZED, MANUAL_ENTRY, or VAN_SYNTHESIZED flows. Observed inserts are protected by uq_payment_intents_idempotency_key and ON CONFLICT RETURNING so concurrent callers receive the same intent id.';
