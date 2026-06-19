-- 0072_create_pg_cron_schedules.sql
-- Purpose: pg_cron schedule registration for all batch jobs.
--          Operational validation queries for DBeaver.
--          Windows PowerShell deployment commands.
--          Supabase Edge Function cron trigger setup.
-- Depends on: 0071_create_edge_function_templates.sql
-- Note: pg_cron requires Supabase Pro or above.
--       Enable in Supabase Dashboard > Database > Extensions.
--       Or: CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =============================================
-- Enable pg_cron extension
-- =============================================
create extension if not exists pg_cron
  schema cron;

comment on extension pg_cron is
  'PostgreSQL job scheduler (cron).
   Supabase Pro+ 필요.
   Dashboard → Database → Extensions → pg_cron.
   cron.schedule() → UTC 기준.
   Asia/Seoul = UTC+9 → KST 23:00 = UTC 14:00.';


-- =============================================
-- pg_cron job registry sync table
-- pg_cron job ID ↔ catchmenu job_code 매핑
-- =============================================
create table if not exists
  catchmenu_common.pg_cron_jobs (
  id uuid primary key default gen_random_uuid(),
  job_code text not null unique,
  pg_cron_job_id bigint,
  pg_cron_job_name text not null,
  schedule_cron_utc text not null,
  schedule_cron_kst text not null,
  sql_command text not null,
  is_registered boolean not null default false,
  last_registered_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_pg_cron_jobs_updated
  on catchmenu_common.pg_cron_jobs;
create trigger trg_pg_cron_jobs_updated
  before update on catchmenu_common.pg_cron_jobs
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.pg_cron_jobs is
  'pg_cron job registry.
   schedule_cron_utc: pg_cron에 등록되는 UTC 기준.
   schedule_cron_kst: 사람이 읽는 KST 기준.
   pg_cron_job_id: cron.job 테이블의 jobid.

   등록 확인:
   SELECT * FROM cron.job ORDER BY jobid;

   실행 이력:
   SELECT * FROM cron.job_run_details
   ORDER BY start_time DESC LIMIT 20;';


-- seed pg_cron job definitions
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'SESSION_CLEANUP',
  'catchmenu_session_cleanup',
  '*/15 * * * *',
  '*/15 * * * * (15분마다)',
  $sql$
SELECT catchmenu_common.run_session_cleanup_batch(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  '세션 만료 정리 + 노쇼 자동 처리. 15분마다 실행.'
),
(
  'POINT_EXPIRY_BATCH',
  'catchmenu_point_expiry',
  '0 17 * * *',
  '0 2 * * * (매일 새벽 2시 KST)',
  $sql$
SELECT catchmenu_store.expire_points(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_batch_size := 500
);
$sql$,
  '포인트 만료 처리. 매일 새벽 2시 KST.'
),
(
  'DAILY_CLOSE_BATCH',
  'catchmenu_daily_close',
  '0 14 * * *',
  '0 23 * * * (매일 밤 11시 KST)',
  $sql$
SELECT catchmenu_common.run_daily_close_batch(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_force := false
);
$sql$,
  '일일 마감 배치. 매일 밤 11시 KST.'
),
(
  'NIGHTLY_INTEGRITY_CHECK',
  'catchmenu_integrity_check',
  '0 16 * * *',
  '0 1 * * * (매일 새벽 1시 KST)',
  $sql$
SELECT catchmenu_common.run_nightly_integrity_batch(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  '야간 4원장 무결성 검증. 매일 새벽 1시 KST.'
),
(
  'KNOWLEDGE_GAP_BATCH',
  'catchmenu_knowledge_gap',
  '0 18 * * *',
  '0 3 * * * (매일 새벽 3시 KST)',
  $sql$
SELECT catchmenu_common.run_knowledge_gap_batch(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_batch_size := 50
);
$sql$,
  'Knowledge Gap 분석 + SOP 진화 큐잉. 매일 새벽 3시 KST.'
),
(
  'DAILY_RECONCILIATION',
  'catchmenu_reconciliation',
  '30 14 * * *',
  '30 23 * * * (매일 밤 11시 30분 KST)',
  $sql$
SELECT catchmenu_payment.run_layer1_reconciliation(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  'Layer 1 결제 대사. 매일 밤 11시 30분 KST.'
),
(
  'WEEKLY_SECURITY_SCAN',
  'catchmenu_security_scan',
  '0 19 * * 0',
  '0 4 * * 0 (매주 일요일 새벽 4시 KST)',
  $sql$
SELECT catchmenu_audit.generate_security_report(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_scanned_by_type := 'SYSTEM'
);
$sql$,
  '주간 보안 스캔. 매주 일요일 새벽 4시 KST.'
),
(
  'COUPON_EXPIRY_UPDATE',
  'catchmenu_coupon_expiry',
  '0 15 * * *',
  '0 0 * * * (매일 자정 KST)',
  $sql$
UPDATE catchmenu_store.coupons
SET
  coupon_status = 'EXPIRED',
  updated_at = now()
WHERE valid_until < now()
  AND coupon_status = 'ACTIVE';
$sql$,
  '만료 쿠폰 상태 업데이트. 매일 자정 KST.'
)
on conflict (job_code) do nothing;


-- =============================================
-- pg_cron 등록 함수
-- =============================================
create or replace function
  catchmenu_common.register_all_pg_cron_jobs()
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common, cron
as $$
declare
  v_job record;
  v_job_id bigint;
  v_registered int := 0;
  v_failed int := 0;
  v_results jsonb := '[]'::jsonb;
begin
  for v_job in
    select job_code, pg_cron_job_name,
           schedule_cron_utc, sql_command
    from catchmenu_common.pg_cron_jobs
    where is_registered = false
    order by job_code
  loop
    begin
      -- unschedule if exists
      perform cron.unschedule(v_job.pg_cron_job_name);
    exception when others then
      null; -- ignore if not exists
    end;

    begin
      -- register pg_cron job
      select cron.schedule(
        v_job.pg_cron_job_name,
        v_job.schedule_cron_utc,
        v_job.sql_command
      ) into v_job_id;

      -- update registry
      update catchmenu_common.pg_cron_jobs
      set
        pg_cron_job_id = v_job_id,
        is_registered = true,
        last_registered_at = now()
      where job_code = v_job.job_code;

      v_registered := v_registered + 1;

      v_results := v_results || jsonb_build_array(
        jsonb_build_object(
          'job_code', v_job.job_code,
          'pg_cron_job_name', v_job.pg_cron_job_name,
          'job_id', v_job_id,
          'status', 'REGISTERED'
        )
      );

    exception when others then
      v_failed := v_failed + 1;
      v_results := v_results || jsonb_build_array(
        jsonb_build_object(
          'job_code', v_job.job_code,
          'status', 'FAILED',
          'error', sqlerrm
        )
      );
    end;
  end loop;

  return jsonb_build_object(
    'success', v_failed = 0,
    'registered', v_registered,
    'failed', v_failed,
    'results', v_results,
    'next_step', case v_registered
      when 0 then 'All jobs already registered'
      else 'Run: SELECT * FROM cron.job;'
    end
  );
end;
$$;

comment on function
  catchmenu_common.register_all_pg_cron_jobs() is
  'Registers all batch jobs with pg_cron.
   Run once after initial deployment:
   SELECT * FROM catchmenu_common.register_all_pg_cron_jobs();

   Verify registration:
   SELECT jobid, jobname, schedule, active
   FROM cron.job ORDER BY jobid;

   Check execution history:
   SELECT *
   FROM cron.job_run_details
   ORDER BY start_time DESC LIMIT 20;';


-- =============================================
-- OPERATIONAL VALIDATION QUERIES
-- DBeaver에서 실행하는 운영 검증 쿼리
-- =============================================
-- 이 섹션은 SQL 주석으로 보관
-- DBeaver에서 개별 선택 후 실행

/*
==============================================
  CATCHMENU 운영 검증 쿼리 모음
  DBeaver에서 개별 쿼리 선택 후 F5 실행
==============================================

-- =============================================
-- 1. 전체 스키마 테이블 현황
-- =============================================
SELECT
  table_schema,
  COUNT(*) as table_count
FROM information_schema.tables
WHERE table_schema LIKE 'catchmenu_%'
  AND table_type = 'BASE TABLE'
GROUP BY table_schema
ORDER BY table_schema;


-- =============================================
-- 2. RLS 적용 현황
-- =============================================
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled,
  -- force row security 확인
  c.relforcerowsecurity as rls_forced
FROM pg_tables t
JOIN pg_class c
  ON c.relname = t.tablename
JOIN pg_namespace n
  ON n.oid = c.relnamespace
  AND n.nspname = t.schemaname
WHERE t.schemaname LIKE 'catchmenu_%'
ORDER BY t.schemaname, t.tablename;


-- =============================================
-- 3. 등록된 RPC 함수 목록
-- =============================================
SELECT
  routine_schema,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema LIKE 'catchmenu_%'
  OR routine_schema = 'catchmenu_common'
ORDER BY routine_schema, routine_name;


-- =============================================
-- 4. 시드 데이터 확인
-- =============================================
SELECT
  'tenants' AS entity,
  COUNT(*) AS count
FROM catchmenu_hq.tenants
UNION ALL
SELECT 'stores', COUNT(*)
FROM catchmenu_hq.stores
UNION ALL
SELECT 'menus', COUNT(*)
FROM catchmenu_pos.menus
UNION ALL
SELECT 'devices', COUNT(*)
FROM catchmenu_store.device_registry
UNION ALL
SELECT 'agents', COUNT(*)
FROM catchmenu_store.agent_registry
UNION ALL
SELECT 'staff', COUNT(*)
FROM catchmenu_store.staff
UNION ALL
SELECT 'ingredients', COUNT(*)
FROM catchmenu_store.ingredients
UNION ALL
SELECT 'error_codes', COUNT(*)
FROM catchmenu_common.error_codes
UNION ALL
SELECT 'message_catalog', COUNT(*)
FROM catchmenu_common.message_catalog
UNION ALL
SELECT 'realtime_channels', COUNT(*)
FROM catchmenu_common.realtime_channels
UNION ALL
SELECT 'edge_functions', COUNT(*)
FROM catchmenu_common.edge_function_registry
UNION ALL
SELECT 'embedding_models', COUNT(*)
FROM catchmenu_knowledge.embedding_models
ORDER BY entity;


-- =============================================
-- 5. pg_cron 등록 현황
-- =============================================
SELECT
  j.job_code,
  j.pg_cron_job_name,
  j.schedule_cron_kst,
  j.is_registered,
  j.last_registered_at,
  cj.schedule AS registered_schedule,
  cj.active AS cron_active,
  cj.jobname AS cron_name
FROM catchmenu_common.pg_cron_jobs j
LEFT JOIN cron.job cj
  ON cj.jobname = j.pg_cron_job_name
ORDER BY j.job_code;


-- =============================================
-- 6. 최근 cron 실행 이력
-- =============================================
SELECT
  jrd.jobid,
  j.jobname,
  jrd.run_id,
  jrd.job_pid,
  jrd.database,
  jrd.start_time,
  jrd.end_time,
  EXTRACT(EPOCH FROM (
    jrd.end_time - jrd.start_time
  ))::int AS duration_seconds,
  jrd.status,
  jrd.return_message
FROM cron.job_run_details jrd
JOIN cron.job j ON j.jobid = jrd.jobid
ORDER BY jrd.start_time DESC
LIMIT 30;


-- =============================================
-- 7. 오늘 영업 현황 요약
-- (ULSAN_01 테스트 매장)
-- =============================================
SELECT *
FROM catchmenu_pos.get_daily_summary(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001',
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'
);


-- =============================================
-- 8. 결제 대사 현황
-- =============================================
SELECT
  pl.provider_type,
  pl.ledger_status,
  pl.reconciliation_status,
  COUNT(*) AS count,
  SUM(pl.net_amount) AS total_net
FROM catchmenu_payment.payment_ledger pl
WHERE pl.business_day = CURRENT_DATE
  AND pl.tenant_id =
    '00000000-0000-0000-0000-000000000001'
GROUP BY
  pl.provider_type,
  pl.ledger_status,
  pl.reconciliation_status
ORDER BY pl.ledger_status;


-- =============================================
-- 9. KDS 현재 상태
-- =============================================
SELECT
  kds_status,
  kitchen_zone,
  COUNT(*) AS ticket_count,
  AVG(
    EXTRACT(EPOCH FROM (
      NOW() - ticket_created_at
    )) / 60
  )::INT AS avg_wait_minutes
FROM catchmenu_kds.kds_tickets
WHERE business_day = CURRENT_DATE
  AND tenant_id =
    '00000000-0000-0000-0000-000000000001'
  AND kds_status NOT IN (
    'COMPLETED', 'CANCELLED', 'SERVED'
  )
GROUP BY kds_status, kitchen_zone
ORDER BY kds_status, kitchen_zone;


-- =============================================
-- 10. 미해결 Exception 목록
-- =============================================
SELECT
  exception_domain,
  exception_type,
  exception_severity,
  exception_status,
  error_message,
  occurrence_count,
  detected_at,
  requires_human_approval
FROM catchmenu_ledger.exceptions
WHERE business_day = CURRENT_DATE
  AND exception_status IN (
    'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
  )
ORDER BY
  CASE exception_severity
    WHEN 'FATAL' THEN 0
    WHEN 'CRITICAL' THEN 1
    WHEN 'ERROR' THEN 2
    WHEN 'WARNING' THEN 3
    ELSE 4
  END,
  detected_at DESC;


-- =============================================
-- 11. 감사 원장 무결성 빠른 확인
-- =============================================
SELECT
  COUNT(*) AS total_audit_records,
  COUNT(*) FILTER (
    WHERE recorded_at <> created_at
  ) AS modified_records,
  MAX(recorded_at) AS latest_audit,
  MIN(recorded_at) AS earliest_audit
FROM catchmenu_ledger.audit_records
WHERE business_day = CURRENT_DATE;


-- =============================================
-- 12. 진단 로그 최근 에러
-- =============================================
SELECT
  log_level,
  log_domain,
  log_event,
  error_code,
  error_key,
  message,
  recovery_hint,
  rpc_name,
  occurred_at
FROM catchmenu_common.diagnostic_logs
WHERE log_level IN ('ERROR', 'CRITICAL', 'FATAL')
  AND occurred_at > NOW() - INTERVAL '1 hour'
ORDER BY occurred_at DESC
LIMIT 20;


-- =============================================
-- 13. 메뉴 i18n 커버리지
-- =============================================
SELECT
  m.menu_code,
  m.menu_name AS ko_name,
  MAX(CASE WHEN mi.locale = 'en'
    THEN mi.menu_name END) AS en_name,
  MAX(CASE WHEN mi.locale = 'zh'
    THEN mi.menu_name END) AS zh_name,
  MAX(CASE WHEN mi.locale = 'ja'
    THEN mi.menu_name END) AS ja_name,
  m.menu_status
FROM catchmenu_pos.menus m
LEFT JOIN catchmenu_pos.menu_i18n mi
  ON mi.menu_id = m.id
WHERE m.store_id =
  '00000000-0000-0000-0000-000000000002'
  AND m.is_active = true
GROUP BY m.id, m.menu_code, m.menu_name,
         m.menu_status
ORDER BY m.display_order;


-- =============================================
-- 14. pgvector 임베딩 현황
-- =============================================
SELECT
  d.document_type,
  d.domain,
  COUNT(de.id) AS embedding_count,
  COUNT(de.id) FILTER (
    WHERE de.is_valid = true
  ) AS valid_count,
  COUNT(de.id) FILTER (
    WHERE de.is_valid = false
  ) AS invalid_count,
  AVG(de.chunk_char_count) AS avg_chunk_chars,
  MAX(de.embedded_at) AS last_embedded_at
FROM catchmenu_knowledge.document_embeddings de
JOIN catchmenu_knowledge.documents d
  ON d.id = de.document_id
GROUP BY d.document_type, d.domain
ORDER BY d.document_type, d.domain;


-- =============================================
-- 15. 보안 격리 빠른 검사
-- =============================================
SELECT
  'orders_cross_tenant' AS check_name,
  COUNT(*) AS violation_count
FROM catchmenu_pos.orders o
JOIN catchmenu_hq.stores s ON s.id = o.store_id
WHERE o.tenant_id <> s.tenant_id
UNION ALL
SELECT
  'payment_cross_tenant',
  COUNT(*)
FROM catchmenu_payment.payment_ledger pl
JOIN catchmenu_hq.stores s ON s.id = pl.store_id
WHERE pl.tenant_id <> s.tenant_id
UNION ALL
SELECT
  'untrusted_devices_online',
  COUNT(*)
FROM catchmenu_store.device_registry
WHERE trust_level IN ('UNTRUSTED', 'REVOKED')
  AND device_status = 'ONLINE'
UNION ALL
SELECT
  'uncertain_payment_with_cooking_kds',
  COUNT(*)
FROM catchmenu_payment.payment_intents pi
JOIN catchmenu_kds.kds_tickets kt
  ON kt.order_id = pi.order_id
WHERE pi.intent_status = 'UNCERTAIN'
  AND kt.kds_status = 'COOKING';


-- =============================================
-- 16. 알레르겐 미설정 메뉴 확인
-- =============================================
SELECT
  m.menu_code,
  m.menu_name,
  m.menu_status,
  COUNT(mal.id) AS allergen_link_count
FROM catchmenu_pos.menus m
LEFT JOIN catchmenu_pos.menu_allergen_links mal
  ON mal.menu_id = m.id
WHERE m.store_id =
  '00000000-0000-0000-0000-000000000002'
  AND m.is_active = true
  AND m.is_kds_required = true
GROUP BY m.id, m.menu_code, m.menu_name,
         m.menu_status
HAVING COUNT(mal.id) = 0
ORDER BY m.display_order;


-- =============================================
-- 17. 배치 실행 현황
-- =============================================
SELECT
  job_code,
  job_type,
  execution_status,
  started_at,
  duration_ms,
  records_processed,
  records_failed,
  target_business_day
FROM catchmenu_common.cron_job_executions
ORDER BY started_at DESC
LIMIT 30;


-- =============================================
-- 18. Edge Function 라우트 확인
-- =============================================
SELECT *
FROM catchmenu_common.get_edge_function_routes();


-- =============================================
-- 19. 격리 감사 실행
-- =============================================
SELECT *
FROM catchmenu_audit.run_isolation_audit(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001',
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'
);


-- =============================================
-- 20. 원장 Gap 탐지
-- =============================================
SELECT *
FROM catchmenu_ledger.reconcile_ledger_gaps(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001',
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'
);

*/


-- =============================================
-- Windows PowerShell 배포 가이드
-- SQL 주석으로 보관
-- =============================================
/*
==============================================
  Windows PowerShell 배포 명령어
  VSCode 터미널에서 실행
==============================================

# 1. Supabase CLI 설치 (최초 1회)
npm install -g supabase

# 2. 프로젝트 연결
cd D:\workspace\yoonsul_wait_order_handoff
supabase login
supabase link --project-ref YOUR_PROJECT_REF

# 3. 마이그레이션 실행 (DBeaver에서 수동 실행 권장)
# DBeaver → 연결 → sql/migrations/ 파일 순서대로 실행

# 4. Edge Functions 배포
supabase functions deploy toss-webhook
supabase functions deploy baemin-webhook
supabase functions deploy yogiyo-webhook
supabase functions deploy coupang-webhook
supabase functions deploy van-approval
supabase functions deploy kds-broadcast
supabase functions deploy did-broadcast
supabase functions deploy ai-chat
supabase functions deploy session-cleanup
supabase functions deploy daily-close

# 5. Edge Function 환경변수 설정
supabase secrets set `
  TOSS_WEBHOOK_SECRET=YOUR_SECRET `
  ANTHROPIC_API_KEY=YOUR_KEY `
  TENANT_ID=00000000-0000-0000-0000-000000000001 `
  STORE_ID=00000000-0000-0000-0000-000000000002

# 6. pg_cron 등록 (DBeaver에서 실행)
# SELECT * FROM catchmenu_common.register_all_pg_cron_jobs();

# 7. 검증
# SELECT * FROM cron.job ORDER BY jobid;
# SELECT * FROM cron.job_run_details
#   ORDER BY start_time DESC LIMIT 10;

# 8. 로컬 테스트 (Edge Function)
supabase functions serve toss-webhook --env-file .env.local

# 9. 함수 로그 확인
supabase functions logs toss-webhook --tail

# 10. DB 접속 (DBeaver 대안)
# supabase db connect

==============================================
  .env.local 파일 형식
  D:\workspace\yoonsul_wait_order_handoff\.env.local
==============================================
SUPABASE_URL=https://YOUR_REF.supabase.co
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_KEY
TOSS_WEBHOOK_SECRET=YOUR_TOSS_SECRET
ANTHROPIC_API_KEY=sk-ant-YOUR_KEY
TENANT_ID=00000000-0000-0000-0000-000000000001
STORE_ID=00000000-0000-0000-0000-000000000002
BAEMIN_WEBHOOK_SECRET=YOUR_BAEMIN_SECRET
YOGIYO_WEBHOOK_SECRET=YOUR_YOGIYO_SECRET
COUPANG_WEBHOOK_SECRET=YOUR_COUPANG_SECRET

==============================================
  Flutter pubspec.yaml 의존성
==============================================
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0
  intl: ^0.19.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_local_notifications: ^17.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.0

==============================================
  Flutter 디렉토리 구조
==============================================
lib/
  core/
    app_exception.dart
    rpc_handler.dart
    constants.dart
  services/
    bootstrap_service.dart
    realtime_service.dart
    heartbeat_service.dart
    edge_function_service.dart
  features/
    kds/
      kds_screen.dart
      kds_service.dart
      kds_provider.dart
    kiosk/
      kiosk_screen.dart
      menu_screen.dart
      order_screen.dart
      payment_screen.dart
    pos/
      pos_screen.dart
      table_screen.dart
      order_management_screen.dart
    did/
      did_screen.dart
      waiting_display.dart
    staff/
      staff_home_screen.dart
      waiting_queue_screen.dart
      exception_screen.dart
    ai_chat/
      ai_chat_screen.dart
      ai_chat_service.dart
  l10n/
    app_ko.arb
    app_en.arb
    app_zh.arb
    app_ja.arb

==============================================
  supabase/functions/ 디렉토리 구조
==============================================
supabase/
  functions/
    toss-webhook/
      index.ts
    baemin-webhook/
      index.ts
    yogiyo-webhook/
      index.ts
    coupang-webhook/
      index.ts
    van-approval/
      index.ts
    kds-broadcast/
      index.ts
    did-broadcast/
      index.ts
    ai-chat/
      index.ts
    session-cleanup/
      index.ts
    daily-close/
      index.ts
    _shared/
      supabase.ts
      cors.ts
      logger.ts
  migrations/
    [0001~0072 SQL files]
  config.toml

==============================================
  supabase/functions/_shared/logger.ts
==============================================
// Structured logging matching diagnostic_logs
export function log(
  level: 'DEBUG'|'INFO'|'WARNING'|'ERROR'|'CRITICAL',
  domain: string,
  event: string,
  message: string,
  details?: Record<string, unknown>
) {
  const entry = {
    level,
    domain,
    event,
    message,
    ...details,
    timestamp: new Date().toISOString(),
  };
  // grep-friendly format
  console.log(
    `[${level}] ${domain}.${event} | ${message}`,
    JSON.stringify(details ?? {})
  );
}

*/


-- =============================================
-- Final deployment checklist
-- =============================================
create table if not exists
  catchmenu_common.deployment_checklist (
  id uuid primary key default gen_random_uuid(),
  check_item text not null,
  check_category text not null,
  is_required boolean not null default true,
  check_status text not null default 'PENDING',
  check_notes text,
  checked_at timestamptz,
  checked_by text,
  created_at timestamptz not null default now()
);

insert into catchmenu_common.deployment_checklist (
  check_item, check_category, is_required, check_notes
) values
-- DB
('마이그레이션 0001~0072 실행 완료', 'DATABASE', true,
  'DBeaver에서 순서대로 실행'),
('시드 데이터 확인 (tenant/store/menu)', 'DATABASE', true,
  'Query #4 실행 확인'),
('RLS 전체 적용 확인', 'DATABASE', true,
  'Query #2 실행 — rls_enabled + rls_forced 모두 true'),
('pg_cron 등록', 'DATABASE', true,
  'SELECT * FROM catchmenu_common.register_all_pg_cron_jobs()'),
('pgvector extension 활성화', 'DATABASE', true,
  'CREATE EXTENSION IF NOT EXISTS vector'),
-- Edge Functions
('Edge Functions 배포 (10개)', 'EDGE_FUNCTION', true,
  'supabase functions deploy ...'),
('환경변수 설정', 'EDGE_FUNCTION', true,
  'supabase secrets set ...'),
('Toss 웹훅 URL 등록', 'INTEGRATION', true,
  'Toss Dashboard에서 웹훅 URL 설정'),
('배민/요기요/쿠팡 웹훅 URL 등록', 'INTEGRATION', false,
  '배달앱 연동 시 설정'),
-- Security
('보안 격리 검사 통과', 'SECURITY', true,
  'Query #15 실행 — 모든 violation_count = 0'),
('격리 감사 통과', 'SECURITY', true,
  'SELECT * FROM catchmenu_audit.run_isolation_audit(...)'),
-- Flutter
('Flutter pubspec.yaml 의존성 추가', 'FLUTTER', true,
  'supabase_flutter, riverpod 등'),
('Bootstrap RPC 연동 테스트', 'FLUTTER', true,
  'bootstrap_app() 호출 → 200 OK'),
('Realtime 구독 테스트', 'FLUTTER', true,
  'KDS 채널 구독 → 이벤트 수신 확인'),
('Heartbeat 30초 루프 동작 확인', 'FLUTTER', true,
  'heartbeat() 호출 → next_heartbeat_seconds 반환'),
-- Operations
('일일 마감 배치 테스트', 'OPERATIONS', true,
  'SELECT * FROM catchmenu_common.run_daily_close_batch(...)'),
('원장 무결성 검사 통과', 'OPERATIONS', true,
  'SELECT * FROM catchmenu_common.run_nightly_integrity_batch(...)'),
('메뉴 i18n 입력 (en 최소)', 'OPERATIONS', false,
  '외국인 고객 대응 시 필수'),
('알레르겐 정보 입력', 'OPERATIONS', true,
  '식품위생법 의무 — Query #16 확인'),
-- AI
('pgvector 임베딩 생성 (SOP 문서)', 'AI', false,
  'AI 고객센터 활성화 시 필요'),
('AI 고객센터 Edge Function 테스트', 'AI', false,
  'Phase 1 완료 후 진행')
on conflict do nothing;

comment on table
  catchmenu_common.deployment_checklist is
  'Deployment readiness checklist.
   배포 전 필수 확인 항목.

   진행 상황 확인:
   SELECT check_category, check_item,
     check_status, check_notes
   FROM catchmenu_common.deployment_checklist
   ORDER BY check_category, is_required DESC;

   완료 표시:
   UPDATE catchmenu_common.deployment_checklist
   SET check_status = ''DONE'',
     checked_at = now(),
     checked_by = ''your_name''
   WHERE check_item = ''...'';';


-- grants
do $$
begin
  grant select on catchmenu_common.pg_cron_jobs
    to authenticated;
  grant select on catchmenu_common.deployment_checklist
    to authenticated;

  revoke all on function
    catchmenu_common.register_all_pg_cron_jobs()
    from public;
  grant execute on function
    catchmenu_common.register_all_pg_cron_jobs()
    to authenticated;
end;
$$;