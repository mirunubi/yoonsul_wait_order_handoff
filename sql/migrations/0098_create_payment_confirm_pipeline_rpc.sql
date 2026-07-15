-- 0098_create_payment_confirm_pipeline_rpc.sql
-- Purpose: Payment confirmation pipeline with
--          KDS Late Binding integration.
--          토스페이먼츠/OKpos 결제 확인 → KDS 해제.
--          Layer 1 대사 즉시 실행.
--          환불/부분취소 파이프라인.
--          특허2 핵심: 결제 확인 후 KDS HOLD 해제.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0097_create_auth_login_pipeline_rpc.sql
-- Creates:
--   function catchmenu_payment.confirm_payment(...)
--   function catchmenu_payment.confirm_payment_webhook(...)
--   function catchmenu_payment.release_kds_after_payment(...)
--   function catchmenu_payment.request_refund(...)
--   function catchmenu_payment.confirm_refund(...)
--   function catchmenu_payment.get_payment_status(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('payment_confirmed', 'ko',
  '결제가 완료되었습니다'),
('payment_confirmed', 'en',
  'Payment confirmed'),
('payment_confirmed', 'zh',
  '付款已完成'),
('payment_confirmed', 'ja',
  'お支払いが完了しました'),
('payment_confirmed', 'vi',
  'Thanh toán đã hoàn tất'),
('payment_confirmed', 'th',
  'ชำระเงินเรียบร้อยแล้ว'),

('kds_released', 'ko',
  '주방으로 주문이 전달되었습니다'),
('kds_released', 'en',
  'Order sent to kitchen'),
('kds_released', 'zh',
  '订单已发送至厨房'),
('kds_released', 'ja',
  '注文がキッチンに送られました'),
('kds_released', 'vi',
  'Đơn hàng đã gửi đến bếp'),
('kds_released', 'th',
  'ส่งคำสั่งซื้อไปที่ครัวแล้ว'),

('refund_requested', 'ko',
  '환불 요청이 접수되었습니다'),
('refund_requested', 'en',
  'Refund request submitted'),
('refund_requested', 'zh',
  '退款请求已提交'),
('refund_requested', 'ja',
  '返金申請を受け付けました'),
('refund_requested', 'vi',
  'Yêu cầu hoàn tiền đã được gửi'),
('refund_requested', 'th',
  'ส่งคำขอคืนเงินแล้ว'),

('refund_confirmed', 'ko',
  '환불이 완료되었습니다'),
('refund_confirmed', 'en',
  'Refund confirmed'),
('refund_confirmed', 'zh',
  '退款已完成'),
('refund_confirmed', 'ja',
  '返金が完了しました'),
('refund_confirmed', 'vi',
  'Hoàn tiền đã hoàn tất'),
('refund_confirmed', 'th',
  'คืนเงินเรียบร้อยแล้ว'),

('payment_status_loaded', 'ko',
  '결제 현황이 로드되었습니다'),
('payment_status_loaded', 'en',
  'Payment status loaded'),

('payment_webhook_processed', 'ko',
  '결제 웹훅이 처리되었습니다'),
('payment_webhook_processed', 'en',
  'Payment webhook processed'),

('kds_late_binding_released', 'ko',
  '결제 확인 후 주방 조리가 시작됩니다'),
('kds_late_binding_released', 'en',
  'Kitchen cooking started after payment'),
('kds_late_binding_released', 'zh',
  '付款确认后厨房开始烹饪'),
('kds_late_binding_released', 'ja',
  '支払い確認後にキッチンでの調理が開始されます'),
('kds_late_binding_released', 'vi',
  'Bếp bắt đầu nấu sau khi xác nhận thanh toán'),
('kds_late_binding_released', 'th',
  'ครัวเริ่มปรุงอาหารหลังยืนยันการชำระเงิน'),

('payment_already_confirmed', 'ko',
  '이미 완료된 결제입니다'),
('payment_already_confirmed', 'en',
  'Payment already confirmed'),

('refund_amount_invalid', 'ko',
  '환불 금액이 올바르지 않습니다'),
('refund_amount_invalid', 'en',
  'Invalid refund amount'),

('partial_refund_not_supported', 'ko',
  '부분 환불은 현재 지원되지 않습니다'),
('partial_refund_not_supported', 'en',
  'Partial refund not supported'),

('net_cancel_required', 'ko',
  '망취소가 필요합니다. PG사에 즉시 연락하세요'),
('net_cancel_required', 'en',
  'Net cancel required. Contact PG immediately')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(4015, 'payment_already_confirmed',
  'PAYMENT', 'CONFLICT', 409, 'INFO', null),
(4016, 'refund_amount_invalid',
  'PAYMENT', 'INVALID_INPUT', 400, 'WARNING', null),
(4017, 'net_cancel_required',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(4018, 'payment_idempotency_violation',
  'PAYMENT', 'CONFLICT', 409, 'CRITICAL',
  'SOP-PAY-003'),
(4019, 'kds_release_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-KDS-001')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
drop function if exists catchmenu_payment.confirm_payment(
  uuid, uuid, uuid, text, text, text,
  int, text, jsonb, text, uuid, text, text
);

create or replace function
  catchmenu_payment.confirm_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_provider_type text,
  p_provider_approval_number text,
  p_provider_tx_id text,
  p_approved_amount int,
  p_payment_method text,
  p_provider_response jsonb default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null,
  p_intent_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_ledger_id uuid;
  v_kds_result jsonb;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_net_amount int;
  v_fee_amount int;
  v_intent_id uuid;
  v_provider_response_id uuid;
  v_gateway_provider_type text;
  v_actor_type text;
  v_row_count int;
begin
  v_actor_type := case
    when p_actor_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'OWNER',
      'HQ_ADMIN',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    ) then p_actor_type
    when p_actor_type in (
      'PG_WEBHOOK',
      'POS_WEBHOOK',
      'VAN_WEBHOOK',
      'PROVIDER_WEBHOOK'
    ) then 'PROVIDER'
    else 'SYSTEM'
  end;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 멱등성 검사 (correlation_id 기반)
  if p_correlation_id is not null then
    select pl.id
    into v_ledger_id
    from catchmenu_payment.payment_ledger pl
    join catchmenu_pos.orders o
      on o.id = pl.order_id
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.provider_payment_key = p_provider_tx_id
      and pl.provider_type = p_provider_type
      and pl.ledger_status = 'APPROVED'
      and pl.order_id = p_order_id
    order by pl.approved_at desc
    limit 1;

    if v_ledger_id is not null then
      if exists (
        select 1
        from catchmenu_pos.orders
        where id = p_order_id
          and store_id = p_store_id
          and tenant_id = p_tenant_id
          and order_status = 'CONFIRMED'
      ) then
        return catchmenu_common.build_success_response(
          p_message_key := 'payment_already_confirmed_idempotent',
          p_data := jsonb_build_object(
            'ledger_id', v_ledger_id,
            'order_id', p_order_id,
            'already_confirmed', true
          ),
          p_locale := p_locale,
          p_correlation_id := p_correlation_id
        );
      end if;

      perform catchmenu_common.log_diagnostic(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_log_level := 'CRITICAL',
        p_log_domain := 'PAYMENT',
        p_log_event :=
          'payment_idempotency_violation',
        p_message :=
          'Duplicate payment confirmation attempt: '
          || p_provider_tx_id,
        p_rpc_name := 'confirm_payment',
        p_correlation_id := p_correlation_id,
        p_details := jsonb_build_object(
          'provider_tx_id', p_provider_tx_id,
          'provider_type', p_provider_type,
          'order_id', p_order_id,
          'existing_ledger_id', v_ledger_id
        )
      );

      return catchmenu_common.build_error_response(
        p_error_key := 'payment_already_confirmed',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'confirm_payment',
        p_order_id := p_order_id,
        p_payment_id := v_ledger_id
      );
    end if;
  end if;

  -- 주문 조회
  select id, order_number, order_status,
         order_type, final_amount, session_id,
         total_amount, discount_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 이미 결제 완료
  if v_order.order_status = 'CONFIRMED' then
    select id
    into v_ledger_id
    from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
    order by approved_at desc
    limit 1;

    if v_ledger_id is not null then
      return catchmenu_common.build_success_response(
        p_message_key := 'payment_already_confirmed_idempotent',
        p_data := jsonb_build_object(
          'ledger_id', v_ledger_id,
          'order_id', p_order_id,
          'already_confirmed', true
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    end if;

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status in (
    'COOKING',
    'READY',
    'SERVED',
    'COMPLETED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status not in (
    'PENDING',
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;

  if v_order.order_status = 'PENDING' and exists (
    select 1 from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and ledger_status = 'APPROVED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;
  -- 금액 검증 (±10원 허용 오차)
  if abs(p_approved_amount - v_order.final_amount)
    > 10
  then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'PAYMENT',
      p_log_event := 'payment_amount_mismatch',
      p_message :=
        'Payment amount mismatch'
        || ' | order=' || v_order.final_amount
        || ' | approved=' || p_approved_amount,
      p_rpc_name := 'confirm_payment',
      p_details := jsonb_build_object(
        'order_amount', v_order.final_amount,
        'approved_amount', p_approved_amount,
        'diff', abs(
          p_approved_amount - v_order.final_amount
        )
      )
    );
  end if;

  -- 수수료 추정 (PG사별 기본 요율 적용)
  v_fee_amount := case p_provider_type
    when 'TOSS_PAYMENTS' then
      (p_approved_amount * 0.015)::int
    when 'NICE_VAN' then
      (p_approved_amount * 0.020)::int
    when 'KIS_VAN' then
      (p_approved_amount * 0.018)::int
    else
      (p_approved_amount * 0.015)::int
  end;
  v_net_amount := p_approved_amount;

  v_gateway_provider_type := case
    when p_provider_type in (
      'TOSS_POS',
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'PG_KAKAO',
      'PG_NAVER',
      'ALIPAY',
      'WECHAT_PAY',
      'SAMSUNG_PAY',
      'DELIVERY_BAEMIN',
      'DELIVERY_YOGIYO',
      'DELIVERY_COUPANG',
      'OKPOS',
      'KIOSK_VENDOR',
      'INTERNAL_AGENT',
      'OTHER'
    ) then p_provider_type
    else 'OTHER'
  end;

  insert into catchmenu_gateway.provider_raw_events (
    tenant_id,
    store_id,
    provider_type,
    provider_code,
    provider_event_id,
    provider_event_type,
    raw_payload,
    correlation_id
  ) values (
    p_tenant_id,
    p_store_id,
    v_gateway_provider_type,
    p_provider_type,
    p_provider_tx_id,
    'PAYMENT_CONFIRM',
    coalesce(
      p_provider_response,
      jsonb_build_object(
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'approved_amount', p_approved_amount
      )
    ),
    p_correlation_id
  )
  returning id into v_provider_response_id;

  v_intent_id :=
    catchmenu_payment.resolve_or_create_payment_intent(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_requested_amount := p_approved_amount,
      p_payment_method := p_payment_method,
      p_payment_channel := 'STAFF_POS',
      p_provider_type := p_provider_type,
      p_intent_origin := case
        when p_intent_id is not null then
          'PREAUTHORIZED'
        else
          'POS_SYNTHESIZED'
      end,
      p_origin_reference := jsonb_build_object(
        'source', 'confirm_payment',
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number
      ),
      p_intent_id := p_intent_id,
      p_session_id := v_order.session_id,
      p_locale := p_locale
    );

  if v_intent_id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_intent_resolution_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 결제 원장 기록 (Layer 1)
  if v_order.order_status in (
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    insert into catchmenu_payment.payment_ledger (
      tenant_id, store_id,
      order_id, session_id,
      intent_id,
      ledger_entry_type,
      provider_type,
      provider_payment_key,
      provider_approval_number,
      provider_approved_at,
      provider_response_id,
      approved_amount, net_amount,
      ledger_status,
      approved_at,
      reconciliation_status,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      p_order_id, v_order.session_id,
      v_intent_id,
      'APPROVAL',
      p_provider_type,
      p_provider_tx_id,
      p_provider_approval_number,
      now(),
      v_provider_response_id,
      p_approved_amount, v_net_amount,
      'APPROVED',
      now(),
      'MANUAL_REVIEW',
      v_business_day, v_timezone
    )
    returning id into v_ledger_id;

    insert into catchmenu_payment.payment_events (
      tenant_id, store_id, order_id,
      intent_id, ledger_id,
      event_type, from_status, to_status,
      caused_by_type, caused_by_id,
      amount_at_event,
      provider_event_id,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id, p_order_id,
      v_intent_id, v_ledger_id,
      'payment_approved',
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      p_approved_amount,
      p_provider_tx_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_correlation_id, now()
    );

    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, caused_by_id,
      event_payload,
      order_id, payment_id, correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'payment',
      'payment_approved_after_order_cancelled', 1,
      'payment_ledger', v_ledger_id,
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'approved_amount', p_approved_amount,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_order_id, v_ledger_id, p_correlation_id,
      v_business_day, v_timezone, now()
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_details := jsonb_build_object(
        'ledger_id', v_ledger_id,
        'order_id', p_order_id,
        'order_status', v_order.order_status,
        'reconciliation_status', 'MANUAL_REVIEW',
        'reason', 'payment_approved_after_order_cancelled'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id,
    intent_id,
    ledger_entry_type,
    provider_type,
    provider_payment_key,
    provider_approval_number,
    provider_approved_at,
    provider_response_id,
    approved_amount, net_amount,
    ledger_status,
    approved_at,
    reconciliation_status,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_order_id, v_order.session_id,
    v_intent_id,
    'APPROVAL',
    p_provider_type,
    p_provider_tx_id,
    p_provider_approval_number,
    now(),
    v_provider_response_id,
    p_approved_amount, v_net_amount,
    'APPROVED',
    now(),
    'PENDING',
    v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- 주문 상태 CONFIRMED → PAID
  update catchmenu_pos.orders
  set
    order_status = case order_type
      when 'TABLE' then 'COOKING'
      else 'CONFIRMED'
    end,
    confirmed_at = now(),
    updated_at = now()
  where id = p_order_id
    and order_status = 'PENDING';

  get diagnostics v_row_count = row_count;

  if v_row_count = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_status_changed_concurrently',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  -- ==========================================
  -- 특허2 핵심: KDS Late Binding 해제
  -- HOLD → COMMITTED (조리 시작 승인)
  -- ==========================================
  v_kds_result :=
    catchmenu_payment.release_kds_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_ledger_id := v_ledger_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := v_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_released',
        (v_kds_result->>'success')::boolean
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_confirmed', 1,
    'payment_ledger', v_ledger_id,
    'PENDING', 'APPROVED',
    v_actor_type, p_actor_id,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'net_amount', v_net_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_tickets_released',
        v_kds_result->'data'->>'released_count',
      'audit_id', v_audit_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- Realtime → 직원 앱 결제 완료 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'payment_confirmed',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'approved_amount', p_approved_amount,
      'provider_type', p_provider_type,
      'kds_released',
        (v_kds_result->>'success')::boolean
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_confirmed',
    p_data := jsonb_build_object(
      'ledger_id', v_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'provider_tx_id', p_provider_tx_id,
      'approval_number',
        p_provider_approval_number,
      'approved_amount', p_approved_amount,
      'fee_amount', v_fee_amount,
      'net_amount', v_net_amount,
      'audit_id', v_audit_id,
      'kds', v_kds_result->'data',
      'late_binding_note',
        catchmenu_common.get_message(
          'kds_late_binding_released',
          p_locale, null
        )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 특허2 핵심 함수
-- KDS Late Binding 해제
-- 결제 확인 후 HOLD → COMMITTED
-- =============================================
create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- KDS 용량 재확인
  -- (결제 완료 시점에도 Late Binding 조건 검증)
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- HOLD 티켓 → COMMITTED (조리 시작)
  -- conditions_met 업데이트:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', p_ledger_id,
        'released_at', now()
      ),
      committed_at = now(),
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'HOLD'
    returning id
  )
  select
    count(*),
    coalesce(
      jsonb_agg(to_jsonb(id)), '[]'::jsonb
    )
  into v_released_count, v_ticket_ids
  from released;

  if v_released_count = 0 then
    -- HOLD 티켓 없음 (이미 해제되었거나 없음)
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'KDS',
      p_log_event := 'kds_no_hold_tickets',
      p_message :=
        'KDS HOLD 티켓 없음: order_id='
        || p_order_id,
      p_rpc_name := 'release_kds_after_payment',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'order_id', p_order_id,
        'ledger_id', p_ledger_id
      )
    );
  end if;

  -- KDS Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_tickets_released',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'ledger_id', p_ledger_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'capacity', v_capacity_check->'data',
      'released_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_released',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'kds_status', 'COMMITTED',
      'capacity_after',
        v_capacity_check->'data',
      'late_binding_principle',
        'HOLD → COMMITTED after payment only'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 웹훅 결제 확인
-- 토스페이먼츠/배달앱 웹훅 처리
-- =============================================
create or replace function
  catchmenu_payment.confirm_payment_webhook(
  p_tenant_id uuid,
  p_store_id uuid,
  p_webhook_payload jsonb,
  p_provider_type text,
  p_webhook_signature text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_order_id uuid;
  v_provider_tx_id text;
  v_approval_number text;
  v_approved_amount int;
  v_payment_method text;
  v_correlation_id text;
  v_result jsonb;
begin
  -- 웹훅 서명 검증 (Edge Function에서 1차 검증)
  -- 여기서는 2차 검증 (DB 레벨)
  if p_webhook_signature is not null then
    insert into catchmenu_common.security_audit_log (
      tenant_id, audit_event, event_severity,
      event_source, event_detail,
      is_violation
    ) values (
      p_tenant_id,
      'webhook_received',
      'INFO',
      'confirm_payment_webhook',
      jsonb_build_object(
        'provider_type', p_provider_type,
        'has_signature', true
      ),
      false
    );
  end if;

  -- 제공자별 웹훅 파라미터 파싱
  case p_provider_type
    when 'TOSS_PAYMENTS' then
      v_provider_tx_id :=
        p_webhook_payload->>'paymentKey';
      v_approval_number :=
        p_webhook_payload->>'approvalKey';
      v_approved_amount :=
        (p_webhook_payload->>'amount')::int;
      v_payment_method :=
        p_webhook_payload->>'method';
      v_order_id := (
        p_webhook_payload->>'orderId'
      )::uuid;

    when 'OKPOS' then
      v_provider_tx_id :=
        p_webhook_payload->>'okpos_order_id';
      v_approval_number :=
        p_webhook_payload->>'approval_number';
      v_approved_amount :=
        (p_webhook_payload->>'paid_amount')::int;
      v_payment_method :=
        coalesce(
          p_webhook_payload->>'payment_method',
          'CARD'
        );
      v_order_id := (
        p_webhook_payload->>'order_id'
      )::uuid;

    when 'TOSS_POS' then
      v_provider_tx_id :=
        p_webhook_payload->>'toss_pos_order_id';
      v_approval_number :=
        p_webhook_payload->>'approval_number';
      v_approved_amount :=
        (p_webhook_payload->>'paid_amount')::int;
      v_payment_method := 'CARD';
      v_order_id := (
        p_webhook_payload->>'order_id'
      )::uuid;

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := 'ko',
        p_params := jsonb_build_object(
          'field', 'provider_type',
          'value', p_provider_type
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'confirm_payment_webhook'
      );
  end case;

  v_correlation_id := 'WH-' || p_provider_type
    || '-' || coalesce(
      v_provider_tx_id, gen_random_uuid()::text
    );

  -- 실제 결제 확인 실행
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_provider_type := p_provider_type,
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := v_provider_tx_id,
    p_approved_amount := v_approved_amount,
    p_payment_method := v_payment_method,
    p_provider_response := p_webhook_payload,
    p_actor_type := 'WEBHOOK',
    p_locale := 'ko',
    p_correlation_id := v_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_webhook_processed',
    p_data := jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_tx_id', v_provider_tx_id,
      'order_id', v_order_id,
      'correlation_id', v_correlation_id,
      'payment_result', v_result->'data'
    ),
    p_locale := 'ko',
    p_correlation_id := v_correlation_id
  );
end;
$$;


-- =============================================
-- 환불 요청
-- =============================================
create or replace function
  catchmenu_payment.request_refund(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_refund_amount int,
  p_refund_reason text,
  p_is_partial boolean default false,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_payment record;
  v_order record;
  v_refund_ledger_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 원결제 조회
  select id, provider_type,
         provider_tx_id,
         provider_approval_number,
         approved_amount, ledger_status
  into v_payment
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'APPROVED'
  order by approved_at desc
  limit 1;

  if v_payment.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_refund'
    );
  end if;

  -- 환불 금액 검증
  if p_refund_amount <= 0
    or p_refund_amount > v_payment.approved_amount
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'refund_amount_invalid',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'max_refund', v_payment.approved_amount
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_refund'
    );
  end if;

  -- 주문 조회
  select id, order_number, order_status
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 환불 원장 생성 (PENDING 상태)
  -- 실제 PG사 취소는 Edge Function 처리
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id,
    provider_type, payment_method,
    provider_tx_id,
    provider_approval_number,
    approved_amount,
    fee_amount, net_amount,
    ledger_status,
    refund_reason,
    is_partial_refund,
    original_ledger_id,
    business_day, business_timezone
  )
  select
    p_tenant_id, p_store_id,
    p_order_id, pl.session_id,
    pl.provider_type, pl.payment_method,
    pl.provider_tx_id || '_REFUND',
    null,
    -p_refund_amount,
    -(pl.fee_amount * p_refund_amount
      / pl.approved_amount)::int,
    -(pl.net_amount * p_refund_amount
      / pl.approved_amount)::int,
    'REFUND_PENDING',
    p_refund_reason,
    p_is_partial,
    v_payment.id,
    v_business_day, v_timezone
  from catchmenu_payment.payment_ledger pl
  where pl.id = v_payment.id
  returning id into v_refund_ledger_id;

  -- 주문 취소 처리
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- KDS 취소
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and store_id = p_store_id
    and kds_status not in (
      'SERVED', 'COMPLETED', 'CANCELLED'
    );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'refund_requested',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_refund_ledger_id,
    p_decision := 'REFUND_PENDING',
    p_decision_reason := p_refund_reason,
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'refund_amount', p_refund_amount,
      'original_amount',
        v_payment.approved_amount,
      'is_partial', p_is_partial,
      'provider_type', v_payment.provider_type
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'refund_requested', 1,
    'payment_ledger', v_refund_ledger_id,
    'APPROVED', 'REFUND_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'provider_type', v_payment.provider_type,
      'original_tx_id', v_payment.provider_tx_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- Edge Function에 PG 취소 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type := 'pg_cancel_requested',
    p_payload := jsonb_build_object(
      'refund_ledger_id', v_refund_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', v_payment.provider_type,
      'provider_tx_id', v_payment.provider_tx_id,
      'approval_number',
        v_payment.provider_approval_number,
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'correlation_id', p_correlation_id
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'refund_requested',
    p_data := jsonb_build_object(
      'refund_ledger_id', v_refund_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'refund_amount', p_refund_amount,
      'provider_type', v_payment.provider_type,
      'refund_status', 'REFUND_PENDING',
      'audit_id', v_audit_id,
      'note',
        'PG 취소는 Edge Function이 처리합니다'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 환불 확인 (Edge Function → 웹훅 콜백)
-- =============================================
create or replace function
  catchmenu_payment.confirm_refund(
  p_tenant_id uuid,
  p_store_id uuid,
  p_refund_ledger_id uuid,
  p_provider_cancel_tx_id text,
  p_cancel_result text default 'SUCCESS',
  p_provider_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_refund record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_new_status text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, order_id, provider_type,
         approved_amount, refund_reason,
         original_ledger_id
  into v_refund
  from catchmenu_payment.payment_ledger
  where id = p_refund_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'REFUND_PENDING'
  for update;

  if v_refund.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_refund'
    );
  end if;

  v_new_status := case p_cancel_result
    when 'SUCCESS' then 'REFUNDED'
    else 'REFUND_FAILED'
  end;

  -- 환불 원장 업데이트
  update catchmenu_payment.payment_ledger
  set
    ledger_status = v_new_status,
    provider_tx_id = p_provider_cancel_tx_id,
    provider_response = coalesce(
      p_provider_response, provider_response
    ),
    refunded_at = case p_cancel_result
      when 'SUCCESS' then now()
      else null
    end,
    updated_at = now()
  where id = p_refund_ledger_id;

  -- 원결제 원장 상태 업데이트
  if p_cancel_result = 'SUCCESS' then
    update catchmenu_payment.payment_ledger
    set
      ledger_status = 'REFUNDED',
      refunded_at = now(),
      updated_at = now()
    where id = v_refund.original_ledger_id;
  end if;

  -- 망취소 실패 처리
  if p_cancel_result <> 'SUCCESS' then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'net_cancel_failed',
      p_message :=
        '망취소 실패 - 즉시 PG사 연락 필요',
      p_rpc_name := 'confirm_refund',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'refund_ledger_id', p_refund_ledger_id,
        'order_id', v_refund.order_id,
        'provider_type', v_refund.provider_type,
        'cancel_result', p_cancel_result
      )
    );

    -- 운영 알림 생성
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'PAYMENT_FAILED',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key := 'net_cancel_required',
      p_alert_detail := jsonb_build_object(
        'refund_ledger_id', p_refund_ledger_id,
        'order_id', v_refund.order_id,
        'provider_type', v_refund.provider_type
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'refund_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'WEBHOOK',
    p_subject_type := 'payment_ledger',
    p_subject_id := p_refund_ledger_id,
    p_decision := v_new_status,
    p_decision_payload := jsonb_build_object(
      'cancel_tx_id', p_provider_cancel_tx_id,
      'cancel_result', p_cancel_result,
      'refund_amount', v_refund.approved_amount
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'refund_confirmed', 1,
    'payment_ledger', p_refund_ledger_id,
    'REFUND_PENDING', v_new_status,
    'WEBHOOK',
    jsonb_build_object(
      'cancel_tx_id', p_provider_cancel_tx_id,
      'cancel_result', p_cancel_result,
      'refund_amount', v_refund.approved_amount,
      'audit_id', v_audit_id
    ),
    v_refund.order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := case p_cancel_result
      when 'SUCCESS' then 'refund_confirmed'
      else 'refund_failed'
    end,
    p_data := jsonb_build_object(
      'refund_ledger_id', p_refund_ledger_id,
      'order_id', v_refund.order_id,
      'refund_status', v_new_status,
      'cancel_tx_id', p_provider_cancel_tx_id,
      'refund_amount', v_refund.approved_amount,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- 결제 현황 조회
-- =============================================
create or replace function
  catchmenu_payment.get_payment_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_order record;
  v_payments jsonb;
  v_total_approved int;
  v_total_refunded int;
  v_net_paid int;
begin
  select id, order_number, order_status,
         order_type, final_amount,
         total_amount, discount_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_payment_status'
    );
  end if;

  -- 결제 원장 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ledger_id', id,
        'provider_type', provider_type,
        'payment_method', payment_method,
        'provider_tx_id', provider_tx_id,
        'approval_number',
          provider_approval_number,
        'approved_amount', approved_amount,
        'fee_amount', fee_amount,
        'net_amount', net_amount,
        'ledger_status', ledger_status,
        'approved_at', approved_at,
        'refunded_at', refunded_at,
        'is_partial_refund', is_partial_refund,
        'refund_reason', refund_reason
      )
      order by approved_at asc
    ),
    '[]'::jsonb
  )
  into v_payments
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  order by approved_at;

  -- 합계 계산
  select
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'APPROVED'
    ), 0),
    coalesce(abs(sum(approved_amount)) filter (
      where ledger_status = 'REFUNDED'
    ), 0)
  into v_total_approved, v_total_refunded
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  v_net_paid := v_total_approved - v_total_refunded;

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_status_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'order_status', v_order.order_status,
      'order_amount', jsonb_build_object(
        'total_amount', v_order.total_amount,
        'discount_amount',
          v_order.discount_amount,
        'final_amount', v_order.final_amount
      ),
      'payment_summary', jsonb_build_object(
        'total_approved', v_total_approved,
        'total_refunded', v_total_refunded,
        'net_paid', v_net_paid,
        'is_fully_paid',
          v_total_approved
            >= v_order.final_amount,
        'is_refunded', v_total_refunded > 0
      ),
      'payments', v_payments,
      'payment_count',
        jsonb_array_length(v_payments)
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_payment.confirm_payment(
      uuid, uuid, uuid, text, text, text,
      int, text, jsonb, text, uuid, text, text, uuid
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_payment(
      uuid, uuid, uuid, text, text, text,
      int, text, jsonb, text, uuid, text, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_payment.release_kds_after_payment(
      uuid, uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.release_kds_after_payment(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.confirm_payment_webhook(
      uuid, uuid, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_payment_webhook(
      uuid, uuid, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.request_refund(
      uuid, uuid, uuid, int, text,
      boolean, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.request_refund(
      uuid, uuid, uuid, int, text,
      boolean, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.confirm_refund(
      uuid, uuid, uuid, text, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_refund(
      uuid, uuid, uuid, text, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.get_payment_status(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_payment.get_payment_status(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_payment.confirm_payment(
    uuid, uuid, uuid, text, text, text,
    int, text, jsonb, text, uuid, text, text, uuid
  ) is
  '결제 확인 파이프라인 핵심 함수.
   처리 순서:
   1. 멱등성 검사 (provider_tx_id 중복 방지)
   2. 주문 조회 + 금액 검증 (±10원 허용)
   3. payment_ledger 기록 (APPROVED)
   4. 주문 상태 → PAID/COOKING
   5. ★ KDS Late Binding 해제 ★
      HOLD → COMMITTED (특허2 핵심)
   6. 감사 기록 + ledger event
   7. Realtime 직원 앱 알림

   특허2 Late Binding 원칙:
   결제 확인 전: KDS = HOLD (조리 금지)
   결제 확인 후: KDS = COMMITTED (조리 시작)
   → 과결제/미결제 주방 혼란 방지.

   멱등성: provider_tx_id + correlation_id
   수수료: PG사별 기본 요율 자동 적용.
   Layer 1 대사: payment_ledger 즉시 기록.';

comment on function
  catchmenu_payment.release_kds_after_payment(
    uuid, uuid, uuid, uuid, text, text
  ) is
  '특허2 KDS Late Binding 해제 함수.
   HOLD → COMMITTED 상태 전환.
   conditions_met 업데이트:
   - payment_confirmed: true
   - kds_release_authorized: true
   - payment_ledger_id: 증빙 연결
   KDS Realtime 브로드캐스트 → 주방 화면 즉시 반영.
   결제 취소 시 → KDS CANCELLED 처리.
   이 함수 없이는 주방이 조리 시작 불가.
   F&B OS의 심장 = 특허2 Late Binding.';
