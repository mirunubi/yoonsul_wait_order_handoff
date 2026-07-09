-- 0142_patch_toss_mvp_payment_intent_binding.sql
-- Scope: 604260 Toss MVP PaymentIntent Binding Precondition only.
-- Historical migrations remain immutable.

alter table catchmenu_integrations.toss_payment_requests
  add column if not exists payment_intent_id uuid;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'fk_toss_payment_requests_payment_intent'
      and conrelid =
        'catchmenu_integrations.toss_payment_requests'::regclass
  ) then
    alter table catchmenu_integrations.toss_payment_requests
      add constraint fk_toss_payment_requests_payment_intent
      foreign key (payment_intent_id)
      references catchmenu_payment.payment_intents(id);
  end if;
end;
$$;

create index if not exists idx_toss_requests_payment_intent
  on catchmenu_integrations.toss_payment_requests(payment_intent_id)
  where payment_intent_id is not null;

create or replace function
  catchmenu_integrations.bind_toss_payment_intent()
returns trigger
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_order record;
  v_candidate record;
  v_candidate_count int := 0;
  v_intent_id uuid;
  v_intent_result jsonb;
  v_payment_channel text;
begin
  if new.order_id is null then
    raise exception using
      errcode = '23502',
      message = 'TOSS_PAYMENT_INTENT_ORDER_REQUIRED';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(
      new.tenant_id::text || ':' || new.store_id::text || ':' ||
      new.order_id::text,
      604260
    )
  );

  select o.id, o.session_id, o.order_type, o.order_channel,
         o.final_amount
  into v_order
  from catchmenu_pos.orders o
  where o.id = new.order_id
    and o.tenant_id = new.tenant_id
    and o.store_id = new.store_id
  for share;

  if v_order.id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_ORDER_NOT_FOUND';
  end if;

  if v_order.final_amount <> new.amount then
    raise exception using
      errcode = '23514',
      message = 'TOSS_PAYMENT_INTENT_AMOUNT_MISMATCH';
  end if;

  if v_order.order_type in ('DINE_IN', 'KIOSK', 'STAFF_ORDER')
    and v_order.session_id is null
  then
    raise exception using
      errcode = '23502',
      message = 'TOSS_PAYMENT_INTENT_SESSION_REQUIRED';
  end if;

  if new.payment_intent_id is not null then
    select pi.id
    into v_intent_id
    from catchmenu_payment.payment_intents pi
    where pi.id = new.payment_intent_id
      and pi.tenant_id = new.tenant_id
      and pi.store_id = new.store_id
      and pi.order_id = new.order_id
      and pi.requested_amount = new.amount
      and pi.provider_type = 'TOSS_PAYMENTS'
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
    for update;

    if v_intent_id is null then
      raise exception using
        errcode = '23503',
        message = 'TOSS_PAYMENT_INTENT_BINDING_INVALID';
    end if;

    return new;
  end if;

  for v_candidate in
    select pi.id, pi.session_id, pi.requested_amount,
           pi.provider_type
    from catchmenu_payment.payment_intents pi
    where pi.tenant_id = new.tenant_id
      and pi.store_id = new.store_id
      and pi.order_id = new.order_id
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
    order by pi.created_at
    for update
  loop
    v_candidate_count := v_candidate_count + 1;
    v_intent_id := v_candidate.id;

    if v_candidate_count > 1 then
      raise exception using
        errcode = '23505',
        message = 'TOSS_PAYMENT_INTENT_BINDING_CONFLICT';
    end if;

    if v_candidate.requested_amount <> new.amount
      or v_candidate.provider_type <> 'TOSS_PAYMENTS'
      or v_candidate.session_id is distinct from v_order.session_id
    then
      raise exception using
        errcode = '23514',
        message = 'TOSS_PAYMENT_INTENT_ACTIVE_INTENT_MISMATCH';
    end if;
  end loop;

  if v_candidate_count = 0 then
    v_payment_channel := case v_order.order_channel
      when 'KIOSK' then 'KIOSK_QR'
      when 'TABLE_QR' then 'TABLE_QR'
      when 'CUSTOMER_APP' then 'CUSTOMER_APP'
      when 'STAFF_POS' then 'STAFF_POS'
      when 'MANUAL' then 'STAFF_POS'
      else 'ONLINE'
    end;

    v_intent_result := catchmenu_payment.create_payment_intent(
      p_tenant_id := new.tenant_id,
      p_store_id := new.store_id,
      p_order_id := new.order_id,
      p_session_id := v_order.session_id,
      p_payment_method := coalesce(new.payment_method, 'CARD'),
      p_payment_channel := v_payment_channel,
      p_provider_type := 'TOSS_PAYMENTS',
      p_requested_amount := new.amount,
      p_idempotency_key := 'TOSS-INTENT:' || new.idempotency_key,
      p_correlation_id := 'TOSS-REQUEST:' || new.idempotency_key
    );

    if not coalesce((v_intent_result->>'success')::boolean, false) then
      if v_intent_result->>'error_key' = 'active_intent_exists' then
        v_intent_id :=
          (v_intent_result->>'existing_intent_id')::uuid;

        select pi.id
        into v_intent_id
        from catchmenu_payment.payment_intents pi
        where pi.id = v_intent_id
          and pi.tenant_id = new.tenant_id
          and pi.store_id = new.store_id
          and pi.order_id = new.order_id
          and pi.session_id is not distinct from v_order.session_id
          and pi.requested_amount = new.amount
          and pi.provider_type = 'TOSS_PAYMENTS'
          and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
        for update;
      else
        raise exception using
          errcode = 'P0001',
          message = 'TOSS_PAYMENT_INTENT_CREATE_FAILED',
          detail = coalesce(v_intent_result::text, '{}');
      end if;
    else
      v_intent_id := (v_intent_result->>'intent_id')::uuid;
    end if;
  end if;

  if v_intent_id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_BINDING_REQUIRED';
  end if;

  new.payment_intent_id := v_intent_id;
  return new;
end;
$$;

drop trigger if exists trg_toss_request_bind_payment_intent
  on catchmenu_integrations.toss_payment_requests;
create trigger trg_toss_request_bind_payment_intent
  before insert on catchmenu_integrations.toss_payment_requests
  for each row execute function
    catchmenu_integrations.bind_toss_payment_intent();

alter function catchmenu_integrations.initiate_toss_payment(
  uuid, uuid, uuid, text, text, text, text
) rename to initiate_toss_payment_legacy_604260;

alter function catchmenu_integrations.confirm_toss_payment(
  uuid, uuid, text, text, int, jsonb, text, text
) rename to confirm_toss_payment_legacy_604260;

create or replace function
  catchmenu_integrations.initiate_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_payment_method text default 'CARD',
  p_customer_id_hash text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_result jsonb;
  v_request_id uuid;
  v_intent_id uuid;
begin
  v_result :=
    catchmenu_integrations.initiate_toss_payment_legacy_604260(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_payment_method := p_payment_method,
      p_customer_id_hash := p_customer_id_hash,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  if not coalesce((v_result->>'success')::boolean, false) then
    return v_result;
  end if;

  v_request_id := (v_result->'data'->>'request_id')::uuid;

  select tpr.payment_intent_id
  into v_intent_id
  from catchmenu_integrations.toss_payment_requests tpr
  where tpr.id = v_request_id
    and tpr.tenant_id = p_tenant_id
    and tpr.store_id = p_store_id;

  if v_intent_id is null then
    raise exception using
      errcode = '23503',
      message = 'TOSS_PAYMENT_INTENT_BINDING_REQUIRED';
  end if;

  return jsonb_set(
    v_result,
    '{data,payment_intent_id}',
    to_jsonb(v_intent_id),
    true
  );
end;
$$;

create or replace function
  catchmenu_integrations.confirm_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_order_id_toss text,
  p_amount int,
  p_toss_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_result jsonb;
begin
  select tpr.id, tpr.order_id, tpr.amount,
         tpr.payment_intent_id
  into v_request
  from catchmenu_integrations.toss_payment_requests tpr
  where tpr.order_id_toss = p_order_id_toss
    and tpr.tenant_id = p_tenant_id
    and tpr.store_id = p_store_id
  for update;

  if v_request.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_not_found'
    );
  end if;

  if v_request.payment_intent_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_required',
      'request_id', v_request.id
    );
  end if;

  if not exists (
    select 1
    from catchmenu_payment.payment_intents pi
    where pi.id = v_request.payment_intent_id
      and pi.tenant_id = p_tenant_id
      and pi.store_id = p_store_id
      and pi.order_id = v_request.order_id
      and pi.requested_amount = v_request.amount
      and pi.provider_type = 'TOSS_PAYMENTS'
      and pi.intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED')
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_invalid',
      'request_id', v_request.id
    );
  end if;

  v_result :=
    catchmenu_integrations.confirm_toss_payment_legacy_604260(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_payment_key := p_payment_key,
      p_order_id_toss := p_order_id_toss,
      p_amount := p_amount,
      p_toss_response := p_toss_response,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return jsonb_set(
    v_result,
    '{data,payment_intent_id}',
    to_jsonb(v_request.payment_intent_id),
    true
  );
end;
$$;

revoke all on function
  catchmenu_integrations.initiate_toss_payment_legacy_604260(
    uuid, uuid, uuid, text, text, text, text
  ) from public, authenticated;
revoke all on function
  catchmenu_integrations.confirm_toss_payment_legacy_604260(
    uuid, uuid, text, text, int, jsonb, text, text
  ) from public, authenticated;

revoke all on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) from public;
grant execute on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) to authenticated;

revoke all on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) from public;
grant execute on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) to authenticated;

comment on column
  catchmenu_integrations.toss_payment_requests.payment_intent_id is
  'Strong nullable FK binding prepared by Scope D 00A. New Toss requests must populate it; historical rows remain compatible.';

comment on function
  catchmenu_integrations.initiate_toss_payment(
    uuid, uuid, uuid, text, text, text, text
  ) is
  '604260 wrapper. Initiates Toss payment through the preserved legacy implementation and exposes the strongly bound payment_intent_id.';

comment on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) is
  '604260 wrapper. Validates and exposes the bound payment_intent_id before using the preserved Toss confirmation path. It does not patch confirm_payment.';
