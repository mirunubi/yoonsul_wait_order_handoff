-- 0071_create_edge_function_templates.sql
-- Purpose: Edge Function integration guide and template registry.
--          TypeScript template signatures stored as documentation.
--          Flutter SDK usage patterns stored as reference.
--          Supabase Edge Function → RPC routing patterns.
-- Depends on: 0070_create_flutter_bootstrap_rpc.sql
-- Creates:
--   catchmenu_common.edge_function_templates (table)
--   catchmenu_common.flutter_sdk_patterns (table)
--   function catchmenu_common.get_edge_function_template(...)
--   function catchmenu_common.get_flutter_sdk_pattern(...)

-- =============================================
-- edge_function_templates table
-- TypeScript Edge Function 구현 가이드
-- =============================================
create table if not exists
  catchmenu_common.edge_function_templates (
  id uuid primary key default gen_random_uuid(),

  template_code text not null unique,
  function_code text not null
    references catchmenu_common.edge_function_registry(
      function_code
    ),
  template_language text not null default 'typescript',
  template_category text not null,

  -- TypeScript 코드 템플릿
  template_code_body text not null,
  template_description text,
  dependencies jsonb default '[]'::jsonb,
  environment_vars jsonb default '[]'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_template_language check (
    template_language in (
      'typescript', 'javascript', 'dart'
    )
  ),
  constraint chk_template_category check (
    template_category in (
      'WEBHOOK', 'HTTP_HANDLER',
      'SCHEDULED', 'REALTIME_BROADCAST',
      'AI_HANDLER', 'FIREBASE_SYNC'
    )
  )
);

drop trigger if exists trg_edge_templates_updated
  on catchmenu_common.edge_function_templates;
create trigger trg_edge_templates_updated
  before update on
    catchmenu_common.edge_function_templates
  for each row execute function
    catchmenu_common.set_updated_at();

-- =============================================
-- flutter_sdk_patterns table
-- Flutter Dart 코드 패턴 레지스트리
-- =============================================
create table if not exists
  catchmenu_common.flutter_sdk_patterns (
  id uuid primary key default gen_random_uuid(),

  pattern_code text not null unique,
  pattern_name text not null,
  pattern_category text not null,
  device_types jsonb default '["ALL"]'::jsonb,

  -- Dart 코드 패턴
  dart_code text not null,
  description text,
  dependencies jsonb default '[]'::jsonb,
  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_pattern_category check (
    pattern_category in (
      'BOOTSTRAP', 'REALTIME',
      'RPC_CALL', 'HEARTBEAT',
      'AUTH', 'EDGE_FUNCTION',
      'ERROR_HANDLING', 'I18N'
    )
  )
);

drop trigger if exists trg_flutter_patterns_updated
  on catchmenu_common.flutter_sdk_patterns;
create trigger trg_flutter_patterns_updated
  before update on catchmenu_common.flutter_sdk_patterns
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- Seed Edge Function templates
-- =============================================
insert into catchmenu_common.edge_function_templates (
  template_code, function_code,
  template_category, template_description,
  environment_vars, template_code_body
) values

-- =============================================
-- 1. Toss Webhook Handler
-- =============================================
(
  'TOSS_WEBHOOK_HANDLER',
  'TOSS_WEBHOOK',
  'WEBHOOK',
  'Toss Payments 웹훅 수신 → 서명 검증 → RPC 라우팅',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY","TOSS_WEBHOOK_SECRET"]'::jsonb,
  $template$
// supabase/functions/toss-webhook/index.ts
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("TOSS_WEBHOOK_SECRET")!;

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers":
          "Content-Type,toss-signature",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405 }
    );
  }

  const correlationId = crypto.randomUUID();

  try {
    const rawBody = await req.text();
    const payload = JSON.parse(rawBody);
    const signatureHeader =
      req.headers.get("toss-signature") ?? "";
    const rawHeaders: Record<string, string> = {};
    req.headers.forEach((v, k) => { rawHeaders[k] = v; });

    // Extract tenant/store from payload
    // orderId format: {tenantId}_{storeId}_{seq}
    const orderId = payload.orderId as string;
    const parts = orderId.split("_");
    if (parts.length < 3) {
      return new Response(
        JSON.stringify({
          error: "invalid_order_id_format",
          correlation_id: correlationId,
        }),
        { status: 400 }
      );
    }

    const tenantId = parts[0];
    const storeId = parts[1];

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    // Route to RPC
    const { data, error } = await supabase.rpc(
      "process_toss_webhook",
      {
        p_tenant_id: tenantId,
        p_store_id: storeId,
        p_raw_headers: rawHeaders,
        p_raw_body: payload,
        p_signature_header: signatureHeader,
        p_webhook_secret: WEBHOOK_SECRET,
        p_correlation_id: correlationId,
      }
    );

    if (error) {
      console.error(
        `[ERROR] toss-webhook | correlation=${correlationId}`,
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

    // Always return 200 to Toss (ack)
    // Toss retries on non-2xx
    console.log(
      `[INFO] toss-webhook processed`
      + ` | correlation=${correlationId}`
      + ` | status=${data?.processing_status}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[CRITICAL] toss-webhook unhandled`
      + ` | correlation=${correlationId}`,
      err
    );
    // Return 200 anyway to prevent Toss retry storm
    return new Response(
      JSON.stringify({
        error: "internal_error",
        correlation_id: correlationId,
      }),
      { status: 200 }
    );
  }
});
$template$
),

-- =============================================
-- 2. Baemin Webhook Handler
-- =============================================
(
  'BAEMIN_WEBHOOK_HANDLER',
  'BAEMIN_WEBHOOK',
  'WEBHOOK',
  '배달의민족 웹훅 수신 → KDS 과부하 체크 → 주문 처리',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY","BAEMIN_WEBHOOK_SECRET","STORE_ID","TENANT_ID"]'::jsonb,
  $template$
// supabase/functions/baemin-webhook/index.ts
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
// Store-specific env vars (one function per store)
const TENANT_ID = Deno.env.get("TENANT_ID")!;
const STORE_ID = Deno.env.get("STORE_ID")!;

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  const correlationId = crypto.randomUUID();

  try {
    const payload = await req.json();
    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    const { data, error } = await supabase.rpc(
      "process_baemin_order",
      {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_raw_payload: payload,
        p_correlation_id: correlationId,
      }
    );

    if (error) throw error;

    // KDS overload → auto reject
    if (!data?.success &&
        data?.error_key === "kds_overloaded") {
      console.warn(
        `[WARN] baemin order rejected: KDS overloaded`
        + ` | correlation=${correlationId}`
      );
      // Return reject signal to Baemin API
      return new Response(
        JSON.stringify({
          accepted: false,
          reason: "KITCHEN_BUSY",
          correlation_id: correlationId,
        }),
        { status: 200 }
      );
    }

    console.log(
      `[INFO] baemin order processed`
      + ` | order=${data?.order_number}`
      + ` | correlation=${correlationId}`
    );

    // Broadcast to Flutter DID/Staff
    if (data?.success && data?.order_id) {
      await supabase.rpc("notify_channel", {
        p_tenant_id: TENANT_ID,
        p_store_id: STORE_ID,
        p_channel_type: "STAFF_ALERTS",
        p_event_type: "delivery_order_received",
        p_payload: {
          order_id: data.order_id,
          order_number: data.order_number,
          platform: "DELIVERY_BAEMIN",
          total_amount: data.total_amount,
        },
        p_locale: "ko",
      });
    }

    return new Response(
      JSON.stringify({
        accepted: true,
        order_id: data?.order_id,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[ERROR] baemin-webhook | correlation=${correlationId}`,
      err
    );
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500 }
    );
  }
});
$template$
),

-- =============================================
-- 3. Session Cleanup Scheduled Function
-- =============================================
(
  'SESSION_CLEANUP_SCHEDULED',
  'SESSION_CLEANUP_CRON',
  'SCHEDULED',
  '15분마다 실행: 만료 세션 정리 + 노쇼 처리',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY"]'::jsonb,
  $template$
// supabase/functions/session-cleanup/index.ts
// Invoke via Supabase pg_cron or external scheduler
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req: Request) => {
  // Accept only POST from scheduler
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const correlationId = crypto.randomUUID();
  const startTime = Date.now();

  try {
    const body = await req.json();
    const { tenant_id, store_id } = body;

    if (!tenant_id || !store_id) {
      return new Response(
        JSON.stringify({ error: "tenant_id and store_id required" }),
        { status: 400 }
      );
    }

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    const { data, error } = await supabase.rpc(
      "run_session_cleanup_batch",
      {
        p_tenant_id: tenant_id,
        p_store_id: store_id,
      }
    );

    if (error) throw error;

    const durationMs = Date.now() - startTime;
    console.log(
      `[INFO] session-cleanup completed`
      + ` | expired=${data?.expired_sessions}`
      + ` | no_show=${data?.no_show_sessions}`
      + ` | kds_cancelled=${data?.kds_cancelled}`
      + ` | duration=${durationMs}ms`
      + ` | correlation=${correlationId}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        result: data,
        duration_ms: durationMs,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[ERROR] session-cleanup | correlation=${correlationId}`,
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
-- 4. AI Chat Handler (Firebase 포워딩)
-- =============================================
(
  'AI_CHAT_HANDLER',
  'AI_CHAT_HANDLER',
  'AI_HANDLER',
  'AI 고객센터: Context Builder → AI API → Firebase 저장',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY","ANTHROPIC_API_KEY","FIREBASE_PROJECT_ID","FIREBASE_SERVICE_ACCOUNT"]'::jsonb,
  $template$
// supabase/functions/ai-chat/index.ts
// Phase 1: Supabase only
// Phase 2: Firebase Firestore for chat history
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Anthropic from "https://esm.sh/@anthropic-ai/sdk@0.24.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers":
          "Authorization,Content-Type",
      },
    });
  }

  const correlationId = crypto.randomUUID();
  const authHeader = req.headers.get("Authorization");

  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: "unauthorized" }),
      { status: 401 }
    );
  }

  try {
    const {
      tenant_id,
      store_id,
      query_text,
      query_type,
      locale,
      query_embedding,
    } = await req.json();

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    // STEP 1: Build grounded context from pgvector
    const { data: context, error: contextError } =
      await supabase.rpc(
        "build_grounded_ai_context",
        {
          p_tenant_id: tenant_id,
          p_store_id: store_id,
          p_query_text: query_text,
          p_query_embedding: query_embedding,
          p_query_type: query_type ?? "FAQ_LOOKUP",
          p_locale: locale ?? "ko",
          p_document_types: JSON.stringify([
            "SOP", "POLICY", "RUNBOOK",
            "CHECKLIST", "FAQ"
          ]),
        }
      );

    if (contextError) throw contextError;

    // STEP 2: If no grounded context → reject
    if (!context?.is_grounded) {
      const noContextMsg =
        locale === "ko"
          ? "해당 질문에 대한 승인된 문서를 찾을 수 없습니다. "
            + "관리자에게 문의해 주세요."
          : "No approved documents found for this query. "
            + "Please contact your manager.";

      return new Response(
        JSON.stringify({
          success: true,
          is_grounded: false,
          answer: noContextMsg,
          citations: [],
          correlation_id: correlationId,
        }),
        {
          status: 200,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // STEP 3: Build system prompt with retrieved docs
    const retrievedDocs = context.context.all_results
      as Array<{
        chunk_text: string;
        citation: {
          document_code: string;
          document_type: string;
          title: string;
          version: number;
        };
        similarity_score: number;
      }>;

    const docsContext = retrievedDocs
      .map((doc, idx) =>
        `[Document ${idx + 1}]`
        + ` Type: ${doc.citation.document_type}`
        + ` | Code: ${doc.citation.document_code}`
        + ` | Title: ${doc.citation.title}`
        + ` | v${doc.citation.version}`
        + `\n${doc.chunk_text}`
      )
      .join("\n\n---\n\n");

    const groundingInstructions =
      context.grounding_instructions;

    const systemPrompt = locale === "ko"
      ? `당신은 외식업 운영 AI 어시스턴트입니다.
아래 승인된 문서만을 기반으로 답변하세요.
반드시 지켜야 할 규칙:
1. 검색된 문서 내용만 사용하세요
2. 모든 답변에 출처를 인용하세요
3. 문서에 없는 내용은 "해당 문서에서 찾을 수 없습니다"라고 답하세요
4. 추측이나 학습 지식만으로 답변하지 마세요
5. 출처 형식: [문서유형] 제목 (v버전) — 코드

승인된 문서:
${docsContext}`
      : `You are a F&B operations AI assistant.
Answer ONLY based on the approved documents below.
Rules you MUST follow:
1. Use ONLY retrieved document content
2. Cite sources in every answer
3. If not found: "Not found in approved documents"
4. Never answer from training knowledge alone
5. Citation format: [Type] Title (vN) — Code

Approved documents:
${docsContext}`;

    // STEP 4: Call Anthropic Claude
    const anthropic = new Anthropic({
      apiKey: ANTHROPIC_KEY,
    });

    const aiResponse = await anthropic.messages.create({
      model: "claude-sonnet-4-6",
      max_tokens: 1024,
      system: systemPrompt,
      messages: [
        {
          role: "user",
          content: query_text,
        },
      ],
    });

    const aiAnswer = aiResponse.content
      .filter((c) => c.type === "text")
      .map((c) => (c as { type: "text"; text: string }).text)
      .join("\n");

    // Extract cited document IDs from context
    const citedDocumentIds = retrievedDocs.map(
      (_: unknown, idx: number) =>
        context.context.all_results[idx]?.document_id
    ).filter(Boolean);

    const citedVersionIds = retrievedDocs.map(
      (_: unknown, idx: number) =>
        context.context.all_results[idx]?.version_id
    ).filter(Boolean);

    // STEP 5: Verify answer grounding
    const { data: verification } = await supabase.rpc(
      "verify_answer_grounding",
      {
        p_tenant_id: tenant_id,
        p_context_id: context.context_id,
        p_ai_answer: aiAnswer,
        p_cited_document_ids: JSON.stringify(
          citedDocumentIds
        ),
        p_cited_version_ids: JSON.stringify(
          citedVersionIds
        ),
        p_query_text: query_text,
        p_locale: locale ?? "ko",
      }
    );

    // STEP 6: Block ungrounded answers
    if (
      verification?.verdict === "REJECTED_NO_CITATIONS"
      || verification?.verdict ===
        "REJECTED_STALE_CITATIONS"
    ) {
      const blockMsg =
        locale === "ko"
          ? "승인된 문서 기반으로 답변할 수 없습니다. "
            + "관리자에게 문의해 주세요."
          : "Cannot answer based on approved documents. "
            + "Please contact your manager.";

      return new Response(
        JSON.stringify({
          success: false,
          is_grounded: false,
          answer: blockMsg,
          verdict: verification?.verdict,
          correlation_id: correlationId,
        }),
        { status: 200 }
      );
    }

    // STEP 7: Build citations for response
    const citations = retrievedDocs.map((doc) => ({
      document_code: doc.citation.document_code,
      document_type: doc.citation.document_type,
      title: doc.citation.title,
      version: doc.citation.version,
      similarity_score: doc.similarity_score,
    }));

    console.log(
      `[INFO] ai-chat answered`
      + ` | grounded=${verification?.is_grounded}`
      + ` | citations=${citations.length}`
      + ` | correlation=${correlationId}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        context_id: context.context_id,
        is_grounded: verification?.is_grounded ?? true,
        answer: aiAnswer,
        citations,
        verdict: verification?.verdict,
        correlation_id: correlationId,
        // Phase 2: Firebase chat history storage
        // firebase_session_id: await saveToFirebase(...)
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[ERROR] ai-chat | correlation=${correlationId}`,
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
-- 5. Daily Close Scheduled Function
-- =============================================
(
  'DAILY_CLOSE_SCHEDULED',
  'DAILY_CLOSE_CRON',
  'SCHEDULED',
  '23:00 KST 일일 마감 배치 실행',
  '["SUPABASE_URL","SUPABASE_SERVICE_ROLE_KEY"]'::jsonb,
  $template$
// supabase/functions/daily-close/index.ts
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const correlationId = crypto.randomUUID();
  const startTime = Date.now();

  try {
    const { tenant_id, store_ids } = await req.json();

    if (!tenant_id || !store_ids?.length) {
      return new Response(
        JSON.stringify({
          error: "tenant_id and store_ids required"
        }),
        { status: 400 }
      );
    }

    const supabase = createClient(
      SUPABASE_URL, SUPABASE_KEY
    );

    const results = [];

    // Run batch for each store sequentially
    for (const storeId of store_ids) {
      const { data, error } = await supabase.rpc(
        "run_daily_close_batch",
        {
          p_tenant_id: tenant_id,
          p_store_id: storeId,
          p_force: false,
        }
      );

      if (error) {
        console.error(
          `[ERROR] daily-close store=${storeId}`,
          error
        );
        results.push({
          store_id: storeId,
          success: false,
          error: error.message,
        });
      } else {
        results.push({
          store_id: storeId,
          success: true,
          result: data,
        });
      }
    }

    const durationMs = Date.now() - startTime;
    const successCount = results.filter(
      (r) => r.success
    ).length;

    console.log(
      `[INFO] daily-close completed`
      + ` | stores=${store_ids.length}`
      + ` | success=${successCount}`
      + ` | duration=${durationMs}ms`
      + ` | correlation=${correlationId}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        total_stores: store_ids.length,
        success_count: successCount,
        results,
        duration_ms: durationMs,
        correlation_id: correlationId,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );

  } catch (err) {
    console.error(
      `[ERROR] daily-close | correlation=${correlationId}`,
      err
    );
    return new Response(
      JSON.stringify({ error: "internal_error" }),
      { status: 500 }
    );
  }
});
$template$
)
on conflict (template_code) do nothing;


-- =============================================
-- Seed Flutter SDK patterns
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values

-- =============================================
-- 1. App Bootstrap
-- =============================================
(
  'FLUTTER_BOOTSTRAP',
  '앱 초기화 패턴',
  'BOOTSTRAP',
  '["ALL"]'::jsonb,
  '앱 시작 시 단일 RPC로 전체 설정 로드',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/bootstrap_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class BootstrapService {
  final _supabase = Supabase.instance.client;

  Future<BootstrapResult> bootstrap({
    required String tenantId,
    required String storeId,
    required String deviceId,
    required String deviceType,
    String locale = 'ko',
    String? appVersion,
  }) async {
    try {
      final response = await _supabase.rpc(
        'bootstrap_app',
        params: {
          'p_tenant_id': tenantId,
          'p_store_id': storeId,
          'p_device_id': deviceId,
          'p_device_type': deviceType,
          'p_locale': locale,
          'p_app_version': appVersion,
          'p_correlation_id':
            DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response['success'] == false) {
        final error = response['error'] as Map;
        throw AppException(
          code: error['code'] as int,
          key: error['key'] as String,
          message: error['message'] as String,
        );
      }

      return BootstrapResult.fromJson(
        response as Map<String, dynamic>
      );

    } on PostgrestException catch (e) {
      throw AppException(
        code: 99001,
        key: 'database_error',
        message: e.message,
      );
    }
  }
}

// Device-specific bootstrap
Future<Map<String, dynamic>> bootstrapKds({
  required String tenantId,
  required String storeId,
  required String deviceId,
  String? kitchenZone,
}) async {
  return await Supabase.instance.client.rpc(
    'bootstrap_kds_app',
    params: {
      'p_tenant_id': tenantId,
      'p_store_id': storeId,
      'p_device_id': deviceId,
      'p_kitchen_zone': kitchenZone,
      'p_locale': 'ko',
    },
  );
}
$dart$
),

-- =============================================
-- 2. Realtime Subscription
-- =============================================
(
  'FLUTTER_REALTIME',
  'Supabase Realtime 구독 패턴',
  'REALTIME',
  '["ALL"]'::jsonb,
  'bootstrap에서 받은 채널 설정으로 구독',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  final _supabase = Supabase.instance.client;
  final List<RealtimeChannel> _channels = [];

  Future<void> subscribeAll({
    required List<Map<String, dynamic>> channels,
    required Function(Map<String, dynamic>) onEvent,
  }) async {
    for (final ch in channels) {
      final channelName =
        ch['channel_name_resolved'] as String;
      final realtimeType =
        ch['realtime_type'] as String;

      if (realtimeType == 'POSTGRES_CHANGES') {
        final channel = _supabase
          .channel(channelName)
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: ch['schema_name'] as String,
            table: ch['table_name'] as String,
            filter: ch['filter_column'] != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column:
                    ch['filter_column'] as String,
                  value: ch['filter_value'] as String,
                )
              : null,
            callback: (payload) {
              onEvent({
                'channel_type': ch['channel_type'],
                'event_type': payload.eventType.name,
                'new_record': payload.newRecord,
                'old_record': payload.oldRecord,
              });
            },
          )
          .subscribe();
        _channels.add(channel);

      } else if (realtimeType == 'BROADCAST') {
        final channel = _supabase
          .channel(channelName)
          .onBroadcast(
            event: '*',
            callback: (payload) {
              onEvent({
                'channel_type': ch['channel_type'],
                'broadcast': payload,
              });
            },
          )
          .subscribe();
        _channels.add(channel);
      }
    }
  }

  Future<void> unsubscribeAll() async {
    for (final ch in _channels) {
      await _supabase.removeChannel(ch);
    }
    _channels.clear();
  }
}
$dart$
),

-- =============================================
-- 3. Heartbeat Timer
-- =============================================
(
  'FLUTTER_HEARTBEAT',
  '주기적 Heartbeat 패턴',
  'HEARTBEAT',
  '["ALL"]'::jsonb,
  '30초 주기 heartbeat — 서버에서 interval 조정',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/heartbeat_service.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class HeartbeatService {
  final _supabase = Supabase.instance.client;
  Timer? _timer;
  int _intervalSeconds = 30;

  final String tenantId;
  final String storeId;
  final String deviceId;
  final Function(HeartbeatResult) onAlert;

  HeartbeatService({
    required this.tenantId,
    required this.storeId,
    required this.deviceId,
    required this.onAlert,
  });

  void start() {
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(
      Duration(seconds: _intervalSeconds),
      _beat,
    );
  }

  Future<void> _beat() async {
    try {
      final response = await _supabase.rpc(
        'heartbeat',
        params: {
          'p_tenant_id': tenantId,
          'p_store_id': storeId,
          'p_device_id': deviceId,
          'p_locale': 'ko',
        },
      );

      if (response['success'] == true) {
        // Adaptive interval from server
        _intervalSeconds =
          response['next_heartbeat_seconds'] as int? ?? 30;

        final alerts =
          response['alerts'] as Map<String, dynamic>;

        if (alerts['has_critical_alerts'] == true) {
          onAlert(HeartbeatResult(
            hasCriticalAlerts: true,
            paymentUncertain:
              alerts['payment_uncertain'] as bool,
            manualFallback:
              alerts['manual_fallback'] as bool,
            openExceptions:
              alerts['open_exceptions'] as int,
            storeMode: response['store_mode'] as String,
          ));
        }
      }
    } catch (e) {
      // Heartbeat failure → stay online, retry faster
      _intervalSeconds = 10;
    } finally {
      _scheduleNext();
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

class HeartbeatResult {
  final bool hasCriticalAlerts;
  final bool paymentUncertain;
  final bool manualFallback;
  final int openExceptions;
  final String storeMode;

  HeartbeatResult({
    required this.hasCriticalAlerts,
    required this.paymentUncertain,
    required this.manualFallback,
    required this.openExceptions,
    required this.storeMode,
  });
}
$dart$
),

-- =============================================
-- 4. Error Handling
-- =============================================
(
  'FLUTTER_ERROR_HANDLING',
  'i18n 에러 처리 패턴',
  'ERROR_HANDLING',
  '["ALL"]'::jsonb,
  'RPC 에러 코드 → i18n 메시지 + 로깅',
  '["supabase_flutter: ^2.0.0","flutter_riverpod: ^2.0.0"]'::jsonb,
  $dart$
// lib/core/app_exception.dart
class AppException implements Exception {
  final int code;
  final String key;
  final String message;
  final bool isRetryable;
  final String? recoveryHint;
  final String? sopCode;

  AppException({
    required this.code,
    required this.key,
    required this.message,
    this.isRetryable = false,
    this.recoveryHint,
    this.sopCode,
  });

  bool get isCritical =>
    code >= 99000 || key.contains('uncertain');

  @override
  String toString() =>
    'AppException[$code] $key: $message';
}

// lib/core/rpc_handler.dart
class RpcHandler {
  static Future<T> call<T>({
    required Future<dynamic> Function() rpc,
    required T Function(Map<String, dynamic>) onSuccess,
    String locale = 'ko',
  }) async {
    try {
      final response = await rpc();
      final result = response as Map<String, dynamic>;

      if (result['success'] == false) {
        final error = result['error']
          as Map<String, dynamic>?;
        throw AppException(
          code: (error?['code'] as num?)?.toInt() ?? 99001,
          key: error?['key'] as String? ?? 'internal_error',
          message: error?['message'] as String? ?? 'Error',
          isRetryable:
            error?['is_retryable'] as bool? ?? false,
          recoveryHint:
            error?['recovery_hint'] as String?,
          sopCode: error?['sop_code'] as String?,
        );
      }

      return onSuccess(result);

    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw AppException(
        code: 99002,
        key: 'database_error',
        message: e.message,
        isRetryable: true,
      );
    } catch (e) {
      throw AppException(
        code: 99001,
        key: 'internal_error',
        message: e.toString(),
        isRetryable: false,
      );
    }
  }
}

// Usage example
// final result = await RpcHandler.call(
//   rpc: () => supabase.rpc('confirm_order', params: {...}),
//   onSuccess: (data) => Order.fromJson(data['data']),
// );
$dart$
),

-- =============================================
-- 5. Edge Function Invoke
-- =============================================
(
  'FLUTTER_EDGE_INVOKE',
  'Edge Function 호출 패턴',
  'EDGE_FUNCTION',
  '["ALL"]'::jsonb,
  'Flutter → Supabase Edge Function 호출',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/edge_function_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class EdgeFunctionService {
  final _supabase = Supabase.instance.client;

  // VAN 승인 처리
  Future<Map<String, dynamic>> processVanApproval({
    required String tenantId,
    required String storeId,
    required String vanProvider,
    required String intentId,
    required int approvedAmount,
    required Map<String, dynamic> rawResponse,
    String? vanApprovalNumber,
    String? responseCode,
  }) async {
    final response =
      await _supabase.functions.invoke(
        'van-approval',
        body: {
          'p_tenant_id': tenantId,
          'p_store_id': storeId,
          'p_van_provider': vanProvider,
          'p_intent_id': intentId,
          'p_requested_amount': approvedAmount,
          'p_raw_response': rawResponse,
          'p_van_approval_number': vanApprovalNumber,
          'p_response_code': responseCode,
          'p_correlation_id':
            DateTime.now()
              .millisecondsSinceEpoch.toString(),
        },
      );

    if (response.status != 200) {
      throw AppException(
        code: 4010,
        key: 'van_approval_failed',
        message: 'VAN approval failed: '
          + '${response.status}',
        isRetryable: true,
      );
    }

    return response.data as Map<String, dynamic>;
  }

  // AI 고객센터 채팅
  Future<AiChatResponse> sendAiChat({
    required String tenantId,
    required String storeId,
    required String queryText,
    required List<double> queryEmbedding,
    String locale = 'ko',
  }) async {
    final response =
      await _supabase.functions.invoke(
        'ai-chat',
        body: {
          'tenant_id': tenantId,
          'store_id': storeId,
          'query_text': queryText,
          'query_embedding': queryEmbedding,
          'query_type': 'FAQ_LOOKUP',
          'locale': locale,
        },
      );

    final data = response.data as Map<String, dynamic>;
    return AiChatResponse(
      success: data['success'] as bool,
      isGrounded: data['is_grounded'] as bool,
      answer: data['answer'] as String,
      citations: (data['citations'] as List?)
        ?.cast<Map<String, dynamic>>() ?? [],
      correlationId:
        data['correlation_id'] as String?,
    );
  }
}

class AiChatResponse {
  final bool success;
  final bool isGrounded;
  final String answer;
  final List<Map<String, dynamic>> citations;
  final String? correlationId;

  AiChatResponse({
    required this.success,
    required this.isGrounded,
    required this.answer,
    required this.citations,
    this.correlationId,
  });
}
$dart$
)
on conflict (pattern_code) do nothing;


-- =============================================
-- RPCs for template retrieval
-- =============================================
create or replace function
  catchmenu_common.get_edge_function_template(
  p_template_code text
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_template record;
begin
  select * into v_template
  from catchmenu_common.edge_function_templates
  where template_code = p_template_code;

  if v_template.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'template_not_found',
      'template_code', p_template_code
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'template_code', v_template.template_code,
    'function_code', v_template.function_code,
    'template_category', v_template.template_category,
    'template_language', v_template.template_language,
    'description', v_template.template_description,
    'environment_vars', v_template.environment_vars,
    'code', v_template.template_code_body,
    'deploy_command',
      'supabase functions deploy '
      || lower(
        replace(v_template.function_code, '_', '-')
      ),
    'message_code', 'template_loaded'
  );
end;
$$;


create or replace function
  catchmenu_common.get_flutter_sdk_pattern(
  p_pattern_code text
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_pattern record;
begin
  select * into v_pattern
  from catchmenu_common.flutter_sdk_patterns
  where pattern_code = p_pattern_code;

  if v_pattern.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'pattern_not_found',
      'pattern_code', p_pattern_code
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'pattern_code', v_pattern.pattern_code,
    'pattern_name', v_pattern.pattern_name,
    'pattern_category', v_pattern.pattern_category,
    'device_types', v_pattern.device_types,
    'description', v_pattern.description,
    'dependencies', v_pattern.dependencies,
    'dart_code', v_pattern.dart_code,
    'notes', v_pattern.notes,
    'message_code', 'pattern_loaded'
  );
end;
$$;


-- grants
do $$
begin
  grant select on
    catchmenu_common.edge_function_templates
    to authenticated;
  grant select on
    catchmenu_common.flutter_sdk_patterns
    to authenticated;

  revoke all on function
    catchmenu_common.get_edge_function_template(text)
    from public;
  grant execute on function
    catchmenu_common.get_edge_function_template(text)
    to authenticated;

  revoke all on function
    catchmenu_common.get_flutter_sdk_pattern(text)
    from public;
  grant execute on function
    catchmenu_common.get_flutter_sdk_pattern(text)
    to authenticated;
end;
$$;

comment on table
  catchmenu_common.edge_function_templates is
  'Supabase Edge Function TypeScript templates.
   Deploy with:
     supabase functions deploy {function-name}
   Env vars: set in Supabase Dashboard or
     supabase secrets set KEY=VALUE

   Templates included:
   - TOSS_WEBHOOK_HANDLER: 서명검증 + RPC 라우팅
   - BAEMIN_WEBHOOK_HANDLER: KDS 과부하체크 + 자동거절
   - SESSION_CLEANUP_SCHEDULED: 15분 배치
   - AI_CHAT_HANDLER: pgvector + Claude + grounding
   - DAILY_CLOSE_SCHEDULED: 23:00 일일마감

   특허1: Edge Function = Gateway 샌드박스 구현체.
   모든 외부 이벤트 = Edge Function 필수 경유.';

comment on table
  catchmenu_common.flutter_sdk_patterns is
  'Flutter Dart SDK usage patterns.
   DBeaver에서 조회:
     SELECT dart_code
     FROM catchmenu_common.flutter_sdk_patterns
     WHERE pattern_code = ''FLUTTER_BOOTSTRAP'';

   Patterns included:
   - FLUTTER_BOOTSTRAP: 앱 초기화
   - FLUTTER_REALTIME: Realtime 구독
   - FLUTTER_HEARTBEAT: 30s 주기 heartbeat
   - FLUTTER_ERROR_HANDLING: i18n 에러 처리
   - FLUTTER_EDGE_INVOKE: Edge Function 호출';