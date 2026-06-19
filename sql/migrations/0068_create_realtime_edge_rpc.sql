-- 0068_create_realtime_edge_rpc.sql
-- Purpose: Supabase Realtime channel management and
--          Edge Function integration RPCs.
--          Flutter app realtime subscription config.
--          Edge Function webhook routing table.
--          Firebase migration boundary definitions.
--          특허1: 실시간 고객 안내 채널 관리.
--          특허3: AI 고객센터 Firebase 마이그레이션 경계.
-- Depends on: 0067_create_cron_scheduler_rpc.sql
-- Creates:
--   catchmenu_common.realtime_channels (table)
--   catchmenu_common.edge_function_registry (table)
--   catchmenu_common.firebase_migration_boundary (table)
--   function catchmenu_common.get_realtime_config(...)
--   function catchmenu_common.notify_channel(...)
--   function catchmenu_common.get_edge_function_routes(...)
--   function catchmenu_common.register_firebase_boundary(...)

-- =============================================
-- realtime_channels table
-- Flutter Supabase Realtime 구독 채널 관리
-- =============================================
create table if not exists
  catchmenu_common.realtime_channels (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  channel_code text not null,
  channel_name text not null,
  channel_type text not null,

  -- Supabase Realtime config
  -- Postgres Changes / Broadcast / Presence
  realtime_type text not null
    default 'POSTGRES_CHANGES',

  -- table subscription config
  schema_name text,
  table_name text,
  filter_column text,
  filter_value text,
  events jsonb default
    '["INSERT","UPDATE","DELETE"]'::jsonb,

  -- Flutter channel name pattern
  -- e.g. store:{store_id}:kds
  channel_pattern text not null,

  -- access control
  allowed_roles jsonb default
    '["authenticated"]'::jsonb,
  requires_store_match boolean
    not null default true,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_channel_code unique (
    tenant_id, channel_code
  ),
  constraint chk_channel_type check (
    channel_type in (
      'KDS_TICKETS', 'ORDER_SESSIONS',
      'WAITING_QUEUE', 'PAYMENT_STATUS',
      'DID_DISPLAY', 'STAFF_ALERTS',
      'MENU_STATUS', 'STORE_MODE',
      'KDS_EVENTS', 'AI_CHAT',
      'SYSTEM_ALERTS'
    )
  ),
  constraint chk_realtime_type check (
    realtime_type in (
      'POSTGRES_CHANGES',
      'BROADCAST',
      'PRESENCE'
    )
  )
);

create index if not exists idx_realtime_store
  on catchmenu_common.realtime_channels(
    store_id, channel_type
  ) where is_active = true;

alter table catchmenu_common.realtime_channels
  enable row level security;
alter table catchmenu_common.realtime_channels
  force row level security;

drop policy if exists realtime_channels_isolation
  on catchmenu_common.realtime_channels;
create policy realtime_channels_isolation
  on catchmenu_common.realtime_channels
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_realtime_channels_updated
  on catchmenu_common.realtime_channels;
create trigger trg_realtime_channels_updated
  before update on catchmenu_common.realtime_channels
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.realtime_channels is
  'Supabase Realtime channel registry.
   Flutter app subscribes using channel_pattern.
   POSTGRES_CHANGES: table row change events.
   BROADCAST: manual push via notify_channel().
   PRESENCE: device/staff online presence tracking.

   Flutter 구독 예시:
   supabase.channel("store:$storeId:kds")
     .on(RealtimeListenTypes.postgresChanges, ...)
     .subscribe()

   특허1: 실시간 KDS/DID/대기열 상태 Push.
   특허2: KDS 상태 변경 = Flutter KDS 화면 즉시 반영.';


-- seed default channels
insert into catchmenu_common.realtime_channels (
  tenant_id,
  channel_code, channel_name, channel_type,
  realtime_type,
  schema_name, table_name, filter_column,
  events, channel_pattern
)
select
  t.id,
  channel_data.code,
  channel_data.name,
  channel_data.ctype,
  channel_data.rtype,
  channel_data.schema_n,
  channel_data.table_n,
  channel_data.filter_col,
  channel_data.events::jsonb,
  channel_data.pattern
from catchmenu_hq.tenants t
cross join (
  values
  -- KDS 티켓 변경 (주방 화면)
  (
    'KDS_TICKETS_CHANGE',
    'KDS 티켓 실시간',
    'KDS_TICKETS',
    'POSTGRES_CHANGES',
    'catchmenu_kds', 'kds_tickets',
    'store_id',
    '["UPDATE"]',
    'store:{store_id}:kds'
  ),
  -- KDS 이벤트 (주방 알림)
  (
    'KDS_EVENTS_STREAM',
    'KDS 이벤트 스트림',
    'KDS_EVENTS',
    'BROADCAST',
    null, null, null,
    '["*"]',
    'store:{store_id}:kds:events'
  ),
  -- 대기열 변경 (DID/직원 화면)
  (
    'WAITING_QUEUE_CHANGE',
    '대기열 실시간',
    'WAITING_QUEUE',
    'POSTGRES_CHANGES',
    'catchmenu_pos', 'order_sessions',
    'store_id',
    '["INSERT","UPDATE"]',
    'store:{store_id}:waiting'
  ),
  -- 결제 상태 변경 (POS 화면)
  (
    'PAYMENT_STATUS_CHANGE',
    '결제 상태 실시간',
    'PAYMENT_STATUS',
    'POSTGRES_CHANGES',
    'catchmenu_payment', 'payment_ledger',
    'store_id',
    '["INSERT","UPDATE"]',
    'store:{store_id}:payment'
  ),
  -- DID 디스플레이 (고객 화면)
  (
    'DID_DISPLAY_BROADCAST',
    'DID 고객 안내',
    'DID_DISPLAY',
    'BROADCAST',
    null, null, null,
    '["*"]',
    'store:{store_id}:did'
  ),
  -- 메뉴 품절 (키오스크/앱)
  (
    'MENU_STATUS_CHANGE',
    '메뉴 상태 실시간',
    'MENU_STATUS',
    'POSTGRES_CHANGES',
    'catchmenu_pos', 'menus',
    'store_id',
    '["UPDATE"]',
    'store:{store_id}:menu'
  ),
  -- 매장 운영 모드 변경
  (
    'STORE_MODE_CHANGE',
    '매장 운영 모드',
    'STORE_MODE',
    'BROADCAST',
    null, null, null,
    '["*"]',
    'store:{store_id}:mode'
  ),
  -- 직원 알림 (직원 앱)
  (
    'STAFF_ALERTS',
    '직원 알림',
    'STAFF_ALERTS',
    'BROADCAST',
    null, null, null,
    '["*"]',
    'store:{store_id}:staff:alerts'
  ),
  -- AI 고객센터 채팅 (Firebase 마이그레이션 대상)
  (
    'AI_CHAT_STREAM',
    'AI 고객센터 채팅',
    'AI_CHAT',
    'BROADCAST',
    null, null, null,
    '["*"]',
    'customer:{customer_id}:ai:chat'
  )
) as channel_data(
  code, name, ctype, rtype,
  schema_n, table_n, filter_col,
  events, pattern
)
where not exists (
  select 1
  from catchmenu_common.realtime_channels
  where tenant_id = t.id
    and channel_code = channel_data.code
)
on conflict do nothing;


-- =============================================
-- edge_function_registry table
-- Supabase Edge Functions 라우팅 관리
-- =============================================
create table if not exists
  catchmenu_common.edge_function_registry (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,

  function_code text not null,
  function_name text not null,
  function_path text not null,
  function_method text not null default 'POST',

  -- routing
  trigger_type text not null,
  trigger_source text,

  -- security
  requires_auth boolean not null default true,
  requires_signature boolean not null default false,
  allowed_origins jsonb default '["*"]'::jsonb,

  -- rate limiting
  rate_limit_per_minute int default 60,
  rate_limit_per_day int,

  -- timeout
  timeout_seconds int not null default 10,

  -- target RPC
  target_rpc_schema text,
  target_rpc_name text,

  -- Flutter SDK invoke path
  flutter_invoke_name text,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_function_code unique (
    coalesce(tenant_id::text, 'GLOBAL'),
    function_code
  ),
  constraint chk_trigger_type check (
    trigger_type in (
      'WEBHOOK', 'SCHEDULED', 'HTTP',
      'REALTIME', 'STORAGE', 'AUTH'
    )
  ),
  constraint chk_function_method check (
    function_method in (
      'GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'
    )
  )
);

alter table catchmenu_common.edge_function_registry
  enable row level security;
alter table catchmenu_common.edge_function_registry
  force row level security;

drop policy if exists edge_function_isolation
  on catchmenu_common.edge_function_registry;
create policy edge_function_isolation
  on catchmenu_common.edge_function_registry
  for all to authenticated
  using (
    tenant_id is null
    or tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_edge_function_updated
  on catchmenu_common.edge_function_registry;
create trigger trg_edge_function_updated
  before update on catchmenu_common.edge_function_registry
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_common.edge_function_registry is
  'Supabase Edge Function routing registry.
   Flutter invoke:
     supabase.functions.invoke(flutter_invoke_name, ...)
   Edge Function routes to target_rpc via PostgreSQL.

   Edge Function 역할:
   1. 외부 웹훅 수신 (Toss, Baemin, VAN)
   2. 서명 검증 (HMAC-SHA256)
   3. Rate limiting
   4. Supabase RPC 호출
   5. Realtime Broadcast 발행
   6. Firebase 이벤트 포워딩 (AI 채팅)

   특허1: Gateway 샌드박스 = Edge Function 구현체.
   외부 이벤트는 반드시 Edge Function 경유.
   직접 RPC 호출 금지 (서명 검증 우회 방지).';


-- seed edge function routes
insert into catchmenu_common.edge_function_registry (
  function_code, function_name, function_path,
  function_method, trigger_type,
  requires_auth, requires_signature,
  timeout_seconds,
  target_rpc_schema, target_rpc_name,
  flutter_invoke_name
) values
-- Toss 웹훅
(
  'TOSS_WEBHOOK',
  'Toss Payments 웹훅',
  '/functions/v1/toss-webhook',
  'POST', 'WEBHOOK',
  false, true, 5,
  'catchmenu_integrations',
  'process_toss_webhook',
  null
),
-- 배민 웹훅
(
  'BAEMIN_WEBHOOK',
  '배달의민족 웹훅',
  '/functions/v1/baemin-webhook',
  'POST', 'WEBHOOK',
  false, true, 5,
  'catchmenu_integrations',
  'process_baemin_order',
  null
),
-- 요기요 웹훅
(
  'YOGIYO_WEBHOOK',
  '요기요 웹훅',
  '/functions/v1/yogiyo-webhook',
  'POST', 'WEBHOOK',
  false, true, 5,
  'catchmenu_integrations',
  'process_yogiyo_order',
  null
),
-- 쿠팡이츠 웹훅
(
  'COUPANG_WEBHOOK',
  '쿠팡이츠 웹훅',
  '/functions/v1/coupang-webhook',
  'POST', 'WEBHOOK',
  false, true, 5,
  'catchmenu_integrations',
  'process_coupang_order',
  null
),
-- VAN 승인 처리
(
  'VAN_APPROVAL',
  'VAN 승인 처리',
  '/functions/v1/van-approval',
  'POST', 'HTTP',
  true, false, 10,
  'catchmenu_integrations',
  'process_van_approval',
  'van-approval'
),
-- KDS 실시간 Broadcast
(
  'KDS_BROADCAST',
  'KDS 상태 브로드캐스트',
  '/functions/v1/kds-broadcast',
  'POST', 'HTTP',
  true, false, 5,
  null, null,
  'kds-broadcast'
),
-- DID Broadcast
(
  'DID_BROADCAST',
  'DID 고객 안내 브로드캐스트',
  '/functions/v1/did-broadcast',
  'POST', 'HTTP',
  true, false, 5,
  null, null,
  'did-broadcast'
),
-- AI 고객센터 (Firebase 포워딩)
(
  'AI_CHAT_HANDLER',
  'AI 고객센터 채팅',
  '/functions/v1/ai-chat',
  'POST', 'HTTP',
  true, false, 30,
  'catchmenu_knowledge',
  'build_ai_context',
  'ai-chat'
),
-- 세션 정리 Cron
(
  'SESSION_CLEANUP_CRON',
  '세션 정리 스케줄러',
  '/functions/v1/session-cleanup',
  'POST', 'SCHEDULED',
  false, false, 60,
  'catchmenu_common',
  'run_session_cleanup_batch',
  null
),
-- 일일 마감 Cron
(
  'DAILY_CLOSE_CRON',
  '일일 마감 배치',
  '/functions/v1/daily-close',
  'POST', 'SCHEDULED',
  false, false, 300,
  'catchmenu_common',
  'run_daily_close_batch',
  null
)
on conflict do nothing;


-- =============================================
-- firebase_migration_boundary table
-- Firebase NoSQL 마이그레이션 경계 정의
-- =============================================
create table if not exists
  catchmenu_common.firebase_migration_boundary (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,

  -- boundary definition
  domain_name text not null unique,
  current_storage text not null,
  target_storage text not null,
  migration_phase text not null default 'PHASE_1',
  migration_status text not null default 'NOT_STARTED',

  -- Supabase source
  supabase_schema text,
  supabase_tables jsonb default '[]'::jsonb,
  supabase_rpc_names jsonb default '[]'::jsonb,

  -- Firebase target
  firebase_collection text,
  firebase_document_schema jsonb,
  firebase_indexes jsonb default '[]'::jsonb,

  -- sync strategy
  sync_direction text not null default 'SUPABASE_TO_FIREBASE',
  sync_trigger text not null default 'REALTIME',
  is_bidirectional boolean not null default false,
  conflict_resolution text not null default 'SUPABASE_WINS',

  -- data classification
  contains_pii boolean not null default false,
  contains_financial boolean not null default false,
  retention_days int,
  gdpr_applicable boolean not null default false,

  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_storage check (
    current_storage in (
      'SUPABASE_POSTGRES',
      'FIREBASE_FIRESTORE',
      'BOTH'
    )
    and target_storage in (
      'SUPABASE_POSTGRES',
      'FIREBASE_FIRESTORE',
      'BOTH'
    )
  ),
  constraint chk_migration_phase check (
    migration_phase in (
      'PHASE_1', 'PHASE_2', 'PHASE_3', 'COMPLETE'
    )
  ),
  constraint chk_migration_status check (
    migration_status in (
      'NOT_STARTED', 'IN_PROGRESS',
      'TESTING', 'COMPLETED', 'ROLLED_BACK'
    )
  ),
  constraint chk_sync_direction check (
    sync_direction in (
      'SUPABASE_TO_FIREBASE',
      'FIREBASE_TO_SUPABASE',
      'BIDIRECTIONAL'
    )
  ),
  constraint chk_conflict_resolution check (
    conflict_resolution in (
      'SUPABASE_WINS',
      'FIREBASE_WINS',
      'LATEST_WINS',
      'MANUAL'
    )
  )
);

drop trigger if exists trg_firebase_boundary_updated
  on catchmenu_common.firebase_migration_boundary;
create trigger trg_firebase_boundary_updated
  before update on
    catchmenu_common.firebase_migration_boundary
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_common.firebase_migration_boundary is
  'Firebase NoSQL migration boundary definitions.
   Defines what stays in PostgreSQL vs
   what migrates to Firebase Firestore.

   설계 원칙:
   1. 운영 원장 (orders, payments, KDS, audit)
      → 영구 PostgreSQL (절대 이동 불가)
   2. AI 대화/세션 컨텍스트
      → Firebase Firestore (Phase 2)
   3. 실시간 채팅/presence
      → Firebase Realtime DB (Phase 2)
   4. Vector search (메뉴 추천)
      → Firebase + Vector Extension (Phase 3)

   contains_financial = true → PostgreSQL 잠금.
   SUPABASE_WINS: 분쟁 시 PostgreSQL 우선.';


-- seed migration boundaries
insert into catchmenu_common.firebase_migration_boundary (
  domain_name, current_storage, target_storage,
  migration_phase, migration_status,
  supabase_schema, supabase_tables,
  firebase_collection,
  sync_direction, is_bidirectional,
  conflict_resolution,
  contains_pii, contains_financial,
  notes
) values
-- 운영 원장 (PostgreSQL 영구)
(
  'OPERATIONAL_LEDGERS',
  'SUPABASE_POSTGRES', 'SUPABASE_POSTGRES',
  'COMPLETE', 'COMPLETED',
  'catchmenu_ledger',
  '["events","audit_records","exceptions","tasks"]'::jsonb,
  null,
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  false, true,
  '운영 4원장 — 절대 이동 불가. '
  || 'Financial/Audit 데이터 = PostgreSQL 전용.'
),
-- 결제 원장 (PostgreSQL 영구)
(
  'PAYMENT_LEDGER',
  'SUPABASE_POSTGRES', 'SUPABASE_POSTGRES',
  'COMPLETE', 'COMPLETED',
  'catchmenu_payment',
  '["payment_ledger","payment_intents","reconciliation_cases"]'::jsonb,
  null,
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  false, true,
  '금융 원장 — 절대 이동 불가. '
  || '특허1 핵심 데이터.'
),
-- 메뉴/주문 (PostgreSQL 영구)
(
  'POS_CORE',
  'SUPABASE_POSTGRES', 'SUPABASE_POSTGRES',
  'COMPLETE', 'COMPLETED',
  'catchmenu_pos',
  '["orders","order_items","order_sessions","menus"]'::jsonb,
  null,
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  false, false,
  'POS 핵심 데이터 — PostgreSQL 전용.'
),
-- AI 고객센터 대화 (Firebase 마이그레이션 대상)
(
  'AI_CUSTOMER_CHAT',
  'SUPABASE_POSTGRES', 'FIREBASE_FIRESTORE',
  'PHASE_2', 'NOT_STARTED',
  'catchmenu_knowledge',
  '["documents"]'::jsonb,
  'ai_chat_sessions',
  'SUPABASE_TO_FIREBASE', true,
  'LATEST_WINS',
  true, false,
  'AI 고객센터 대화 이력.'
  || ' Phase 2: Firestore real-time chat.'
  || ' 대화 세션, 메시지, 컨텍스트 캐시.'
  || ' PII 포함 (고객 문의 내용).'
),
-- 고객 세션 컨텍스트 (Firebase 마이그레이션 대상)
(
  'AI_CONTEXT_CACHE',
  'SUPABASE_POSTGRES', 'FIREBASE_FIRESTORE',
  'PHASE_2', 'NOT_STARTED',
  null, null,
  'ai_context_cache',
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  false, false,
  'Context Builder 캐시.'
  || ' TTL: 5분. 운영 데이터 복사본 (요약본).'
  || ' PostgreSQL 원본 기준 항상 재생성 가능.'
),
-- Knowledge Vector (Phase 3)
(
  'KNOWLEDGE_VECTOR',
  'SUPABASE_POSTGRES', 'BOTH',
  'PHASE_3', 'NOT_STARTED',
  'catchmenu_knowledge',
  '["documents","document_versions"]'::jsonb,
  'knowledge_vectors',
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  false, false,
  'SOP/가이드 문서 벡터 임베딩.'
  || ' Phase 3: Firebase + Vector Extension.'
  || ' 메뉴 추천, SOP 검색 최적화.'
),
-- 고객 멤버십 (Supabase 유지, Firebase 읽기 캐시)
(
  'CUSTOMER_MEMBERSHIP',
  'SUPABASE_POSTGRES', 'BOTH',
  'PHASE_2', 'NOT_STARTED',
  'catchmenu_store',
  '["customers","coupon_issues","point_ledger"]'::jsonb,
  'customer_profiles',
  'SUPABASE_TO_FIREBASE', false,
  'SUPABASE_WINS',
  true, true,
  'PostgreSQL 원본. Firebase는 읽기 캐시만.'
  || ' PII + 포인트 원장 포함.'
  || ' Firebase 쓰기 금지 — Supabase RPC만 허용.'
)
on conflict (domain_name) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.get_realtime_config(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_type text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_channels jsonb;
  v_device_channels jsonb;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_realtime_config'
    );
  end if;

  -- all channels for store
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'channel_code', rc.channel_code,
        'channel_name', rc.channel_name,
        'channel_type', rc.channel_type,
        'realtime_type', rc.realtime_type,
        -- resolve channel name with store_id
        'channel_name_resolved', replace(
          replace(
            rc.channel_pattern,
            '{store_id}',
            p_store_id::text
          ),
          '{tenant_id}',
          p_tenant_id::text
        ),
        'schema_name', rc.schema_name,
        'table_name', rc.table_name,
        'filter_column', rc.filter_column,
        'filter_value', case
          when rc.filter_column = 'store_id'
          then p_store_id::text
          when rc.filter_column = 'tenant_id'
          then p_tenant_id::text
          else rc.filter_value
        end,
        'events', rc.events
      )
      order by rc.channel_type
    ),
    '[]'::jsonb
  )
  into v_channels
  from catchmenu_common.realtime_channels rc
  where rc.tenant_id = p_tenant_id
    and rc.is_active = true
    and rc.channel_type <> 'AI_CHAT';

  -- device-specific channel filter
  v_device_channels := case p_device_type
    when 'KDS' then (
      select jsonb_agg(ch)
      from jsonb_array_elements(v_channels) ch
      where ch->>'channel_type' in (
        'KDS_TICKETS', 'KDS_EVENTS',
        'MENU_STATUS', 'STORE_MODE'
      )
    )
    when 'POS' then (
      select jsonb_agg(ch)
      from jsonb_array_elements(v_channels) ch
      where ch->>'channel_type' in (
        'ORDER_SESSIONS', 'PAYMENT_STATUS',
        'WAITING_QUEUE', 'STORE_MODE',
        'STAFF_ALERTS'
      )
    )
    when 'KIOSK' then (
      select jsonb_agg(ch)
      from jsonb_array_elements(v_channels) ch
      where ch->>'channel_type' in (
        'MENU_STATUS', 'STORE_MODE',
        'PAYMENT_STATUS'
      )
    )
    when 'DID' then (
      select jsonb_agg(ch)
      from jsonb_array_elements(v_channels) ch
      where ch->>'channel_type' in (
        'WAITING_QUEUE', 'DID_DISPLAY',
        'ORDER_SESSIONS'
      )
    )
    when 'STAFF_APP' then (
      select jsonb_agg(ch)
      from jsonb_array_elements(v_channels) ch
      where ch->>'channel_type' in (
        'ORDER_SESSIONS', 'KDS_TICKETS',
        'WAITING_QUEUE', 'STAFF_ALERTS',
        'MENU_STATUS', 'STORE_MODE'
      )
    )
    else v_channels
  end;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'timezone', v_store.timezone
    ),
    'device_type', p_device_type,
    'channels', coalesce(
      v_device_channels, v_channels
    ),
    'channel_count', jsonb_array_length(
      coalesce(v_device_channels, v_channels)
    ),
    'supabase_realtime_url',
      'wss://{project_ref}.supabase.co/realtime/v1',
    'flutter_sdk_note',
      'Use supabase.channel(channel_name_resolved)'
      || '.on(RealtimeListenTypes.postgresChanges, ...)'
      || '.subscribe()',
    'message_code', 'realtime_config_loaded'
  );
end;
$$;


create or replace function
  catchmenu_common.notify_channel(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel_type text,
  p_event_type text,
  p_payload jsonb,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_channel record;
  v_channel_name text;
  v_notify_payload jsonb;
begin
  -- get channel config
  select channel_code, channel_pattern,
         realtime_type
  into v_channel
  from catchmenu_common.realtime_channels
  where tenant_id = p_tenant_id
    and channel_type = p_channel_type
    and realtime_type = 'BROADCAST'
    and is_active = true
  limit 1;

  if v_channel.channel_code is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'channel_type',
        'value', p_channel_type
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'notify_channel'
    );
  end if;

  -- resolve channel name
  v_channel_name := replace(
    replace(
      v_channel.channel_pattern,
      '{store_id}', p_store_id::text
    ),
    '{tenant_id}', p_tenant_id::text
  );

  -- build notification payload
  v_notify_payload := jsonb_build_object(
    'type', 'broadcast',
    'event', p_event_type,
    'payload', p_payload || jsonb_build_object(
      'tenant_id', p_tenant_id,
      'store_id', p_store_id,
      'sent_at', now()
    )
  );

  -- use pg_notify for Supabase Realtime
  -- Supabase Realtime listens on
  -- 'realtime:{channel_name}'
  perform pg_notify(
    'realtime:' || v_channel_name,
    v_notify_payload::text
  );

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'DEBUG',
    p_log_domain := 'SYSTEM',
    p_log_event := 'channel_notified',
    p_message :=
      'Broadcast: ' || v_channel_name
      || ' event=' || p_event_type,
    p_rpc_name := 'notify_channel',
    p_details := jsonb_build_object(
      'channel_type', p_channel_type,
      'channel_name', v_channel_name,
      'event_type', p_event_type
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'channel_name', v_channel_name,
      'event_type', p_event_type,
      'notified_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_edge_function_routes(
  p_tenant_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_routes jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'function_code', function_code,
        'function_name', function_name,
        'function_path', function_path,
        'function_method', function_method,
        'trigger_type', trigger_type,
        'requires_auth', requires_auth,
        'requires_signature', requires_signature,
        'timeout_seconds', timeout_seconds,
        'rate_limit_per_minute',
          rate_limit_per_minute,
        'target_rpc', case
          when target_rpc_name is not null
          then target_rpc_schema || '.'
            || target_rpc_name
          else null
        end,
        'flutter_invoke_name', flutter_invoke_name
      )
      order by trigger_type, function_code
    ),
    '[]'::jsonb
  )
  into v_routes
  from catchmenu_common.edge_function_registry
  where is_active = true
    and (
      tenant_id is null
      or tenant_id = p_tenant_id
    );

  return jsonb_build_object(
    'success', true,
    'routes', v_routes,
    'route_count', jsonb_array_length(v_routes),
    'flutter_usage',
      'supabase.functions.invoke(flutter_invoke_name, '
      || 'body: {...}, headers: {...})',
    'message_code', 'edge_routes_loaded'
  );
end;
$$;


create or replace function
  catchmenu_common.register_firebase_boundary(
  p_domain_name text,
  p_target_storage text,
  p_migration_phase text,
  p_firebase_collection text,
  p_firebase_document_schema jsonb default null,
  p_sync_direction text default 'SUPABASE_TO_FIREBASE',
  p_notes text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_boundary_id uuid;
begin
  update catchmenu_common.firebase_migration_boundary
  set
    target_storage = p_target_storage,
    migration_phase = p_migration_phase,
    firebase_collection = p_firebase_collection,
    firebase_document_schema =
      p_firebase_document_schema,
    sync_direction = p_sync_direction,
    notes = coalesce(p_notes, notes),
    updated_at = now()
  where domain_name = p_domain_name
  returning id into v_boundary_id;

  if v_boundary_id is null then
    insert into
      catchmenu_common.firebase_migration_boundary (
      domain_name, current_storage, target_storage,
      migration_phase, firebase_collection,
      firebase_document_schema, sync_direction,
      notes
    ) values (
      p_domain_name, 'SUPABASE_POSTGRES',
      p_target_storage, p_migration_phase,
      p_firebase_collection,
      p_firebase_document_schema,
      p_sync_direction, p_notes
    )
    returning id into v_boundary_id;
  end if;

  return jsonb_build_object(
    'success', true,
    'boundary_id', v_boundary_id,
    'domain_name', p_domain_name,
    'target_storage', p_target_storage,
    'migration_phase', p_migration_phase,
    'firebase_collection', p_firebase_collection,
    'message_code', 'firebase_boundary_registered'
  );
end;
$$;


-- grants
do $$
begin
  grant select on
    catchmenu_common.realtime_channels
    to authenticated;
  grant select on
    catchmenu_common.edge_function_registry
    to authenticated;
  grant select on
    catchmenu_common.firebase_migration_boundary
    to authenticated;

  revoke all on function
    catchmenu_common.get_realtime_config(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.get_realtime_config(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.notify_channel(
      uuid, uuid, text, text, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_common.notify_channel(
      uuid, uuid, text, text, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_edge_function_routes(uuid)
    from public;
  grant execute on function
    catchmenu_common.get_edge_function_routes(uuid)
    to authenticated;

  revoke all on function
    catchmenu_common.register_firebase_boundary(
      text, text, text, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_common.register_firebase_boundary(
      text, text, text, text, jsonb, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_common.get_realtime_config(
  uuid, uuid, text
) is
  'Returns Supabase Realtime channel config for Flutter app.
   Device-specific channel filtering:
     KDS: kds_tickets + kds_events + menu_status
     POS: order_sessions + payment_status + waiting_queue
     KIOSK: menu_status + store_mode + payment_status
     DID: waiting_queue + did_display + order_sessions
     STAFF_APP: all channels

   Flutter 구독 코드:
   final config = await supabase.rpc(
     "get_realtime_config",
     params: {
       "p_tenant_id": tenantId,
       "p_store_id": storeId,
       "p_device_type": "KDS"
     }
   );
   for (final ch in config["channels"]) {
     supabase
       .channel(ch["channel_name_resolved"])
       .on(RealtimeListenTypes.postgresChanges,
         ChannelFilter(
           event: "*",
           schema: ch["schema_name"],
           table: ch["table_name"],
           filter: "${ch["filter_column"]}=eq.${ch["filter_value"]}"
         ),
         (payload, [ref]) => onRealtimeEvent(payload)
       )
       .subscribe();
   }';

comment on table
  catchmenu_common.firebase_migration_boundary is
  'Firebase NoSQL migration boundary.

   이동 불가 (SUPABASE_POSTGRES 영구):
   - OPERATIONAL_LEDGERS: 4원장
   - PAYMENT_LEDGER: 결제/대사
   - POS_CORE: 주문/메뉴

   Phase 2 이동 대상 (Firebase Firestore):
   - AI_CUSTOMER_CHAT: 대화 세션/이력
   - AI_CONTEXT_CACHE: Context Builder 캐시

   Phase 3 이동 대상:
   - KNOWLEDGE_VECTOR: 임베딩/벡터 검색

   핵심 설계 원칙:
   1. contains_financial = true → PostgreSQL 잠금
   2. SUPABASE_WINS = PostgreSQL이 항상 진실의 원천
   3. Firebase는 캐시/UI 레이어 역할
   4. AI 채팅 이력만 Firebase 단독 소유 가능
   5. 고객 PII는 Firebase 쓰기 금지
      (Supabase RPC 통해서만 변경)

   특허3: AI 고객센터 Firebase 마이그레이션.
   Context Builder → Firebase 캐시 → AI Engine.
   운영 원장은 절대 Firebase 이동 금지.';