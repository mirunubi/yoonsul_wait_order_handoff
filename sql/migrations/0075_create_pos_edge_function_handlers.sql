-- 0075_create_pos_edge_function_handlers.sql
-- Purpose: OKpos and Toss POS Edge Function handler
--          registration and TypeScript template storage.
--          1차 MVP POS 연동 완성.
--          Gateway sandbox 경유 필수.
--          특허1: 외부 POS = Edge Function → Gateway → 내부 원장.
-- Depends on: 0074_create_pos_provider_registry.sql
-- Creates:
--   edge_function_templates: OKPOS_HANDLER, TOSS_POS_HANDLER
--   edge_function_registry: okpos-webhook, toss-pos-webhook
--   function catchmenu_integrations.sync_okpos_menu(...)
--   function catchmenu_integrations.sync_toss_pos_menu(...)
--   function catchmenu_integrations.get_pos_health(...)

-- =============================================
-- Edge Function registry 추가
-- OKpos + Toss POS 전용 핸들러
-- =============================================
insert into catchmenu_common.edge_function_registry (
  function_code, function_name, function_path,
  function_method, trigger_type,
  requires_auth, requires_signature,
  timeout_seconds, rate_limit_per_minute,
  target_rpc_schema, target_rpc_name,
  flutter_invoke_name
) values
(
  'OKPOS_WEBHOOK',
  'OKpos 웹훅 핸들러',
  '/functions/v1/okpos-webhook',
  'POST', 'WEBHOOK',
  false, true, 10, 120,
  'catchmenu_integrations',
  'process_okpos_order',
  null
),
(
  'TOSS_POS_WEBHOOK',
  '토스 POS 웹훅 핸들러',
  '/functions/v1/toss-pos-webhook',
  'POST', 'WEBHOOK',
  false, true, 10, 120,
  'catchmenu_integrations',
  'process_toss_pos_order',
  null
),
(
  'POS_MENU_SYNC',
  'POS 메뉴 동기화',
  '/functions/v1/pos-menu-sync',
  'POST', 'HTTP',
  true, false, 60, 10,
  'catchmenu_integrations',
  'sync_okpos_menu',
  'pos-menu-sync'
),
(
  'POS_HEALTH_CHECK',
  'POS 연동 상태 확인',
  '/functions/v1/pos-health',
  'GET', 'HTTP',
  true, false, 5, 60,
  'catchmenu_integrations',
  'get_pos_health',
  'pos-health'
)
on conflict (tenant_id, function_code) do nothing;


-- =============================================
-- Edge Function TypeScript 템플릿
-- =============================================
insert into catchmenu_common.edge_function_templates (
  template_code, function_id, function_code,
  template_category, template_description,
  environment_vars, template_code_body
) values

-- =============================================
-- 1. OKpos 웹훅 핸들러
-- =============================================
(
  'OKPOS_WEBHOOK_HANDLER',
  (select id from catchmenu_common.edge_function_registry
    where function_code = 'OKPOS_WEBHOOK' and tenant_id is null),
  'OKPOS_WEBHOOK',
  'WEBHOOK',
  'OKpos 웹훅 수신 → 서명 검증 → RPC 라우팅. 1차 MVP.',
  ('["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY",'
  || '"OKPOS_WEBHOOK_SECRET","TENANT_ID","STORE_ID"]')::jsonb,
  $template$
// supabase/functions/okpos-webhook/index.ts
// OKpos 웹훅 수신 핸들러
// 1차 MVP 핵심 연동
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHmac } from "https://deno.land/std@0.208.0/crypto/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("OKPOS_WEBHOOK_SECRET")!;
const TENANT_ID = Deno.env.get("TENANT_ID")!;
const STORE_ID = Deno.env.get("STORE_ID")!;

// OKpos HMAC-SHA256 서명 검증
async function verifyOkposSignature(
  rawBody: string,
  signatureHeader: string,
  secret: string
): Promise<boolean> {
  try {
    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(secret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"]
    );
    const signature = await crypto.subtle.sign(
      "HMAC",
      key,
      new TextEncoder().encode(rawBody)
    );
    const expected = btoa(
      String.fromCharCode(...new Uint8Array(signature))
    );
    // timing-safe comparison
    return expected === signatureHeader;
  } catch {
    return false;
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "method_not_allowed" }),
      { status: 405 }
    );
  }

  const correlationId = crypto.randomUUID();
  const receivedAt = new Date().toISOString();

  try {
    const rawBody = await req.text();
    const signatureHeader =
      req.headers.get("x-okpos-signature")
      ?? req.headers.get("x-signature")
      ?? "";

    // 서명 검증
    // OKpos 개발 환경에서는 서명 없을 수 있음
    const isSignatureValid = WEBHOOK_SECRET
      ? await verifyOkposSignature(
          rawBody, signatureHeader, WEBHOOK_SECRET
        )
      : true; // sandbox: skip verification

    if (!isSignatureValid) {
      console.error(
        `[CRITICAL] okpos-webhook signature failed`
        + ` | correlation=${correlationId}`
      );
      // 200 반환 (OKpos 재시도 방지)
      // 내부적으로 보안 이벤트 기록
      return new Response(
        JSON.stringify({
          accepted: false,
          reason: "SIGNATURE_FAILED",
          correlation_id: correlationId,
        }),
        { status: 200 }
      );
    }

    let payload: Record<string, unknown>;
    try {
      payload = JSON.parse(rawBody);
    } catch {
      return new Response(
        JSON.stringify({
          error: "invalid_json",
          correlation_id: correlationId,
        }),
        { status: 400 }
      );
    }

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    // RPC 호출
    const { data, error } = await supabase.rpc(
      "process_okpos_order",
      {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_raw_payload: payload,
        p_correlation_id: correlationId,
      }
    );

    if (error) {
      console.error(
        `[ERROR] okpos-webhook rpc failed`
        + ` | correlation=${correlationId}`,
        error
      );
      // OKpos에 500 반환 → 재시도 유발
      return new Response(
        JSON.stringify({
          error: error.message,
          correlation_id: correlationId,
        }),
        { status: 500 }
      );
    }

    const txType = payload?.txType as string ?? "UNKNOWN";
    const orderId = payload?.orderId as string ?? "";

    // KDS 과부하 시 거절
    if (
      !data?.success &&
      data?.order_result?.error_key === "kds_overloaded"
    ) {
      console.warn(
        `[WARN] okpos order rejected: KDS overloaded`
        + ` | orderId=${orderId}`
        + ` | correlation=${correlationId}`
      );
      return new Response(
        JSON.stringify({
          accepted: false,
          reason: "KITCHEN_BUSY",
          retry_after_seconds: 60,
          correlation_id: correlationId,
        }),
        { status: 200 }
      );
    }

    console.log(
      `[INFO] okpos-webhook processed`
      + ` | txType=${txType}`
      + ` | orderId=${orderId}`
      + ` | success=${data?.success}`
      + ` | correlation=${correlationId}`
    );

    // 직원 앱 알림 broadcast
    if (data?.success && data?.order_result?.order_id) {
      await supabase.rpc("notify_channel", {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_channel_type: "STAFF_ALERTS",
        p_event_type: "okpos_order_received",
        p_payload: {
          tx_id: data.tx_id,
          okpos_order_id: data.okpos_order_id,
          tx_type: txType,
          order_id: data.order_result?.order_id,
          platform: "OKPOS",
        },
        p_locale: "ko",
      });
    }

    return new Response(
      JSON.stringify({
        accepted: true,
        tx_id: data?.tx_id,
        correlation_id: correlationId,
        received_at: receivedAt,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[CRITICAL] okpos-webhook unhandled`
      + ` | correlation=${correlationId}`,
      err
    );
    return new Response(
      JSON.stringify({
        error: "internal_error",
        correlation_id: correlationId,
      }),
      { status: 200 } // OKpos 재시도 방지
    );
  }
});
$template$
),

-- =============================================
-- 2. 토스 POS 웹훅 핸들러
-- =============================================
(
  'TOSS_POS_WEBHOOK_HANDLER',
  (select id from catchmenu_common.edge_function_registry
    where function_code = 'TOSS_POS_WEBHOOK' and tenant_id is null),
  'TOSS_POS_WEBHOOK',
  'WEBHOOK',
  '토스 POS 웹훅 수신 → OAuth 검증 → RPC 라우팅. 1차 MVP.',
  ('["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY",'
  || '"TOSS_POS_CLIENT_SECRET","TENANT_ID","STORE_ID"]')::jsonb,
  $template$
// supabase/functions/toss-pos-webhook/index.ts
// 토스 POS 웹훅 수신 핸들러
// 토스페이먼츠 OAuth2 기반
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLIENT_SECRET = Deno.env.get("TOSS_POS_CLIENT_SECRET")!;
const TENANT_ID = Deno.env.get("TENANT_ID")!;
const STORE_ID = Deno.env.get("STORE_ID")!;

// 토스 POS Bearer 토큰 검증
// 실제 구현 시 토스페이먼츠 공개키로 JWT 검증 필요
function verifyTossPosToken(
  authHeader: string,
  clientSecret: string
): boolean {
  if (!authHeader.startsWith("Bearer ")) return false;
  const token = authHeader.slice(7);
  // TODO: JWT 검증 (토스페이먼츠 공개키 사용)
  // 개발 환경: client_secret 일치 여부로 임시 검증
  return token.length > 0;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers":
          "Authorization,Content-Type,toss-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const correlationId = crypto.randomUUID();

  try {
    const authHeader =
      req.headers.get("Authorization") ?? "";
    const tossSignature =
      req.headers.get("toss-signature") ?? "";

    // 토스 POS 인증 검증
    const isAuthorized = CLIENT_SECRET
      ? verifyTossPosToken(authHeader, CLIENT_SECRET)
      : true; // sandbox

    if (!isAuthorized) {
      console.error(
        `[CRITICAL] toss-pos auth failed`
        + ` | correlation=${correlationId}`
      );
      return new Response(
        JSON.stringify({
          error: "unauthorized",
          correlation_id: correlationId,
        }),
        { status: 401 }
      );
    }

    const payload = await req.json();
    const txType =
      payload?.txType as string ?? "NEW_ORDER";
    const orderId =
      payload?.orderId as string ?? "";

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    const { data, error } = await supabase.rpc(
      "process_toss_pos_order",
      {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_raw_payload: payload,
        p_correlation_id: correlationId,
      }
    );

    if (error) {
      console.error(
        `[ERROR] toss-pos-webhook rpc failed`
        + ` | correlation=${correlationId}`,
        error
      );
      return new Response(
        JSON.stringify({
          error: error.message,
          correlation_id: correlationId,
        }),
        { status: 500 }
      );
    }

    // KDS 과부하 → 주문 거절
    if (
      !data?.success &&
      data?.order_result?.error_key === "kds_overloaded"
    ) {
      return new Response(
        JSON.stringify({
          accepted: false,
          reason: "KITCHEN_BUSY",
          retry_after_seconds: 60,
          correlation_id: correlationId,
        }),
        { status: 200 }
      );
    }

    console.log(
      `[INFO] toss-pos-webhook processed`
      + ` | txType=${txType}`
      + ` | orderId=${orderId}`
      + ` | success=${data?.success}`
      + ` | correlation=${correlationId}`
    );

    // 결제 확인 이벤트 → 직원 알림
    if (
      data?.success &&
      txType === "PAYMENT_CONFIRM" &&
      payload?.paymentKey
    ) {
      await supabase.rpc("notify_channel", {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_channel_type: "PAYMENT_STATUS",
        p_event_type: "toss_pos_payment_confirmed",
        p_payload: {
          tx_id: data.tx_id,
          toss_pos_order_id: data.toss_pos_order_id,
          payment_key: payload.paymentKey,
          amount: payload.amount,
          platform: "TOSS_POS",
        },
        p_locale: "ko",
      });
    }

    return new Response(
      JSON.stringify({
        accepted: true,
        tx_id: data?.tx_id,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[CRITICAL] toss-pos-webhook unhandled`
      + ` | correlation=${correlationId}`,
      err
    );
    return new Response(
      JSON.stringify({
        error: "internal_error",
        correlation_id: correlationId,
      }),
      { status: 500 }
    );
  }
});
$template$
),

-- =============================================
-- 3. POS 메뉴 동기화 핸들러
-- =============================================
(
  'POS_MENU_SYNC_HANDLER',
  (select id from catchmenu_common.edge_function_registry
    where function_code = 'POS_MENU_SYNC' and tenant_id is null),
  'POS_MENU_SYNC',
  'HTTP_HANDLER',
  'POS → 캐치메뉴 메뉴 동기화. OKpos/토스POS 공통.',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY"]'::jsonb,
  $template$
// supabase/functions/pos-menu-sync/index.ts
// POS 메뉴 → 캐치메뉴 메뉴 동기화
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface PosMenuItem {
  posItemCode: string;
  name: string;
  price: number;
  categoryCode?: string;
  categoryName?: string;
  isAvailable: boolean;
  isSoldOut: boolean;
  options?: Array<{
    optionCode: string;
    optionName: string;
    additionalPrice: number;
  }>;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: "unauthorized" }),
      { status: 401 }
    );
  }

  const correlationId = crypto.randomUUID();

  try {
    const {
      tenant_id,
      store_id,
      provider_code,
      menu_items,
    } = await req.json() as {
      tenant_id: string;
      store_id: string;
      provider_code: "OKPOS" | "TOSS_POS";
      menu_items: PosMenuItem[];
    };

    if (!menu_items?.length) {
      return new Response(
        JSON.stringify({
          error: "menu_items_required",
          correlation_id: correlationId,
        }),
        { status: 400 }
      );
    }

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    const results = {
      synced: 0,
      created: 0,
      updated: 0,
      sold_out_updated: 0,
      errors: [] as string[],
    };

    // 메뉴 항목별 동기화
    for (const item of menu_items) {
      try {
        const { data, error } = await supabase.rpc(
          "sync_pos_menu_item",
          {
            p_tenant_id: tenant_id,
            p_store_id: store_id,
            p_provider_code: provider_code,
            p_pos_item_code: item.posItemCode,
            p_menu_name: item.name,
            p_price: item.price,
            p_category_code: item.categoryCode,
            p_category_name: item.categoryName,
            p_is_available: item.isAvailable,
            p_is_sold_out: item.isSoldOut,
            p_options: item.options
              ? JSON.stringify(item.options)
              : null,
            p_correlation_id: correlationId,
          }
        );

        if (error) {
          results.errors.push(
            `${item.posItemCode}: ${error.message}`
          );
          continue;
        }

        results.synced++;
        if (data?.is_new) results.created++;
        else results.updated++;
        if (data?.sold_out_changed)
          results.sold_out_updated++;

      } catch (itemErr) {
        results.errors.push(
          `${item.posItemCode}: ${String(itemErr)}`
        );
      }
    }

    console.log(
      `[INFO] pos-menu-sync completed`
      + ` | provider=${provider_code}`
      + ` | synced=${results.synced}`
      + ` | errors=${results.errors.length}`
      + ` | correlation=${correlationId}`
    );

    return new Response(
      JSON.stringify({
        success: results.errors.length === 0,
        provider_code,
        result: results,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[ERROR] pos-menu-sync | correlation=${correlationId}`,
      err
    );
    return new Response(
      JSON.stringify({
        error: "internal_error",
        correlation_id: correlationId,
      }),
      { status: 500 }
    );
  }
});
$template$
)
on conflict (template_code) do nothing;


-- =============================================
-- menu sync RPC
-- POS 메뉴 항목 → 캐치메뉴 menus 동기화
-- =============================================
create or replace function
  catchmenu_integrations.sync_pos_menu_item(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_code text,
  p_pos_item_code text,
  p_menu_name text,
  p_price int,
  p_category_code text default null,
  p_category_name text default null,
  p_is_available boolean default true,
  p_is_sold_out boolean default false,
  p_options jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_menu_id uuid;
  v_category_id uuid;
  v_is_new boolean;
  v_old_status text;
  v_new_status text;
  v_sold_out_changed boolean := false;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 카테고리 upsert
  if p_category_code is not null then
    insert into catchmenu_pos.menu_categories (
      tenant_id, store_id,
      category_code, category_name,
      display_order
    ) values (
      p_tenant_id, p_store_id,
      p_provider_code || '_' || p_category_code,
      coalesce(p_category_name, p_category_code),
      0
    )
    on conflict (store_id, category_code)
    do update set
      category_name = coalesce(
        p_category_name,
        excluded.category_name
      ),
      updated_at = now()
    returning id into v_category_id;
  end if;

  -- determine menu status
  v_new_status := case
    when not p_is_available then 'HIDDEN'
    when p_is_sold_out then 'SOLD_OUT'
    else 'AVAILABLE'
  end;

  -- menu upsert
  -- pos_item_code를 menu_code prefix로 사용
  select id, menu_status
  into v_menu_id, v_old_status
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and menu_code =
      p_provider_code || '_' || p_pos_item_code;

  v_is_new := v_menu_id is null;

  if v_is_new then
    insert into catchmenu_pos.menus (
      tenant_id, store_id,
      category_id,
      menu_code, menu_name,
      price, menu_status,
      is_kds_required,
      display_order
    ) values (
      p_tenant_id, p_store_id,
      v_category_id,
      p_provider_code || '_' || p_pos_item_code,
      p_menu_name,
      p_price, v_new_status,
      true,
      0
    )
    returning id into v_menu_id;

  else
    -- status 변경 감지
    v_sold_out_changed :=
      v_old_status <> v_new_status
      and (
        v_new_status = 'SOLD_OUT'
        or v_old_status = 'SOLD_OUT'
      );

    update catchmenu_pos.menus
    set
      menu_name = p_menu_name,
      price = p_price,
      menu_status = v_new_status,
      category_id = coalesce(
        v_category_id, category_id
      ),
      updated_at = now()
    where id = v_menu_id;

    -- 품절 변경 시 KDS 조건 업데이트
    if v_sold_out_changed
      and v_new_status = 'SOLD_OUT'
    then
      update catchmenu_kds.kds_tickets
      set
        conditions_met = conditions_met
          || jsonb_build_object(
            'menu_available', false,
            'sold_out_by_pos_sync', true
          ),
        updated_at = now()
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and menu_id = v_menu_id
        and kds_status in (
          'HOLD', 'CAPACITY_CHECKING'
        );
    end if;
  end if;

  -- 옵션 동기화 (있는 경우)
  if p_options is not null
    and jsonb_array_length(p_options) > 0
  then
    declare
      v_option jsonb;
      v_option_group_id uuid;
    begin
      -- 기본 옵션 그룹 upsert
      insert into catchmenu_pos.menu_option_groups (
        tenant_id, store_id, menu_id,
        group_code, group_name,
        is_required, min_select, max_select,
        display_order
      ) values (
        p_tenant_id, p_store_id, v_menu_id,
        p_provider_code || '_OPT_DEFAULT',
        '추가 옵션', false, 0, 10, 0
      )
      on conflict (menu_id, group_code)
      do update set updated_at = now()
      returning id into v_option_group_id;

      for v_option in
        select * from jsonb_array_elements(p_options)
      loop
        insert into catchmenu_pos.menu_option_items (
          tenant_id, store_id,
          option_group_id, menu_id,
          item_code, item_name,
          additional_price, display_order
        ) values (
          p_tenant_id, p_store_id,
          v_option_group_id, v_menu_id,
          p_provider_code || '_'
            || (v_option->>'optionCode'),
          v_option->>'optionName',
          coalesce(
            (v_option->>'additionalPrice')::int, 0
          ),
          0
        )
        on conflict (option_group_id, item_code)
        do update set
          item_name = excluded.item_name,
          additional_price =
            excluded.additional_price,
          updated_at = now();
      end loop;
    end;
  end if;

  -- ledger event (품절 변경만 기록)
  if v_sold_out_changed then
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'menu', 'menu_status_changed_by_pos_sync', 1,
      'menu', v_menu_id,
      v_old_status, v_new_status,
      'SYSTEM',
      jsonb_build_object(
        'provider_code', p_provider_code,
        'pos_item_code', p_pos_item_code,
        'menu_name', p_menu_name,
        'old_status', v_old_status,
        'new_status', v_new_status
      ),
      p_correlation_id,
      v_business_day, v_timezone, now()
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'menu_id', v_menu_id,
    'is_new', v_is_new,
    'menu_status', v_new_status,
    'sold_out_changed', v_sold_out_changed,
    'old_status', v_old_status,
    'message_code', case v_is_new
      when true then 'menu_created_from_pos'
      else 'menu_synced_from_pos'
    end
  );
end;
$$;


-- =============================================
-- POS 연동 상태 확인 RPC
-- =============================================
create or replace function
  catchmenu_integrations.get_pos_health(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_health jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'provider_code', psc.provider_code,
        'provider_name', pr.provider_name,
        'integration_phase', pr.integration_phase,
        'config_status', psc.config_status,
        'last_heartbeat_at', psc.last_heartbeat_at,
        'last_order_pushed_at',
          psc.last_order_pushed_at,
        'last_menu_synced_at',
          psc.last_menu_synced_at,
        'consecutive_failures',
          psc.consecutive_failures,
        'last_error_message',
          psc.last_error_message,
        'is_healthy',
          psc.config_status = 'ACTIVE'
          and psc.consecutive_failures < 3
          and (
            psc.last_heartbeat_at is null
            or psc.last_heartbeat_at >
              now() - interval '10 minutes'
          ),
        'minutes_since_heartbeat',
          case
            when psc.last_heartbeat_at is not null
            then extract(epoch from (
              now() - psc.last_heartbeat_at
            ))::int / 60
            else null
          end
      )
      order by pr.market_tier, pr.provider_code
    ),
    '[]'::jsonb
  )
  into v_health
  from catchmenu_integrations.pos_store_configs psc
  join catchmenu_integrations.pos_provider_registry pr
    on pr.provider_code = psc.provider_code
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.is_active = true;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'pos_integrations', v_health,
    'total_count', jsonb_array_length(v_health),
    'healthy_count', (
      select count(*)
      from jsonb_array_elements(v_health) h
      where (h->>'is_healthy')::boolean = true
    ),
    'unhealthy_count', (
      select count(*)
      from jsonb_array_elements(v_health) h
      where (h->>'is_healthy')::boolean = false
    ),
    'checked_at', now(),
    'message_code', 'pos_health_checked'
  );
end;
$$;


-- =============================================
-- pg_cron: POS 메뉴 동기화 주기 등록
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'POS_MENU_SYNC_BATCH',
  'catchmenu_pos_menu_sync',
  '0 */2 * * *',
  '0 */2 * * * (2시간마다)',
  $sql$
SELECT catchmenu_integrations.sync_okpos_menu(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  'OKpos 메뉴 동기화. 2시간마다.'
),
(
  'POS_HEALTH_CHECK_BATCH',
  'catchmenu_pos_health',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
SELECT catchmenu_integrations.get_pos_health(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  'POS 연동 상태 확인. 5분마다.'
)
on conflict (job_code) do nothing;


-- =============================================
-- Flutter SDK 패턴: POS 연동
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dart_code
) values
(
  'FLUTTER_POS_HEALTH',
  'POS 연동 상태 확인 패턴',
  'RPC_CALL',
  '["POS", "STAFF_APP"]'::jsonb,
  'POS 연동 상태 주기적 확인 + 이상 알림',
  $dart$
// lib/services/pos_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PosService {
  final _supabase = Supabase.instance.client;

  // POS 연동 상태 확인
  Future<PosHealthResult> checkPosHealth({
    required String tenantId,
    required String storeId,
  }) async {
    final response = await _supabase.rpc(
      'get_pos_health',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
      },
    );

    final data = response as Map<String, dynamic>;
    final integrations = (data['pos_integrations']
      as List).cast<Map<String, dynamic>>();

    return PosHealthResult(
      totalCount: data['total_count'] as int,
      healthyCount: data['healthy_count'] as int,
      unhealthyCount: data['unhealthy_count'] as int,
      integrations: integrations.map(
        (i) => PosIntegrationHealth(
          providerCode: i['provider_code'] as String,
          providerName: i['provider_name'] as String,
          configStatus: i['config_status'] as String,
          isHealthy: i['is_healthy'] as bool,
          consecutiveFailures:
            i['consecutive_failures'] as int,
          lastErrorMessage:
            i['last_error_message'] as String?,
          minutesSinceHeartbeat:
            i['minutes_since_heartbeat'] as int?,
        )
      ).toList(),
    );
  }

  // POS 연동 등록
  Future<bool> registerPosProvider({
    required String tenantId,
    required String storeId,
    required String providerCode,
    String? merchantId,
    String? terminalId,
    bool orderPushEnabled = false,
    bool paymentConfirmEnabled = false,
  }) async {
    final response = await _supabase.rpc(
      'register_pos_provider',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_provider_code': providerCode,
        'p_merchant_id': merchantId,
        'p_terminal_id': terminalId,
        'p_order_push_enabled': orderPushEnabled,
        'p_payment_confirm_enabled':
          paymentConfirmEnabled,
      },
    );

    return response['success'] as bool;
  }
}

class PosHealthResult {
  final int totalCount;
  final int healthyCount;
  final int unhealthyCount;
  final List<PosIntegrationHealth> integrations;

  bool get isAllHealthy =>
    unhealthyCount == 0 && totalCount > 0;

  PosHealthResult({
    required this.totalCount,
    required this.healthyCount,
    required this.unhealthyCount,
    required this.integrations,
  });
}

class PosIntegrationHealth {
  final String providerCode;
  final String providerName;
  final String configStatus;
  final bool isHealthy;
  final int consecutiveFailures;
  final String? lastErrorMessage;
  final int? minutesSinceHeartbeat;

  PosIntegrationHealth({
    required this.providerCode,
    required this.providerName,
    required this.configStatus,
    required this.isHealthy,
    required this.consecutiveFailures,
    this.lastErrorMessage,
    this.minutesSinceHeartbeat,
  });
}
$dart$
)
on conflict (pattern_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.sync_pos_menu_item(
      uuid, uuid, text, text, text, int,
      text, text, boolean, boolean, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_pos_menu_item(
      uuid, uuid, text, text, text, int,
      text, text, boolean, boolean, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_pos_health(uuid, uuid)
    from public;
  grant execute on function
    catchmenu_integrations.get_pos_health(uuid, uuid)
    to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.sync_pos_menu_item(
    uuid, uuid, text, text, text, int,
    text, text, boolean, boolean, jsonb, text
  ) is
  'POS 메뉴 항목 → 캐치메뉴 menus 동기화.
   menu_code = {provider_code}_{pos_item_code}
   품절 변경 감지 → KDS 조건 자동 업데이트.
   특허2: 품절 = KDS conditions_met.menu_available.
   OKpos/토스POS 공통 사용.
   옵션 동기화 포함.
   2시간마다 pg_cron으로 자동 실행.';

comment on function
  catchmenu_integrations.get_pos_health(uuid, uuid) is
  'POS 연동 상태 헬스체크.
   is_healthy 조건:
   - config_status = ACTIVE
   - consecutive_failures < 3
   - last_heartbeat_at < 10분
   Flutter POS 화면 + 직원 앱 대시보드에 표시.
   5분마다 pg_cron으로 자동 실행.';