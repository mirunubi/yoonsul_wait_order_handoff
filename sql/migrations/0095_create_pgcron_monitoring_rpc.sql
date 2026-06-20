-- 0095_create_pgcron_monitoring_rpc.sql
-- Purpose: pg_cron schedule consolidation and
--          operational monitoring RPCs.
--          전체 pg_cron 스케줄 통합 정리.
--          운영 모니터링 대시보드.
--          SOP 런북 연결.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0094_fix_i18n_hardcoded_strings.sql
-- Creates:
--   catchmenu_common.operation_alerts (table)
--   catchmenu_common.pgcron_execution_log (table)
--   function catchmenu_common.get_operation_dashboard(...)
--   function catchmenu_common.get_pgcron_schedule(...)
--   function catchmenu_common.record_pgcron_execution(...)
--   function catchmenu_common.get_sop_runbook_map(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('operation_dashboard_loaded', 'ko',
  '운영 대시보드가 로드되었습니다'),
('operation_dashboard_loaded', 'en',
  'Operation dashboard loaded'),
('pgcron_schedule_loaded', 'ko',
  'pg_cron 스케줄이 로드되었습니다'),
('pgcron_schedule_loaded', 'en',
  'pg_cron schedule loaded'),
('pgcron_execution_recorded', 'ko',
  'pg_cron 실행이 기록되었습니다'),
('pgcron_execution_recorded', 'en',
  'pg_cron execution recorded'),
('runbook_map_loaded', 'ko',
  'SOP 런북 맵이 로드되었습니다'),
('runbook_map_loaded', 'en',
  'SOP runbook map loaded'),
('alert_created', 'ko',
  '운영 알림이 생성되었습니다'),
('alert_created', 'en',
  'Operation alert created'),
('alert_resolved', 'ko',
  '운영 알림이 해결되었습니다'),
('alert_resolved', 'en',
  'Operation alert resolved'),
('pgcron_job_overdue', 'ko',
  'pg_cron 작업이 예정 시간을 초과했습니다: {job_code}'),
('pgcron_job_overdue', 'en',
  'pg_cron job overdue: {job_code}'),
('pgcron_job_failed', 'ko',
  'pg_cron 작업이 실패했습니다: {job_code}'),
('pgcron_job_failed', 'en',
  'pg_cron job failed: {job_code}')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(3020, 'pgcron_job_not_found',
  'SYSTEM', 'NOT_FOUND', 404, 'WARNING'),
(3021, 'pgcron_job_failed',
  'SYSTEM', 'TECHNICAL', 500, 'ERROR'),
(3022, 'operation_alert_not_found',
  'SYSTEM', 'NOT_FOUND', 404, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- pg_cron 전체 스케줄 통합 완성
-- 0001~0094에서 분산 등록된 모든 job 확인 후
-- 누락분 추가
-- =============================================

insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values

-- 세션 정리 (15분마다)
(
  'SESSION_CLEANUP',
  'catchmenu_session_cleanup',
  '*/15 * * * *',
  '*/15 * * * * (15분마다)',
  $sql$
UPDATE catchmenu_pos.order_sessions
SET
  session_status = 'EXPIRED',
  updated_at = now()
WHERE session_status IN ('WAITING', 'ARRIVAL_PENDING')
  AND session_started_at
    < now() - INTERVAL '3 hours'
  AND business_day < (timezone('Asia/Seoul', now()))::date;
$sql$,
  '만료 대기 세션 정리. 15분마다.',
  true
),

-- 일일 마감 (KST 23:00)
(
  'DAILY_CLOSE',
  'catchmenu_daily_close',
  '0 14 * * *',
  '0 23 * * * (매일 23:00 KST)',
  $sql$
SELECT catchmenu_pos.close_business_day(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  '영업일 마감 처리. 매일 23:00 KST.',
  true
),

-- 포인트 만료 (KST 02:00)
(
  'POINT_EXPIRY',
  'catchmenu_point_expiry',
  '0 17 * * *',
  '0 2 * * * (매일 02:00 KST)',
  $sql$
UPDATE catchmenu_store.point_ledger
SET
  point_type = 'EXPIRE',
  updated_at = now()
WHERE point_type = 'EARN'
  AND expires_at IS NOT NULL
  AND expires_at < now()
  AND tenant_id =
    '00000000-0000-0000-0000-000000000001'::uuid;
$sql$,
  '만료 포인트 처리. 매일 02:00 KST.',
  true
),

-- 무결성 검사 (KST 01:00)
(
  'INTEGRITY_CHECK',
  'catchmenu_integrity_check',
  '0 16 * * *',
  '0 1 * * * (매일 01:00 KST)',
  $sql$
SELECT catchmenu_audit.run_integrity_check(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_check_date :=
    (timezone('Asia/Seoul', now()))::date - 1
);
$sql$,
  '전일 데이터 무결성 검사. 매일 01:00 KST.',
  true
),

-- knowledge gap 탐지 (KST 03:00)
(
  'KNOWLEDGE_GAP_DETECT',
  'catchmenu_knowledge_gap',
  '0 18 * * *',
  '0 3 * * * (매일 03:00 KST)',
  $sql$
SELECT catchmenu_knowledge.run_knowledge_gap_detection(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid
);
$sql$,
  'knowledge gap 탐지 + SOP 후보 생성. 매일 03:00 KST.',
  true
),

-- 정산 대사 Layer 1 (KST 23:30)
(
  'RECONCILIATION_LAYER1',
  'catchmenu_reconciliation',
  '30 14 * * *',
  '30 23 * * * (매일 23:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer1_reconciliation(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  'Layer 1 결제 대사. 매일 23:30 KST.',
  true
),

-- Layer 2 정산 대사 (KST 00:30)
(
  'RECONCILIATION_LAYER2',
  'catchmenu_reconciliation_l2',
  '30 15 * * *',
  '30 0 * * * (매일 00:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer2_reconciliation(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_pos_provider_code := 'OKPOS'
);
$sql$,
  'Layer 2 POS 대사. 매일 00:30 KST.',
  true
),

-- 보안 감사 (매주 월요일 04:00 KST)
(
  'WEEKLY_SECURITY_AUDIT',
  'catchmenu_security_audit',
  '0 19 * * 0',
  '0 4 * * 1 (매주 월요일 04:00 KST)',
  $sql$
SELECT catchmenu_common.run_security_audit(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_audit_depth := 'DEEP'
);
$sql$,
  '주간 보안 감사. 매주 월요일 04:00 KST.',
  true
),

-- 일일 사용량 기록 (KST 00:30)
(
  'DAILY_USAGE_RECORD',
  'catchmenu_daily_usage',
  '30 15 * * *',
  '30 0 * * * (매일 00:30 KST)',
  $sql$
SELECT catchmenu_common.record_usage(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  '일일 SaaS 사용량 집계. 매일 00:30 KST.',
  true
),

-- 배달 주문 폴링 (5분마다)
(
  'DELIVERY_POLL_BATCH',
  'catchmenu_delivery_poll',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
SELECT catchmenu_integrations
  .poll_pending_delivery_orders(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id :=
      '00000000-0000-0000-0000-000000000002'::uuid,
    p_max_age_minutes := 60
  );
$sql$,
  '미완료 배달 주문 폴링. 5분마다.',
  true
),

-- POS 헬스체크 (5분마다)
(
  'POS_HEALTH_CHECK',
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
  'POS 연결 상태 확인. 5분마다.',
  true
),

-- POS 메뉴 동기화 (2시간마다)
(
  'POS_MENU_SYNC',
  'catchmenu_pos_menu_sync',
  '0 */2 * * *',
  '0 */2 * * * (2시간마다)',
  $sql$
SELECT catchmenu_integrations.sync_pos_menu_item(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid
);
$sql$,
  'POS 메뉴 자동 동기화. 2시간마다.',
  true
),

-- DID 큐 정리 (1분마다)
(
  'DID_QUEUE_CLEANUP',
  'catchmenu_did_queue_cleanup',
  '*/1 * * * *',
  '*/1 * * * * (1분마다)',
  $sql$
UPDATE catchmenu_store.did_display_queue
SET
  queue_status = 'EXPIRED',
  dismissed_at = now(),
  dismissed_by_type = 'SYSTEM',
  updated_at = now()
WHERE queue_status = 'DISPLAYING'
  AND auto_dismiss_at < now();
$sql$,
  'DID 호출 만료 자동 해제. 1분마다.',
  true
),

-- 프로모션 상태 업데이트 (10분마다)
(
  'PROMOTION_STATUS_UPDATE',
  'catchmenu_promotion_status',
  '*/10 * * * *',
  '*/10 * * * * (10분마다)',
  $sql$
UPDATE catchmenu_store.promotions
SET promotion_status = 'ACTIVE', updated_at = now()
WHERE promotion_status = 'SCHEDULED'
  AND valid_from <= now()
  AND (valid_until IS NULL OR valid_until >= now());

UPDATE catchmenu_store.promotions
SET promotion_status = 'ENDED', updated_at = now()
WHERE promotion_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

UPDATE catchmenu_store.store_notices
SET notice_status = 'EXPIRED', updated_at = now()
WHERE notice_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  '프로모션/공지 상태 자동 전환. 10분마다.',
  true
),

-- 컴플라이언스 검사 (KST 02:00)
(
  'DAILY_COMPLIANCE_CHECK',
  'catchmenu_compliance_check',
  '0 17 * * *',
  '0 2 * * * (매일 02:00 KST)',
  $sql$
SELECT catchmenu_hq.detect_policy_violations(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_brand_id :=
    '00000000-0000-0000-0000-000000000010'::uuid
);
$sql$,
  '프랜차이즈 정책 준수 검사. 매일 02:00 KST.',
  true
),

-- 자동 에스컬레이션 (6시간마다)
(
  'AUTO_ESCALATION_CHECK',
  'catchmenu_auto_escalation',
  '0 */6 * * *',
  '0 */6 * * * (6시간마다)',
  $sql$
UPDATE catchmenu_hq.policy_violations
SET
  is_escalated = true,
  escalated_at = now(),
  escalation_level = 1,
  violation_status = 'ACKNOWLEDGED',
  updated_at = now()
WHERE violation_status = 'OPEN'
  AND violation_severity IN ('CRITICAL', 'FATAL')
  AND occurrence_count >= 3
  AND is_escalated = false;
$sql$,
  'CRITICAL 위반 자동 에스컬레이션. 6시간마다.',
  true
),

-- 반복 문의 탐지 (KST 04:00)
(
  'RECURRING_INQUIRY_DETECT',
  'catchmenu_recurring_inquiry',
  '0 19 * * *',
  '0 4 * * * (매일 04:00 KST)',
  $sql$
SELECT catchmenu_knowledge
  .detect_recurring_inquiries(
    p_tenant_id :=
      '00000000-0000-0000-0000-000000000001'::uuid,
    p_min_count := 3,
    p_period_days := 30
  );
$sql$,
  '반복 문의 패턴 탐지 + SOP 후보 생성. 매일 04:00 KST.',
  true
)

on conflict (job_code) do update set
  schedule_cron_utc = excluded.schedule_cron_utc,
  schedule_cron_kst = excluded.schedule_cron_kst,
  sql_command = excluded.sql_command,
  notes = excluded.notes,
  is_active = excluded.is_active;


-- =============================================
-- operation_alerts table
-- 운영 알림 (pg_cron 실패/지연 등)
-- =============================================
create table if not exists
  catchmenu_common.operation_alerts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 알림 정보
  alert_code text not null,
  alert_type text not null,
  alert_severity text not null default 'WARNING',
  alert_domain text not null,

  -- 내용
  alert_title text not null,
  alert_detail jsonb default '{}'::jsonb,

  -- 연결된 SOP
  sop_runbook_code text,
  sop_runbook_url text,

  -- 상태
  alert_status text not null default 'OPEN',
  acknowledged_at timestamptz,
  acknowledged_by uuid,
  resolved_at timestamptz,
  resolved_by uuid,
  resolution_note text,

  -- 자동 해결
  auto_resolve_at timestamptz,
  is_auto_resolved boolean not null default false,

  -- 반복
  occurrence_count int not null default 1,
  first_occurred_at timestamptz
    not null default now(),
  last_occurred_at timestamptz
    not null default now(),

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_alert_type check (
    alert_type in (
      'PGCRON_FAILED',
      'PGCRON_OVERDUE',
      'RECONCILIATION_GAP',
      'KDS_STUCK',
      'PAYMENT_FAILED',
      'SECURITY_VIOLATION',
      'QUOTA_EXCEEDED',
      'POS_DISCONNECTED',
      'DELIVERY_SYNC_FAILED',
      'AI_GROUNDING_LOW',
      'CUSTOM'
    )
  ),
  constraint chk_alert_severity check (
    alert_severity in (
      'INFO', 'WARNING', 'ERROR',
      'CRITICAL', 'FATAL'
    )
  ),
  constraint chk_alert_status check (
    alert_status in (
      'OPEN', 'ACKNOWLEDGED',
      'IN_PROGRESS', 'RESOLVED',
      'AUTO_RESOLVED', 'DISMISSED'
    )
  )
);

create index if not exists idx_alerts_tenant
  on catchmenu_common.operation_alerts(
    tenant_id, alert_status, alert_severity
  ) where alert_status in (
    'OPEN', 'ACKNOWLEDGED', 'IN_PROGRESS'
  );
create index if not exists idx_alerts_domain
  on catchmenu_common.operation_alerts(
    alert_domain, alert_type,
    last_occurred_at desc
  );

alter table catchmenu_common.operation_alerts
  enable row level security;
alter table catchmenu_common.operation_alerts
  force row level security;

drop policy if exists operation_alerts_isolation
  on catchmenu_common.operation_alerts;
create policy operation_alerts_isolation
  on catchmenu_common.operation_alerts
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_alerts_updated
  on catchmenu_common.operation_alerts;
create trigger trg_alerts_updated
  before update on catchmenu_common.operation_alerts
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.operation_alerts is
  '운영 알림 관리.
   pg_cron 실패/지연, 결제 이상, KDS 오류 등.
   sop_runbook_code: 연결된 SOP 런북.
   auto_resolve_at: 일정 시간 후 자동 해결.
   occurrence_count: 동일 알림 반복 횟수.
   특허4: 운영 알림 = 감사 추적 가능.';


-- =============================================
-- pgcron_execution_log table
-- pg_cron 실행 이력
-- =============================================
create table if not exists
  catchmenu_common.pgcron_execution_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- job 정보
  job_code text not null,
  pg_cron_job_name text,

  -- 실행 결과
  execution_status text
    not null default 'SUCCESS',
  execution_start timestamptz
    not null default now(),
  execution_end timestamptz,
  duration_ms int,

  -- 결과 상세
  rows_affected int,
  result_summary jsonb,
  error_message text,

  -- 다음 실행
  next_scheduled_at timestamptz,

  business_day date,
  created_at timestamptz not null default now(),

  constraint chk_execution_status check (
    execution_status in (
      'SUCCESS', 'FAILED',
      'PARTIAL', 'SKIPPED'
    )
  )
);

create index if not exists idx_pgcron_log_job
  on catchmenu_common.pgcron_execution_log(
    job_code, execution_start desc
  );
create index if not exists idx_pgcron_log_failed
  on catchmenu_common.pgcron_execution_log(
    execution_status, execution_start desc
  ) where execution_status = 'FAILED';
create index if not exists idx_pgcron_log_tenant
  on catchmenu_common.pgcron_execution_log(
    tenant_id, business_day desc
  );

alter table catchmenu_common.pgcron_execution_log
  enable row level security;
alter table catchmenu_common.pgcron_execution_log
  force row level security;

drop policy if exists pgcron_log_isolation
  on catchmenu_common.pgcron_execution_log;
create policy pgcron_log_isolation
  on catchmenu_common.pgcron_execution_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_common.pgcron_execution_log is
  'pg_cron 실행 이력.
   append-only 로그.
   FAILED → operation_alerts 자동 생성.
   duration_ms: 실행 시간 추적.
   특허4: pg_cron = 감사 추적 가능.';


-- =============================================
-- SOP 런북 맵 시드
-- error_codes.sop_runbook_code 연결
-- =============================================
create table if not exists
  catchmenu_common.sop_runbooks (
  id uuid primary key default gen_random_uuid(),
  runbook_code text not null unique,
  runbook_name text not null,
  runbook_domain text not null,
  runbook_severity text not null default 'WARNING',

  -- 증상 설명
  symptom_description text not null,
  symptom_i18n jsonb default '{}'::jsonb,

  -- 조치 절차
  recovery_steps jsonb not null
    default '[]'::jsonb,
  recovery_steps_i18n jsonb
    default '{}'::jsonb,

  -- 연결 정보
  related_error_codes jsonb default '[]'::jsonb,
  related_alert_types jsonb default '[]'::jsonb,
  related_document_code text,

  -- 에스컬레이션
  escalation_contact text,
  escalation_threshold_minutes int
    default 30,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_runbook_severity check (
    runbook_severity in (
      'INFO', 'WARNING', 'ERROR',
      'CRITICAL', 'FATAL'
    )
  )
);

drop trigger if exists trg_runbooks_updated
  on catchmenu_common.sop_runbooks;
create trigger trg_runbooks_updated
  before update on catchmenu_common.sop_runbooks
  for each row execute function
    catchmenu_common.set_updated_at();

-- SOP 런북 시드
insert into catchmenu_common.sop_runbooks (
  runbook_code, runbook_name, runbook_domain,
  runbook_severity,
  symptom_description,
  recovery_steps,
  related_error_codes,
  related_alert_types,
  escalation_threshold_minutes
) values

-- KDS 과부하
(
  'SOP-KDS-001',
  'KDS 과부하 대응',
  'KDS', 'WARNING',
  'KDS active ticket 수가 임계치를 초과. '
  || '신규 주문 자동 차단 상태.',
  '[
    "1. get_kds_state() 호출하여 현재 상태 확인",
    "2. COOKING 상태 티켓 중 오래된 항목 확인",
    "3. 조리 완료 항목 SERVED 처리",
    "4. 필요시 kds_capacity_threshold_total 임시 상향",
    "5. 주방 직원 추가 투입 또는 주문 일시 중단",
    "6. 정상화 후 store_mode 확인"
  ]'::jsonb,
  '[2009]'::jsonb,
  '["KDS_STUCK", "PGCRON_FAILED"]'::jsonb,
  15
),

-- 결제 실패
(
  'SOP-PAY-001',
  '결제 실패 대응',
  'PAYMENT', 'ERROR',
  'PG/VAN 결제 승인 실패 또는 오류.',
  '[
    "1. payment_ledger에서 실패 건 확인",
    "2. PG사 오류 코드 확인 (provider_response)",
    "3. 네트워크 연결 상태 확인",
    "4. 고객에게 재시도 안내",
    "5. 3회 이상 실패 시 다른 결제 수단 안내",
    "6. PG사 장애 시 VAN 단말기 직접 결제",
    "7. 장애 내용 운영 일지 기록"
  ]'::jsonb,
  '[4003, 4013]'::jsonb,
  '["PAYMENT_FAILED"]'::jsonb,
  10
),

-- 결제 환불 실패
(
  'SOP-PAY-002',
  '결제 환불 실패 대응',
  'PAYMENT', 'ERROR',
  '승인 취소/환불 요청 실패.',
  '[
    "1. 원 승인 정보 확인 (approval_number)",
    "2. PG사 관리자 페이지에서 취소 가능 여부 확인",
    "3. 당일 23:59까지 PG사 포털에서 수동 취소",
    "4. 익일 이후는 PG사 고객센터 연락",
    "5. 고객에게 환불 처리 기간 안내",
    "6. reconciliation_cases에 수동 기록"
  ]'::jsonb,
  '[4005, 4006]'::jsonb,
  '["PAYMENT_FAILED"]'::jsonb,
  30
),

-- 정산 대사 불일치
(
  'SOP-PAY-003',
  '정산 대사 불일치 대응',
  'PAYMENT', 'CRITICAL',
  'Layer 2/3 대사에서 불일치 감지.',
  '[
    "1. get_reconciliation_report() 호출하여 Gap 확인",
    "2. missing_in_internal vs missing_in_pos 비교",
    "3. POS 원장과 payment_ledger 개별 비교",
    "4. 금액 차이 원인 분석 (취소/환불/수수료)",
    "5. resolve_reconciliation_gap() 호출하여 해결",
    "6. WRITE_OFF 처리 시 경영진 승인 필수",
    "7. 동일 Gap 반복 시 POS 연동 점검"
  ]'::jsonb,
  '[4007]'::jsonb,
  '["RECONCILIATION_GAP"]'::jsonb,
  60
),

-- POS 연결 실패
(
  'SOP-POS-001',
  'POS 연결 실패 대응',
  'POS', 'ERROR',
  'OKpos 또는 토스POS 연결 실패.',
  '[
    "1. get_pos_health() 호출하여 상태 확인",
    "2. POS 단말기 재시작",
    "3. 네트워크 연결 확인 (LAN/Wi-Fi)",
    "4. POS 서버 상태 확인 (공지 채널)",
    "5. 재연결 실패 시 현금/수기 영수증 전환",
    "6. sync_pos_menu_item() 재실행",
    "7. 복구 후 누락 주문 manual reconcile"
  ]'::jsonb,
  '[4012]'::jsonb,
  '["POS_DISCONNECTED"]'::jsonb,
  20
),

-- 보안 위반
(
  'SOP-SEC-001',
  '미등록 디바이스 접근 시도',
  'SECURITY', 'WARNING',
  '등록되지 않은 디바이스의 접근 시도.',
  '[
    "1. security_audit_log에서 접근 시도 IP 확인",
    "2. device_registry에서 해당 디바이스 확인",
    "3. 정상적인 신규 디바이스이면 register_device()",
    "4. 비정상 접근이면 IP 차단 및 경고",
    "5. isolate_tenant() 필요 시 발동",
    "6. 사건 내용 audit_record에 기록"
  ]'::jsonb,
  '[1005, 1006]'::jsonb,
  '["SECURITY_VIOLATION"]'::jsonb,
  30
),

-- 디바이스 차단
(
  'SOP-SEC-002',
  '디바이스 차단 대응',
  'SECURITY', 'CRITICAL',
  '반복 위반으로 디바이스 차단 상태.',
  '[
    "1. security_audit_log에서 위반 이력 확인",
    "2. 정상 디바이스 확인 후 trust_level 복구",
    "3. 비정상 디바이스면 차단 유지",
    "4. isolate_tenant() 고려",
    "5. 보안 침해 확인 시 PG사 및 관계기관 신고"
  ]'::jsonb,
  '[1007]'::jsonb,
  '["SECURITY_VIOLATION"]'::jsonb,
  10
),

-- 테넌트 정지
(
  'SOP-SEC-003',
  '테넌트 정지 대응',
  'SECURITY', 'CRITICAL',
  '테넌트 계정 정지 상태.',
  '[
    "1. tenant_status 정지 사유 확인",
    "2. 미결제 구독료 확인",
    "3. 보안 위반 여부 확인",
    "4. 사유 해소 후 isolate_tenant(false) 복구",
    "5. 고객사 담당자에게 상황 통보"
  ]'::jsonb,
  '[1010]'::jsonb,
  '["SECURITY_VIOLATION"]'::jsonb,
  60
),

-- 웹훅 서명 오류
(
  'SOP-SEC-004',
  '웹훅 서명 검증 실패',
  'SECURITY', 'CRITICAL',
  '배달앱/PG 웹훅 서명 검증 실패.',
  '[
    "1. 웹훅 요청 헤더 서명 확인",
    "2. 배달앱/PG 비밀 키 만료 여부 확인",
    "3. 키 갱신 후 Edge Function 환경변수 업데이트",
    "4. 정상 웹훅이면 재전송 요청",
    "5. 공격 의심 시 IP 차단 + 보안팀 알림"
  ]'::jsonb,
  '[9005]'::jsonb,
  '["SECURITY_VIOLATION"]'::jsonb,
  15
),

-- 시스템 오류
(
  'SOP-SYS-001',
  '시스템 오류 대응',
  'SYSTEM', 'ERROR',
  '내부 서버 오류 또는 DB 오류.',
  '[
    "1. health_check() 호출하여 컴포넌트 확인",
    "2. diagnostic_logs에서 ERROR 로그 확인",
    "3. Supabase 대시보드에서 DB 상태 확인",
    "4. Edge Function 로그 확인",
    "5. 오류 재현 여부 확인",
    "6. Supabase 지원팀 티켓 생성"
  ]'::jsonb,
  '[3001, 3002]'::jsonb,
  '["PGCRON_FAILED"]'::jsonb,
  30
),

-- 외부 서비스 장애
(
  'SOP-SYS-002',
  '외부 서비스 장애 대응',
  'SYSTEM', 'ERROR',
  'FCM/PG/배달앱 외부 서비스 장애.',
  '[
    "1. 해당 외부 서비스 상태 페이지 확인",
    "2. 장애 예상 복구 시간 확인",
    "3. 대체 수단 전환 (예: VAN 단말기)",
    "4. 고객 안내 공지 등록",
    "5. 복구 후 누락 데이터 재동기화"
  ]'::jsonb,
  '[3003, 3004]'::jsonb,
  '["POS_DISCONNECTED", "DELIVERY_SYNC_FAILED"]'::jsonb,
  20
),

-- 식품안전 알레르겐
(
  'SOP-FOOD-001',
  '알레르겐 미선언 대응',
  'COMPLIANCE', 'CRITICAL',
  '메뉴 알레르겐 정보 미선언 (식품위생법 위반).',
  '[
    "1. 해당 메뉴 즉시 SOLD_OUT 처리",
    "2. 알레르겐 정보 확인 및 등록",
    "3. update_menu_allergens() 호출",
    "4. 알레르겐 등록 완료 후 AVAILABLE 복구",
    "5. 법무팀 보고 (위반 기간 산정)",
    "6. 감사 증빙 패킷 생성"
  ]'::jsonb,
  '[5003]'::jsonb,
  '["CUSTOM"]'::jsonb,
  5
),

-- 재고 부족
(
  'SOP-INV-001',
  '재고 부족 대응',
  'INVENTORY', 'WARNING',
  '식재료 재고 임계치 이하.',
  '[
    "1. get_stock_alerts() 호출하여 부족 품목 확인",
    "2. 해당 메뉴 SOLD_OUT 또는 수량 제한",
    "3. 발주 또는 다지점 재고 이동 요청",
    "4. request_stock_transfer() 호출",
    "5. 입고 완료 후 재고 수량 업데이트",
    "6. 반복 부족 시 발주 기준량 조정"
  ]'::jsonb,
  '[5004]'::jsonb,
  '["CUSTOM"]'::jsonb,
  60
),

-- 감사 증빙 불완전
(
  'SOP-AUD-001',
  '감사 증빙 불완전 대응',
  'AUDIT', 'CRITICAL',
  '필수 감사 이벤트 누락 또는 증빙 불완전.',
  '[
    "1. audit_records에서 누락 항목 확인",
    "2. ledger.events에서 관련 이벤트 조회",
    "3. 수동 보정 가능 여부 판단",
    "4. 보정 불가 시 incident_report 생성",
    "5. 법무팀 및 회계팀 보고",
    "6. 향후 재발 방지 SOP 수정"
  ]'::jsonb,
  '[10002, 10003]'::jsonb,
  '["CUSTOM"]'::jsonb,
  60
),

-- 배달 동기화 실패
(
  'SOP-DEL-001',
  '배달앱 동기화 실패 대응',
  'DELIVERY', 'ERROR',
  '배달앱 주문 상태 동기화 실패.',
  '[
    "1. poll_pending_delivery_orders() 호출",
    "2. failed_syncs 목록 확인",
    "3. 배달앱 대시보드에서 주문 상태 직접 확인",
    "4. sync_delivery_order_status() 수동 재실행",
    "5. 배달앱 API 키 만료 여부 확인",
    "6. 반복 실패 시 배달앱 고객센터 연락"
  ]'::jsonb,
  '[9001, 9004]'::jsonb,
  '["DELIVERY_SYNC_FAILED"]'::jsonb,
  15
)

on conflict (runbook_code) do update set
  runbook_name = excluded.runbook_name,
  recovery_steps = excluded.recovery_steps,
  is_active = true;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.get_pgcron_schedule(
  p_domain text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_jobs jsonb;
  v_schedule_summary jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'job_code', job_code,
        'pg_cron_job_name', pg_cron_job_name,
        'schedule_cron_utc', schedule_cron_utc,
        'schedule_cron_kst', schedule_cron_kst,
        'notes', notes,
        'is_active', is_active,
        'created_at', created_at
      )
      order by schedule_cron_utc, job_code
    ),
    '[]'::jsonb
  )
  into v_jobs
  from catchmenu_common.pg_cron_jobs
  where is_active = true
    and (
      p_domain is null
      or job_code like '%' || p_domain || '%'
    );

  -- 빈도별 요약
  select jsonb_build_object(
    'total_jobs', count(*),
    'per_minute', count(*) filter (
      where schedule_cron_utc like '*/1 %'
    ),
    'per_5_minutes', count(*) filter (
      where schedule_cron_utc like '*/5 %'
    ),
    'per_10_minutes', count(*) filter (
      where schedule_cron_utc like '*/10 %'
    ),
    'per_15_minutes', count(*) filter (
      where schedule_cron_utc like '*/15 %'
    ),
    'hourly', count(*) filter (
      where schedule_cron_utc like '0 * %'
        or schedule_cron_utc like '0 */% %'
    ),
    'daily', count(*) filter (
      where schedule_cron_utc like '% * * *'
        and schedule_cron_utc
          not like '*/% * * * *'
    ),
    'weekly', count(*) filter (
      where schedule_cron_utc like '% * * %'
        and schedule_cron_utc
          not like '% * * *'
    )
  )
  into v_schedule_summary
  from catchmenu_common.pg_cron_jobs
  where is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'pgcron_schedule_loaded',
    p_data := jsonb_build_object(
      'domain_filter', p_domain,
      'jobs', v_jobs,
      'summary', v_schedule_summary,
      'kst_note',
        'KST = UTC + 9시간. '
        || 'schedule_cron_kst 참고.',
      'apply_note',
        'Supabase pg_cron 설정 필요. '
        || 'Dashboard → Database → pg_cron'
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_common.record_pgcron_execution(
  p_tenant_id uuid,
  p_job_code text,
  p_execution_status text,
  p_duration_ms int default null,
  p_rows_affected int default null,
  p_result_summary jsonb default null,
  p_error_message text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_log_id uuid;
  v_job record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select job_code, pg_cron_job_name
  into v_job
  from catchmenu_common.pg_cron_jobs
  where job_code = p_job_code;

  insert into
    catchmenu_common.pgcron_execution_log (
    tenant_id, job_code, pg_cron_job_name,
    execution_status,
    execution_start, execution_end,
    duration_ms, rows_affected,
    result_summary, error_message,
    business_day
  ) values (
    p_tenant_id, p_job_code,
    v_job.pg_cron_job_name,
    p_execution_status,
    now() - (
      coalesce(p_duration_ms, 0)
        || ' milliseconds'
    )::interval,
    now(),
    p_duration_ms, p_rows_affected,
    p_result_summary, p_error_message,
    v_business_day
  )
  returning id into v_log_id;

  -- 실패 시 운영 알림 생성
  if p_execution_status = 'FAILED' then
    insert into catchmenu_common.operation_alerts (
      tenant_id, alert_code, alert_type,
      alert_severity, alert_domain,
      alert_title, alert_detail,
      sop_runbook_code,
      alert_status, business_day
    ) values (
      p_tenant_id,
      'PGCRON_FAILED_' || p_job_code,
      'PGCRON_FAILED', 'ERROR',
      'SYSTEM',
      catchmenu_common.get_message(
        'pgcron_job_failed', 'ko',
        jsonb_build_object('job_code', p_job_code)
      ),
      jsonb_build_object(
        'job_code', p_job_code,
        'error_message', p_error_message,
        'duration_ms', p_duration_ms,
        'log_id', v_log_id
      ),
      'SOP-SYS-001',
      'OPEN', v_business_day
    )
    on conflict do nothing;

    -- 진단 로그
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_log_level := 'ERROR',
      p_log_domain := 'SYSTEM',
      p_log_event := 'pgcron_job_failed',
      p_message :=
        'pg_cron 작업 실패: ' || p_job_code
        || ' | ' || coalesce(p_error_message, ''),
      p_rpc_name := 'record_pgcron_execution',
      p_details := jsonb_build_object(
        'job_code', p_job_code,
        'error', p_error_message,
        'log_id', v_log_id
      )
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'pgcron_execution_recorded',
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'job_code', p_job_code,
      'execution_status', p_execution_status,
      'alert_created',
        p_execution_status = 'FAILED'
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_common.get_sop_runbook_map(
  p_domain text default null,
  p_severity text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_runbooks jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'runbook_code', runbook_code,
        'runbook_name', runbook_name,
        'runbook_domain', runbook_domain,
        'runbook_severity', runbook_severity,
        'symptom_description',
          symptom_description,
        'recovery_steps', recovery_steps,
        'related_error_codes',
          related_error_codes,
        'related_alert_types',
          related_alert_types,
        'escalation_threshold_minutes',
          escalation_threshold_minutes
      )
      order by runbook_domain, runbook_code
    ),
    '[]'::jsonb
  )
  into v_runbooks
  from catchmenu_common.sop_runbooks
  where is_active = true
    and (
      p_domain is null
      or runbook_domain = p_domain
    )
    and (
      p_severity is null
      or runbook_severity = p_severity
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'runbook_map_loaded',
    p_data := jsonb_build_object(
      'domain_filter', p_domain,
      'severity_filter', p_severity,
      'total_runbooks',
        jsonb_array_length(v_runbooks),
      'runbooks', v_runbooks,
      'by_domain', (
        select coalesce(
          jsonb_object_agg(
            runbook_domain, cnt
          ),
          '{}'::jsonb
        )
        from (
          select runbook_domain,
                 count(*)::int as cnt
          from catchmenu_common.sop_runbooks
          where is_active = true
            and (
              p_domain is null
              or runbook_domain = p_domain
            )
          group by runbook_domain
        ) d
      )
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_common.get_operation_dashboard(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_hq
as $$
declare
  v_open_alerts jsonb;
  v_pgcron_summary jsonb;
  v_health jsonb;
  v_today_summary jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 미해결 운영 알림
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'alert_id', id,
        'alert_code', alert_code,
        'alert_type', alert_type,
        'alert_severity', alert_severity,
        'alert_domain', alert_domain,
        'alert_title', alert_title,
        'sop_runbook_code', sop_runbook_code,
        'occurrence_count', occurrence_count,
        'last_occurred_at', last_occurred_at,
        'alert_status', alert_status
      )
      order by
        case alert_severity
          when 'FATAL' then 0
          when 'CRITICAL' then 1
          when 'ERROR' then 2
          when 'WARNING' then 3
          else 4
        end,
        last_occurred_at desc
    ),
    '[]'::jsonb
  )
  into v_open_alerts
  from catchmenu_common.operation_alerts
  where tenant_id = p_tenant_id
    and alert_status in (
      'OPEN', 'ACKNOWLEDGED', 'IN_PROGRESS'
    )
    and (
      p_store_id is null
      or store_id = p_store_id
      or store_id is null
    );

  -- pg_cron 최근 실행 현황
  select jsonb_build_object(
    'total_executions_today', count(*),
    'success_count', count(*) filter (
      where execution_status = 'SUCCESS'
    ),
    'failed_count', count(*) filter (
      where execution_status = 'FAILED'
    ),
    'recent_failures', coalesce(
      jsonb_agg(
        jsonb_build_object(
          'job_code', job_code,
          'error_message', error_message,
          'execution_start', execution_start
        )
        order by execution_start desc
      ) filter (
        where execution_status = 'FAILED'
      ),
      '[]'::jsonb
    )
  )
  into v_pgcron_summary
  from catchmenu_common.pgcron_execution_log
  where tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 헬스 체크
  v_health := catchmenu_common.health_check(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id
  );

  -- 오늘 운영 요약
  if p_store_id is not null then
    select jsonb_build_object(
      'total_orders', count(*) filter (
        where order_status not in (
          'CANCELLED'
        )
      ),
      'completed_orders', count(*) filter (
        where order_status = 'COMPLETED'
      ),
      'cancelled_orders', count(*) filter (
        where order_status = 'CANCELLED'
      ),
      'takeout_orders', count(*) filter (
        where order_type = 'TAKEOUT'
      ),
      'delivery_orders', count(*) filter (
        where order_type = 'DELIVERY'
      ),
      'active_waiting', (
        select count(*)
        from catchmenu_pos.order_sessions
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and business_day = v_business_day
          and session_status in (
            'WAITING', 'ARRIVAL_PENDING'
          )
      ),
      'kds_active_tickets', (
        select count(*)
        from catchmenu_kds.kds_tickets
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and business_day = v_business_day
          and kds_status in (
            'HOLD', 'COOKING', 'COMMITTED'
          )
      )
    )
    into v_today_summary
    from catchmenu_pos.orders
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'operation_dashboard_loaded',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'business_day', v_business_day,
      'overall_health',
        v_health->'data'->>'overall',
      'health_components',
        v_health->'data'->'components',
      'open_alerts', v_open_alerts,
      'alert_count',
        jsonb_array_length(v_open_alerts),
      'critical_alert_count', (
        select count(*)
        from jsonb_array_elements(v_open_alerts) a
        where a->>'alert_severity'
          in ('CRITICAL', 'FATAL')
      ),
      'pgcron', v_pgcron_summary,
      'today', v_today_summary,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.create_operation_alert(
  p_tenant_id uuid,
  p_alert_type text,
  p_alert_severity text,
  p_alert_domain text,
  p_alert_title_key text,
  p_alert_detail jsonb default null,
  p_store_id uuid default null,
  p_sop_runbook_code text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_alert_id uuid;
  v_business_day date;
  v_runbook_code text;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- SOP 런북 자동 조회
  if p_sop_runbook_code is null then
    select runbook_code
    into v_runbook_code
    from catchmenu_common.sop_runbooks
    where p_alert_type = any(
      select jsonb_array_elements_text(
        related_alert_types
      )
    )
    and runbook_severity in (
      p_alert_severity,
      case p_alert_severity
        when 'FATAL' then 'CRITICAL'
        when 'CRITICAL' then 'ERROR'
        else 'WARNING'
      end
    )
    and is_active = true
    order by runbook_severity desc
    limit 1;
  else
    v_runbook_code := p_sop_runbook_code;
  end if;

  insert into catchmenu_common.operation_alerts (
    tenant_id, store_id,
    alert_code, alert_type,
    alert_severity, alert_domain,
    alert_title, alert_detail,
    sop_runbook_code,
    alert_status, business_day
  ) values (
    p_tenant_id, p_store_id,
    p_alert_type || '_' ||
      to_char(now(), 'YYYYMMDDHH24MISS'),
    p_alert_type,
    p_alert_severity, p_alert_domain,
    catchmenu_common.get_message(
      p_alert_title_key, p_locale, null
    ),
    coalesce(p_alert_detail, '{}'::jsonb),
    v_runbook_code,
    'OPEN', v_business_day
  )
  returning id into v_alert_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'alert_created',
    p_data := jsonb_build_object(
      'alert_id', v_alert_id,
      'alert_type', p_alert_type,
      'alert_severity', p_alert_severity,
      'sop_runbook_code', v_runbook_code
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.resolve_operation_alert(
  p_tenant_id uuid,
  p_alert_id uuid,
  p_resolution_note text,
  p_resolved_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_alert record;
begin
  select id, alert_type, alert_status,
         alert_severity
  into v_alert
  from catchmenu_common.operation_alerts
  where id = p_alert_id
    and tenant_id = p_tenant_id
  for update;

  if v_alert.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'operation_alert_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'resolve_operation_alert'
    );
  end if;

  update catchmenu_common.operation_alerts
  set
    alert_status = 'RESOLVED',
    resolved_at = now(),
    resolved_by = p_resolved_by,
    resolution_note = p_resolution_note,
    updated_at = now()
  where id = p_alert_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'alert_resolved',
    p_data := jsonb_build_object(
      'alert_id', p_alert_id,
      'alert_type', v_alert.alert_type,
      'resolved_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.get_pgcron_schedule(text)
    from public;
  grant execute on function
    catchmenu_common.get_pgcron_schedule(text)
    to authenticated;

  revoke all on function
    catchmenu_common.record_pgcron_execution(
      uuid, text, text, int, int, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_common.record_pgcron_execution(
      uuid, text, text, int, int, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_sop_runbook_map(
      text, text
    ) from public;
  grant execute on function
    catchmenu_common.get_sop_runbook_map(
      text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_operation_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.get_operation_dashboard(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.create_operation_alert(
      uuid, text, text, text, text,
      jsonb, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.create_operation_alert(
      uuid, text, text, text, text,
      jsonb, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.resolve_operation_alert(
      uuid, uuid, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.resolve_operation_alert(
      uuid, uuid, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.get_operation_dashboard(
    uuid, uuid, text
  ) is
  '운영 통합 대시보드.
   포함 데이터:
   - 전체 헬스 상태 (HEALTHY/DEGRADED/DOWN)
   - 미해결 운영 알림 (심각도 순)
   - pg_cron 오늘 실행 현황
   - 오늘 주문/대기/KDS 요약
   CRITICAL/FATAL 알림 → SOP 런북 연결.
   Flutter 직원 앱 홈 화면 상단 표시.
   1호점 운영 핵심 모니터링 도구.';

comment on table catchmenu_common.sop_runbooks is
  'SOP 런북 레지스트리.
   에러 코드 → 런북 코드 → 조치 절차 연결.
   error_codes.sop_runbook_code 참조.
   operation_alerts.sop_runbook_code 참조.
   diagnostic_logs 에러 발생 시 자동 런북 제안.
   grep-friendly: runbook_code로 검색.

   등록된 런북 (14개):
   SOP-KDS-001: KDS 과부하
   SOP-PAY-001: 결제 실패
   SOP-PAY-002: 환불 실패
   SOP-PAY-003: 정산 대사 불일치
   SOP-POS-001: POS 연결 실패
   SOP-SEC-001: 미등록 디바이스
   SOP-SEC-002: 디바이스 차단
   SOP-SEC-003: 테넌트 정지
   SOP-SEC-004: 웹훅 서명 오류
   SOP-SYS-001: 시스템 오류
   SOP-SYS-002: 외부 서비스 장애
   SOP-FOOD-001: 알레르겐 미선언
   SOP-INV-001: 재고 부족
   SOP-AUD-001: 감사 증빙 불완전
   SOP-DEL-001: 배달 동기화 실패';