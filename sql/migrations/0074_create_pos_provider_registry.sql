-- 0074_create_pos_provider_registry.sql
-- Purpose: POS provider registry and integration tables.
--          1차: OKpos + Toss POS (MVP 연동 대상)
--          1-B차: 메이저 POS 30여개 확장 기반
--          6차: 전체 POS 업체 커버리지
--          SaaS 판매 조건:
--            1-B 완성 + AI 고객센터(5차) 동시 요건.
--          특허1 core: 외부 POS = Gateway 샌드박스 경유.
-- Depends on: 0073_final_verification.sql
-- Creates:
--   catchmenu_integrations.pos_provider_registry (table)
--   catchmenu_integrations.pos_store_configs (table)
--   catchmenu_integrations.okpos_transactions (table)
--   catchmenu_integrations.toss_pos_transactions (table)
--   catchmenu_common.feature_flags (table)
--   catchmenu_common.tenant_plan_configs (table)
--   catchmenu_common.online_order_configs (table)
--   catchmenu_common.white_label_configs (table)
--   function catchmenu_integrations.register_pos_provider(...)
--   function catchmenu_integrations.get_pos_config(...)
--   function catchmenu_integrations.process_okpos_order(...)
--   function catchmenu_integrations.process_toss_pos_order(...)
--   function catchmenu_common.is_feature_enabled(...)
--   function catchmenu_common.get_tenant_plan(...)

-- =============================================
-- pos_provider_registry table
-- 전체 POS 업체 등록 레지스트리
-- 1차: OKpos + Toss POS
-- 1-B차: 메이저 POS
-- 6차: 전체
-- =============================================
create table if not exists
  catchmenu_integrations.pos_provider_registry (
  id uuid primary key default gen_random_uuid(),

  provider_code text not null unique,
  provider_name text not null,
  provider_name_en text,
  provider_type text not null,

  -- 연동 단계 분류
  integration_phase text not null default 'PHASE_1B',

  -- API 연동 방식
  api_type text not null default 'REST',
  auth_method text not null default 'API_KEY',
  webhook_supported boolean not null default false,
  polling_supported boolean not null default false,
  realtime_supported boolean not null default false,

  -- 한국 시장 점유율 (참고용)
  market_tier text not null default 'TIER_3',

  -- 연동 상태
  integration_status text not null default 'PLANNED',
  sdk_available boolean not null default false,
  sandbox_available boolean not null default false,

  -- 지원 기능
  supports_order_push boolean not null default false,
  supports_payment_confirm boolean not null default false,
  supports_menu_sync boolean not null default false,
  supports_sales_pull boolean not null default false,

  -- 문서/연락처
  api_docs_url text,
  contact_email text,
  notes text,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_provider_type check (
    provider_type in (
      'CLOUD_POS', 'LOCAL_POS',
      'TABLET_POS', 'MOBILE_POS',
      'HYBRID_POS', 'KIOSK_POS'
    )
  ),
  constraint chk_integration_phase check (
    integration_phase in (
      'PHASE_1',    -- 1차: OKpos, Toss POS
      'PHASE_1B',   -- 1-B차: 메이저 POS
      'PHASE_6'     -- 6차: 전체
    )
  ),
  constraint chk_market_tier check (
    market_tier in (
      'TIER_1',  -- 점유율 상위 (OKpos, 토스POS)
      'TIER_2',  -- 메이저 (NICE포스, 포스뱅크 등)
      'TIER_3'   -- 기타
    )
  ),
  constraint chk_integration_status check (
    integration_status in (
      'PLANNED', 'IN_DEVELOPMENT',
      'TESTING', 'LIVE', 'DEPRECATED'
    )
  ),
  constraint chk_api_type check (
    api_type in (
      'REST', 'SOAP', 'SDK',
      'WEBHOOK', 'POLLING', 'CUSTOM'
    )
  ),
  constraint chk_auth_method check (
    auth_method in (
      'API_KEY', 'OAUTH2', 'HMAC',
      'IP_ALLOWLIST', 'CERTIFICATE', 'CUSTOM'
    )
  )
);

alter table catchmenu_integrations.pos_provider_registry
  enable row level security;
alter table catchmenu_integrations.pos_provider_registry
  force row level security;

drop policy if exists pos_registry_read
  on catchmenu_integrations.pos_provider_registry;
create policy pos_registry_read
  on catchmenu_integrations.pos_provider_registry
  for select to authenticated
  using (true);

drop trigger if exists trg_pos_registry_updated
  on catchmenu_integrations.pos_provider_registry;
create trigger trg_pos_registry_updated
  before update on
    catchmenu_integrations.pos_provider_registry
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.pos_provider_registry is
  'POS 업체 레지스트리.
   PHASE_1: OKpos + Toss POS (1차 MVP)
   PHASE_1B: 메이저 POS 30여개 (1-B차)
   PHASE_6: 전체 POS 업체 (6차 SaaS 완전판)

   SaaS 판매 조건:
   PHASE_1B 완성 + AI 고객센터(5차) 동시 요건.
   예상 SaaS 출시: 2028년 중~2029년 초.';


-- seed POS provider registry
insert into catchmenu_integrations.pos_provider_registry (
  provider_code, provider_name, provider_name_en,
  provider_type, integration_phase,
  api_type, auth_method,
  webhook_supported, polling_supported,
  market_tier, integration_status,
  sdk_available, sandbox_available,
  supports_order_push, supports_payment_confirm,
  supports_menu_sync, supports_sales_pull,
  notes
) values
-- =============================================
-- PHASE_1: 1차 MVP 대상
-- =============================================
(
  'OKPOS',
  '오케이포스', 'OKpos',
  'CLOUD_POS', 'PHASE_1',
  'REST', 'API_KEY',
  true, true,
  'TIER_1', 'IN_DEVELOPMENT',
  false, false,
  true, true, true, true,
  '국내 소형 매장 점유율 1위 클라우드 POS. '
  || '월 구독형. REST API + 웹훅 지원. '
  || '1차 MVP 핵심 연동 대상.'
),
(
  'TOSS_POS',
  '토스 POS', 'Toss POS',
  'TABLET_POS', 'PHASE_1',
  'REST', 'OAUTH2',
  true, false,
  'TIER_1', 'IN_DEVELOPMENT',
  true, true,
  true, true, true, true,
  '토스페이먼츠 기반 태블릿 POS. '
  || '결제 연동 우선. OAuth2 인증. '
  || '1차 MVP 핵심 연동 대상.'
),
-- =============================================
-- PHASE_1B: 1-B차 메이저 POS
-- =============================================
(
  'NICE_POS',
  'NICE포스', 'NICE POS',
  'LOCAL_POS', 'PHASE_1B',
  'SDK', 'CERTIFICATE',
  false, true,
  'TIER_2', 'PLANNED',
  true, false,
  false, true, false, true,
  'NICE정보통신 POS. 중형 매장 점유율 높음. '
  || 'SDK 기반. 1-B차 대상.'
),
(
  'POSBANK',
  '포스뱅크', 'Posbank',
  'LOCAL_POS', 'PHASE_1B',
  'REST', 'API_KEY',
  false, true,
  'TIER_2', 'PLANNED',
  false, false,
  false, false, false, true,
  '하드웨어 기반 로컬 POS. 1-B차 대상.'
),
(
  'IAMPOS',
  '아임포스', 'IamPos',
  'TABLET_POS', 'PHASE_1B',
  'REST', 'API_KEY',
  true, false,
  'TIER_2', 'PLANNED',
  true, false,
  false, true, false, true,
  '태블릿 기반 클라우드 POS. 1-B차 대상.'
),
(
  'KIS_POS',
  'KIS포스', 'KIS POS',
  'LOCAL_POS', 'PHASE_1B',
  'SDK', 'API_KEY',
  false, true,
  'TIER_2', 'PLANNED',
  false, false,
  false, true, false, true,
  'KIS정보통신 POS. VAN 연계 강점. 1-B차 대상.'
),
(
  'SMARTRO_POS',
  '스마트로 POS', 'Smartro POS',
  'HYBRID_POS', 'PHASE_1B',
  'REST', 'HMAC',
  true, false,
  'TIER_2', 'PLANNED',
  false, true,
  false, true, false, true,
  '스마트로 POS + VAN 통합. 1-B차 대상.'
),
(
  'UNIONPOS',
  '유니온포스', 'UnionPos',
  'CLOUD_POS', 'PHASE_1B',
  'REST', 'API_KEY',
  true, false,
  'TIER_2', 'PLANNED',
  true, false,
  false, false, true, true,
  '프랜차이즈 특화 POS. 4차 Franchise_OS 연동 후보. '
  || '1-B차 대상.'
),
(
  'DUMMY_POS_PLACEHOLDER',
  '기타 POS (1-B차 추가 예정)',
  'Other POS',
  'HYBRID_POS', 'PHASE_1B',
  'CUSTOM', 'CUSTOM',
  false, false,
  'TIER_2', 'PLANNED',
  false, false, false, false,
  '1-B차에서 순차 추가 예정 (20여개).'
),
-- =============================================
-- PHASE_6: 6차 전체 커버리지
-- =============================================
(
  'PHASE_6_PLACEHOLDER',
  '전체 POS 업체 (6차)',
  'All POS Providers',
  'HYBRID_POS', 'PHASE_6',
  'CUSTOM', 'CUSTOM',
  false, false,
  'TIER_3', 'PLANNED',
  false, false, false, false,
  '6차 SaaS 완전판에서 전체 POS 업체 연동. '
  || 'SaaS 판매 = 1-B 완성 + AI 고객센터 동시 요건.'
)
on conflict (provider_code) do nothing;


-- =============================================
-- pos_store_configs table
-- 매장별 POS 연동 설정
-- =============================================
create table if not exists
  catchmenu_integrations.pos_store_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  provider_code text not null
    references catchmenu_integrations
      .pos_provider_registry(provider_code),

  -- 연동 설정
  config_status text not null default 'PENDING',
  api_key_hint text,
  merchant_id text,
  terminal_id text,
  store_code_at_pos text,

  -- 동기화 설정
  order_push_enabled boolean not null default false,
  menu_sync_enabled boolean not null default false,
  sales_pull_enabled boolean not null default false,
  payment_confirm_enabled boolean
    not null default false,

  -- 동기화 이력
  last_menu_synced_at timestamptz,
  last_sales_pulled_at timestamptz,
  last_order_pushed_at timestamptz,
  last_heartbeat_at timestamptz,

  -- 오류 추적
  consecutive_failures int not null default 0,
  last_error_at timestamptz,
  last_error_message text,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_store_pos unique (
    store_id, provider_code
  ),
  constraint chk_config_status check (
    config_status in (
      'PENDING', 'ACTIVE',
      'SUSPENDED', 'ERROR', 'DISCONNECTED'
    )
  )
);

create index if not exists idx_pos_store_configs
  on catchmenu_integrations.pos_store_configs(
    store_id, config_status
  ) where is_active = true;

alter table catchmenu_integrations.pos_store_configs
  enable row level security;
alter table catchmenu_integrations.pos_store_configs
  force row level security;

drop policy if exists pos_store_configs_isolation
  on catchmenu_integrations.pos_store_configs;
create policy pos_store_configs_isolation
  on catchmenu_integrations.pos_store_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_pos_store_configs_updated
  on catchmenu_integrations.pos_store_configs;
create trigger trg_pos_store_configs_updated
  before update on
    catchmenu_integrations.pos_store_configs
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- okpos_transactions table
-- OKpos 주문/결제 트랜잭션 원본 보관
-- =============================================
create table if not exists
  catchmenu_integrations.okpos_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- OKpos 식별자
  okpos_order_id text not null,
  okpos_store_id text,
  okpos_terminal_id text,
  okpos_tx_type text not null,

  -- 연결된 내부 레코드
  order_id uuid,
  ledger_id uuid,
  session_id uuid,

  -- 금액
  total_amount int,
  paid_amount int,
  discount_amount int not null default 0,

  -- 상태
  okpos_status text not null default 'RECEIVED',
  raw_request jsonb,
  raw_response jsonb,
  processing_status text not null default 'PENDING',
  processing_error text,

  -- 타임스탬프
  okpos_ordered_at timestamptz,
  received_at timestamptz not null default now(),
  processed_at timestamptz,

  business_day date,
  business_timezone text default 'Asia/Seoul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_okpos_order unique (
    store_id, okpos_order_id
  ),
  constraint chk_okpos_tx_type check (
    okpos_tx_type in (
      'NEW_ORDER', 'ORDER_UPDATE',
      'ORDER_CANCEL', 'PAYMENT_CONFIRM',
      'PAYMENT_CANCEL', 'MENU_SYNC'
    )
  ),
  constraint chk_okpos_processing check (
    processing_status in (
      'PENDING', 'PROCESSING',
      'COMPLETED', 'FAILED', 'IGNORED'
    )
  )
);

create index if not exists idx_okpos_tx_store
  on catchmenu_integrations.okpos_transactions(
    store_id, business_day
  );
create index if not exists idx_okpos_tx_order
  on catchmenu_integrations.okpos_transactions(
    order_id
  ) where order_id is not null;

alter table catchmenu_integrations.okpos_transactions
  enable row level security;
alter table catchmenu_integrations.okpos_transactions
  force row level security;

drop policy if exists okpos_tx_isolation
  on catchmenu_integrations.okpos_transactions;
create policy okpos_tx_isolation
  on catchmenu_integrations.okpos_transactions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_okpos_tx_updated
  on catchmenu_integrations.okpos_transactions;
create trigger trg_okpos_tx_updated
  before update on
    catchmenu_integrations.okpos_transactions
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- toss_pos_transactions table
-- 토스 POS 트랜잭션 원본 보관
-- =============================================
create table if not exists
  catchmenu_integrations.toss_pos_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 토스 POS 식별자
  toss_pos_order_id text not null,
  toss_pos_terminal_id text,
  toss_pos_merchant_id text,
  toss_pos_tx_type text not null,

  -- 결제 정보 (토스페이먼츠 기반)
  toss_payment_key text,
  toss_approval_number text,

  -- 연결된 내부 레코드
  order_id uuid,
  ledger_id uuid,
  session_id uuid,

  -- 금액
  total_amount int,
  paid_amount int,
  discount_amount int not null default 0,
  card_amount int,
  cash_amount int not null default 0,

  -- 상태
  toss_pos_status text not null default 'RECEIVED',
  raw_request jsonb,
  raw_response jsonb,
  processing_status text not null default 'PENDING',
  processing_error text,

  -- 타임스탬프
  toss_pos_ordered_at timestamptz,
  received_at timestamptz not null default now(),
  processed_at timestamptz,

  business_day date,
  business_timezone text default 'Asia/Seoul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_toss_pos_order unique (
    store_id, toss_pos_order_id
  ),
  constraint chk_toss_pos_tx_type check (
    toss_pos_tx_type in (
      'NEW_ORDER', 'ORDER_UPDATE',
      'ORDER_CANCEL', 'PAYMENT_CONFIRM',
      'PAYMENT_CANCEL', 'MENU_SYNC',
      'SALES_CLOSE'
    )
  ),
  constraint chk_toss_pos_processing check (
    processing_status in (
      'PENDING', 'PROCESSING',
      'COMPLETED', 'FAILED', 'IGNORED'
    )
  )
);

create index if not exists idx_toss_pos_tx_store
  on catchmenu_integrations.toss_pos_transactions(
    store_id, business_day
  );
create index if not exists idx_toss_pos_tx_order
  on catchmenu_integrations.toss_pos_transactions(
    order_id
  ) where order_id is not null;

alter table catchmenu_integrations.toss_pos_transactions
  enable row level security;
alter table catchmenu_integrations.toss_pos_transactions
  force row level security;

drop policy if exists toss_pos_tx_isolation
  on catchmenu_integrations.toss_pos_transactions;
create policy toss_pos_tx_isolation
  on catchmenu_integrations.toss_pos_transactions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_toss_pos_tx_updated
  on catchmenu_integrations.toss_pos_transactions;
create trigger trg_toss_pos_tx_updated
  before update on
    catchmenu_integrations.toss_pos_transactions
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- feature_flags table
-- 티어별 기능 ON/OFF 관리
-- SaaS 판매 조건 기반 설계
-- =============================================
create table if not exists
  catchmenu_common.feature_flags (
  id uuid primary key default gen_random_uuid(),

  flag_code text not null,
  flag_name text not null,
  flag_category text not null,
  description text,

  -- 활성화 조건
  -- 어느 플랜 티어부터 사용 가능한지
  min_plan_tier text not null default 'PRO',

  -- 개발 단계 연결
  available_from_phase text not null default 'PHASE_1B',

  -- 기본값
  default_enabled boolean not null default false,

  -- SaaS 판매와의 관계
  required_for_saas boolean not null default false,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_flag_code unique (flag_code),
  constraint chk_min_plan_tier check (
    min_plan_tier in (
      'STARTER', 'PRO', 'ENTERPRISE'
    )
  ),
  constraint chk_available_phase check (
    available_from_phase in (
      'PHASE_1', 'PHASE_1B', 'PHASE_2',
      'PHASE_3', 'PHASE_3B', 'PHASE_4',
      'PHASE_5', 'PHASE_6', 'PHASE_7'
    )
  )
);

drop trigger if exists trg_feature_flags_updated
  on catchmenu_common.feature_flags;
create trigger trg_feature_flags_updated
  before update on catchmenu_common.feature_flags
  for each row execute function
    catchmenu_common.set_updated_at();

-- seed feature flags
insert into catchmenu_common.feature_flags (
  flag_code, flag_name, flag_category,
  min_plan_tier, available_from_phase,
  default_enabled, required_for_saas,
  description
) values
-- 1차 기능 (MVP)
('WAITING_QUEUE', '대기/웨이팅', 'CORE',
  'STARTER', 'PHASE_1', true, false,
  '대기번호 + 호출 + DID 표시'),
('KDS_BASIC', 'KDS 기본', 'CORE',
  'STARTER', 'PHASE_1', true, false,
  'KDS 주문 표시 + Late Binding'),
('TAKEOUT_ORDER', '포장 주문', 'ORDER',
  'STARTER', 'PHASE_1', true, false,
  '포장 앱 주문 수신'),
('MENU_MANAGEMENT', '메뉴 관리', 'CORE',
  'STARTER', 'PHASE_1', true, false,
  '메뉴/품절/카테고리'),
-- 1차 POS 연동
('OKPOS_INTEGRATION', 'OKpos 연동', 'POS',
  'STARTER', 'PHASE_1', false, false,
  'OKpos 주문 수신 + 결제 확인'),
('TOSS_POS_INTEGRATION', '토스 POS 연동', 'POS',
  'STARTER', 'PHASE_1', false, false,
  '토스 POS 주문 + 토스페이먼츠 결제'),
-- 1-B차 기능 (SaaS 전환 핵심)
('CUSTOMER_MEMBERSHIP_APP', '고객 멤버십 앱', 'MEMBERSHIP',
  'PRO', 'PHASE_1B', false, true,
  '고객 앱 + 포인트 + 쿠폰. SaaS 필수 요건.'),
('DELIVERY_INTEGRATION', '배달앱 연동', 'DELIVERY',
  'PRO', 'PHASE_1B', false, true,
  '배민/요기요/쿠팡이츠. SaaS 필수 요건.'),
('DID_CMS', 'DID/CMS 고도화', 'DISPLAY',
  'PRO', 'PHASE_1B', false, false,
  'DID 픽업 표시 + CMS 콘텐츠 관리'),
('MAJOR_POS_INTEGRATION', '메이저 POS 연동', 'POS',
  'PRO', 'PHASE_1B', false, false,
  'NICE포스/포스뱅크/아임포스 등 30여개'),
('WHITE_LABEL', '화이트라벨', 'SAAS',
  'ENTERPRISE', 'PHASE_1B', false, false,
  '가맹점 본사 화이트라벨 협상 기반'),
-- 5차 기능 (SaaS 판매 핵심 요건)
('AI_CUSTOMER_CENTER', 'AI 고객센터', 'AI',
  'PRO', 'PHASE_5', false, true,
  '5차 AI 고객센터. SaaS 판매 핵심 필수 요건. '
  || '이 없이는 SaaS 판매 불가. '
  || '예상 완성: 2028년 중~2029년 초.'),
('DIGITAL_SOP', '디지털 SOP', 'AI',
  'PRO', 'PHASE_5', false, true,
  'RAG + pgvector 기반 SOP 자동 진화'),
-- 6차 기능
('MULTI_TENANT_SAAS', '멀티테넌트 SaaS', 'SAAS',
  'ENTERPRISE', 'PHASE_6', false, false,
  '외부 매장 판매용 완전한 SaaS'),
('ALL_POS_INTEGRATION', '전체 POS 연동', 'POS',
  'ENTERPRISE', 'PHASE_6', false, false,
  '국내 전체 POS 업체 연동'),
-- 7차 기능
('PHYSICAL_AI_GATEWAY', 'Physical AI Gateway', 'IOT',
  'ENTERPRISE', 'PHASE_7', false, false,
  'IoT/로봇/비전/음성 KDS 안전 게이트웨이')
on conflict (flag_code) do nothing;

comment on table catchmenu_common.feature_flags is
  'SaaS 티어별 기능 플래그.
   STARTER (월 1만원):
     PHASE_1 기능 + OKpos + Toss POS
     포장 주문 + KDS + 대기
     1호점 테스트베드 (2027년 9월)

   PRO (월 미정):
     + PHASE_1B 기능
     + 고객 멤버십 앱 (SaaS 필수)
     + 배달앱 연동 (SaaS 필수)
     + AI 고객센터 (SaaS 핵심 필수)
     예상 출시: 2028년 중~2029년 초

   ENTERPRISE:
     + 화이트라벨
     + 전체 POS
     + Physical AI Gateway (7차)

   핵심 공식:
   SaaS 판매 = PRO 완성 + AI 고객센터
   둘 중 하나만으로는 외부 판매 불가.';


-- =============================================
-- tenant_plan_configs table
-- 테넌트별 플랜 + 기능 활성화 상태
-- =============================================
create table if not exists
  catchmenu_common.tenant_plan_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null unique
    references catchmenu_hq.tenants(id),

  -- 플랜
  plan_tier text not null default 'STARTER',
  plan_status text not null default 'TRIAL',
  trial_ends_at timestamptz,
  subscription_starts_at timestamptz,
  subscription_ends_at timestamptz,

  -- 월 구독료
  monthly_fee int,
  currency text not null default 'KRW',

  -- 활성화된 기능 (feature_flag_codes)
  enabled_features jsonb
    not null default '[]'::jsonb,

  -- 한도
  max_stores int not null default 1,
  max_devices_per_store int not null default 5,
  max_staff_per_store int not null default 10,
  max_menu_items int not null default 100,
  max_monthly_orders int,

  -- 화이트라벨 설정
  is_white_label boolean not null default false,
  white_label_partner_code text,
  white_label_brand_name text,

  -- 메모
  sales_channel text,
  contract_note text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_plan_tier check (
    plan_tier in (
      'STARTER', 'PRO', 'ENTERPRISE', 'TRIAL'
    )
  ),
  constraint chk_plan_status check (
    plan_status in (
      'TRIAL', 'ACTIVE', 'SUSPENDED',
      'CANCELLED', 'EXPIRED'
    )
  )
);

alter table catchmenu_common.tenant_plan_configs
  enable row level security;
alter table catchmenu_common.tenant_plan_configs
  force row level security;

drop policy if exists tenant_plan_isolation
  on catchmenu_common.tenant_plan_configs;
create policy tenant_plan_isolation
  on catchmenu_common.tenant_plan_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_tenant_plan_updated
  on catchmenu_common.tenant_plan_configs;
create trigger trg_tenant_plan_updated
  before update on catchmenu_common.tenant_plan_configs
  for each row execute function
    catchmenu_common.set_updated_at();

-- seed: 테스트 테넌트 플랜
insert into catchmenu_common.tenant_plan_configs (
  tenant_id, plan_tier, plan_status,
  monthly_fee, max_stores,
  enabled_features, sales_channel
) values (
  '00000000-0000-0000-0000-000000000001',
  'STARTER', 'TRIAL',
  10000, 1,
  '["WAITING_QUEUE","KDS_BASIC","TAKEOUT_ORDER",'
  || '"MENU_MANAGEMENT","OKPOS_INTEGRATION",'
  || '"TOSS_POS_INTEGRATION"]'::jsonb,
  'DIRECT_1ST_STORE'
)
on conflict (tenant_id) do nothing;


-- =============================================
-- online_order_configs table
-- 포장/온라인 주문 설정
-- =============================================
create table if not exists
  catchmenu_common.online_order_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null unique
    references catchmenu_hq.stores(id),

  -- 포장 주문 설정
  takeout_enabled boolean not null default false,
  takeout_min_order_amount int not null default 0,
  takeout_lead_minutes int not null default 15,
  takeout_max_advance_days int not null default 0,

  -- 운영 시간 (포장)
  takeout_hours jsonb,

  -- 자동 수락
  auto_accept_takeout boolean not null default false,
  auto_accept_delay_seconds int not null default 60,
  reject_if_kds_overloaded boolean not null default true,
  kds_overload_threshold int not null default 15,

  -- 고객 앱 설정
  customer_app_enabled boolean not null default false,
  customer_app_store_name text,
  customer_app_logo_url text,
  customer_app_primary_color text
    default '#FF6B35',

  -- 알림 설정
  notify_on_order_ready boolean not null default true,
  notify_channel text not null default 'APP',

  -- 메시지 (i18n)
  welcome_message jsonb default '{
    "ko": "주문해 주셔서 감사합니다",
    "en": "Thank you for your order"
  }'::jsonb,
  ready_message jsonb default '{
    "ko": "포장이 준비되었습니다",
    "en": "Your order is ready for pickup"
  }'::jsonb,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table catchmenu_common.online_order_configs
  enable row level security;
alter table catchmenu_common.online_order_configs
  force row level security;

drop policy if exists online_order_isolation
  on catchmenu_common.online_order_configs;
create policy online_order_isolation
  on catchmenu_common.online_order_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_online_order_config_updated
  on catchmenu_common.online_order_configs;
create trigger trg_online_order_config_updated
  before update on
    catchmenu_common.online_order_configs
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- white_label_configs table
-- 화이트라벨 파트너 설정
-- =============================================
create table if not exists
  catchmenu_common.white_label_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null unique
    references catchmenu_hq.tenants(id),

  partner_code text not null unique,
  partner_name text not null,
  partner_type text not null,

  -- 브랜딩
  brand_name text not null,
  brand_logo_url text,
  brand_primary_color text,
  brand_secondary_color text,
  custom_domain text,

  -- 협상 조건
  revenue_share_pct numeric(5,2),
  min_store_count int not null default 1,
  contract_start_date date,
  contract_end_date date,

  -- 기능 제한
  allowed_features jsonb
    default '[]'::jsonb,
  max_stores int,

  -- 상태
  contract_status text not null default 'NEGOTIATING',
  contract_document_url text,

  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_partner_type check (
    partner_type in (
      'FRANCHISE_HQ',
      'POS_VENDOR',
      'DISTRIBUTOR',
      'DIRECT'
    )
  ),
  constraint chk_contract_status check (
    contract_status in (
      'NEGOTIATING', 'SIGNED',
      'ACTIVE', 'SUSPENDED', 'TERMINATED'
    )
  )
);

alter table catchmenu_common.white_label_configs
  enable row level security;
alter table catchmenu_common.white_label_configs
  force row level security;

drop policy if exists white_label_isolation
  on catchmenu_common.white_label_configs;
create policy white_label_isolation
  on catchmenu_common.white_label_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_white_label_updated
  on catchmenu_common.white_label_configs;
create trigger trg_white_label_updated
  before update on
    catchmenu_common.white_label_configs
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.white_label_configs is
  '화이트라벨 파트너 설정.
   partner_type:
   FRANCHISE_HQ: 가맹점 본사 (4차 Franchise_OS)
   POS_VENDOR: POS 업체 (OKpos, 토스POS 등)
   DISTRIBUTOR: 총판
   DIRECT: 직접 영업

   화이트라벨 전략:
   1. 개별 업소 직접 컨택 (STARTER 월 1만원)
   2. 가맹점 본사 협상 (ENTERPRISE 화이트라벨)
   3. POS 업체 번들 협상 (OKpos/토스POS 공동 영업)

   수익 모델:
   개별: 월 1만원 × 매장 수
   가맹본부: 월 N만원 × 가맹점 수 (revenue share)
   POS번들: POS 가입자에게 자동 추천';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.is_feature_enabled(
  p_tenant_id uuid,
  p_flag_code text
)
returns boolean
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_enabled boolean;
begin
  select
    tpc.enabled_features @>
      to_jsonb(p_flag_code)
  into v_enabled
  from catchmenu_common.tenant_plan_configs tpc
  where tpc.tenant_id = p_tenant_id
    and tpc.plan_status in ('TRIAL', 'ACTIVE');

  return coalesce(v_enabled, false);
end;
$$;


create or replace function
  catchmenu_common.get_tenant_plan(
  p_tenant_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_plan record;
  v_features jsonb;
begin
  select
    tpc.plan_tier, tpc.plan_status,
    tpc.monthly_fee, tpc.enabled_features,
    tpc.max_stores, tpc.is_white_label,
    tpc.trial_ends_at,
    tpc.subscription_ends_at
  into v_plan
  from catchmenu_common.tenant_plan_configs tpc
  where tpc.tenant_id = p_tenant_id;

  if v_plan.plan_tier is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'plan_not_configured'
    );
  end if;

  -- get feature details
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'flag_code', ff.flag_code,
        'flag_name', ff.flag_name,
        'flag_category', ff.flag_category,
        'available_from_phase',
          ff.available_from_phase,
        'required_for_saas',
          ff.required_for_saas
      )
    ),
    '[]'::jsonb
  )
  into v_features
  from catchmenu_common.feature_flags ff
  where ff.flag_code = any(
    select jsonb_array_elements_text(
      v_plan.enabled_features
    )
  )
  and ff.is_active = true;

  return jsonb_build_object(
    'success', true,
    'plan_tier', v_plan.plan_tier,
    'plan_status', v_plan.plan_status,
    'monthly_fee', v_plan.monthly_fee,
    'max_stores', v_plan.max_stores,
    'is_white_label', v_plan.is_white_label,
    'trial_ends_at', v_plan.trial_ends_at,
    'subscription_ends_at',
      v_plan.subscription_ends_at,
    'enabled_features', v_plan.enabled_features,
    'feature_details', v_features,
    'saas_ready', (
      select bool_and(
        v_plan.enabled_features @>
          to_jsonb(ff.flag_code)
      )
      from catchmenu_common.feature_flags ff
      where ff.required_for_saas = true
        and ff.is_active = true
    ),
    'message_code', 'tenant_plan_loaded'
  );
end;
$$;


create or replace function
  catchmenu_integrations.register_pos_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_code text,
  p_merchant_id text default null,
  p_terminal_id text default null,
  p_store_code_at_pos text default null,
  p_order_push_enabled boolean default false,
  p_payment_confirm_enabled boolean default false,
  p_menu_sync_enabled boolean default false,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_hq
as $$
declare
  v_provider record;
  v_config_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_feature_code text;
begin
  -- validate provider exists
  select id, provider_code, provider_name,
         integration_phase, integration_status,
         market_tier
  into v_provider
  from catchmenu_integrations.pos_provider_registry
  where provider_code = p_provider_code
    and is_active = true;

  if v_provider.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := 'ko',
      p_params := jsonb_build_object(
        'field', 'provider_code',
        'value', p_provider_code
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_pos_provider'
    );
  end if;

  -- check feature flag
  v_feature_code := p_provider_code || '_INTEGRATION';
  if not catchmenu_common.is_feature_enabled(
    p_tenant_id, v_feature_code
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'feature_not_enabled',
      'feature_code', v_feature_code,
      'message',
        p_provider_code
        || ' 연동이 현재 플랜에서 활성화되지 않았습니다. '
        || '플랜을 업그레이드하세요.'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- upsert pos store config
  insert into catchmenu_integrations.pos_store_configs (
    tenant_id, store_id, provider_code,
    config_status,
    merchant_id, terminal_id,
    store_code_at_pos,
    order_push_enabled,
    payment_confirm_enabled,
    menu_sync_enabled
  ) values (
    p_tenant_id, p_store_id, p_provider_code,
    'ACTIVE',
    p_merchant_id, p_terminal_id,
    p_store_code_at_pos,
    p_order_push_enabled,
    p_payment_confirm_enabled,
    p_menu_sync_enabled
  )
  on conflict (store_id, provider_code) do update set
    config_status = 'ACTIVE',
    merchant_id = coalesce(
      excluded.merchant_id, pos_store_configs.merchant_id
    ),
    terminal_id = coalesce(
      excluded.terminal_id, pos_store_configs.terminal_id
    ),
    order_push_enabled = excluded.order_push_enabled,
    payment_confirm_enabled =
      excluded.payment_confirm_enabled,
    menu_sync_enabled = excluded.menu_sync_enabled,
    updated_at = now()
  returning id into v_config_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'integration', 'pos_provider_registered', 1,
    'pos_store_config', v_config_id,
    null, 'ACTIVE',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'provider_code', p_provider_code,
      'provider_name', v_provider.provider_name,
      'market_tier', v_provider.market_tier,
      'integration_phase',
        v_provider.integration_phase
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'integration',
    p_audit_type := 'pos_provider_registered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'pos_store_config',
    p_subject_id := v_config_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'provider_code', p_provider_code,
      'provider_name', v_provider.provider_name,
      'integration_phase',
        v_provider.integration_phase
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'config_id', v_config_id,
    'provider_code', p_provider_code,
    'provider_name', v_provider.provider_name,
    'integration_phase', v_provider.integration_phase,
    'config_status', 'ACTIVE',
    'audit_id', v_audit_id,
    'message_code', 'pos_provider_registered'
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_pos_config(
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
  v_configs jsonb;
  v_plan jsonb;
begin
  -- get tenant plan
  v_plan := catchmenu_common.get_tenant_plan(
    p_tenant_id := p_tenant_id
  );

  -- get active POS configs for store
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'config_id', psc.id,
        'provider_code', psc.provider_code,
        'provider_name', pr.provider_name,
        'provider_type', pr.provider_type,
        'integration_phase', pr.integration_phase,
        'market_tier', pr.market_tier,
        'config_status', psc.config_status,
        'order_push_enabled',
          psc.order_push_enabled,
        'payment_confirm_enabled',
          psc.payment_confirm_enabled,
        'menu_sync_enabled',
          psc.menu_sync_enabled,
        'last_heartbeat_at',
          psc.last_heartbeat_at,
        'consecutive_failures',
          psc.consecutive_failures,
        'last_error_message',
          psc.last_error_message
      )
      order by pr.market_tier, pr.provider_code
    ),
    '[]'::jsonb
  )
  into v_configs
  from catchmenu_integrations.pos_store_configs psc
  join catchmenu_integrations.pos_provider_registry pr
    on pr.provider_code = psc.provider_code
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.is_active = true;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'plan_tier', v_plan->>'plan_tier',
    'saas_ready', v_plan->>'saas_ready',
    'pos_configs', v_configs,
    'active_pos_count',
      jsonb_array_length(v_configs),
    'message_code', 'pos_config_loaded'
  );
end;
$$;


create or replace function
  catchmenu_integrations.process_okpos_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_payload jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_gateway,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_config record;
  v_tx_id uuid;
  v_provider_event_id uuid;
  v_okpos_order_id text;
  v_tx_type text;
  v_normalized jsonb;
  v_order_result jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- feature flag 확인
  if not catchmenu_common.is_feature_enabled(
    p_tenant_id, 'OKPOS_INTEGRATION'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'feature_not_enabled',
      'feature_code', 'OKPOS_INTEGRATION'
    );
  end if;

  -- POS config 확인
  select psc.id, psc.config_status,
         psc.order_push_enabled,
         psc.merchant_id, psc.terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs psc
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.provider_code = 'OKPOS'
    and psc.is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'okpos_not_configured',
      'message', 'OKpos 연동이 설정되지 않았습니다'
    );
  end if;

  if v_config.config_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'okpos_not_active',
      'config_status', v_config.config_status
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- OKpos 페이로드 파싱
  -- OKpos payload structure:
  -- orderId, orderType, items[], totalAmount,
  -- requestMsg, txType
  v_okpos_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'orderNo',
    p_raw_payload->>'id'
  );
  v_tx_type := coalesce(
    p_raw_payload->>'txType',
    'NEW_ORDER'
  );

  if v_okpos_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_okpos_order_id'
    );
  end if;

  -- store raw transaction
  insert into catchmenu_integrations.okpos_transactions (
    tenant_id, store_id,
    okpos_order_id, okpos_store_id,
    okpos_terminal_id, okpos_tx_type,
    total_amount,
    okpos_status, raw_request,
    processing_status,
    okpos_ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_okpos_order_id,
    v_config.merchant_id,
    v_config.terminal_id,
    v_tx_type,
    (p_raw_payload->>'totalAmount')::int,
    'RECEIVED', p_raw_payload,
    'PROCESSING',
    now(),
    v_business_day, v_timezone
  )
  on conflict (store_id, okpos_order_id) do update set
    processing_status = 'PROCESSING',
    updated_at = now()
  returning id into v_tx_id;

  -- store in gateway
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload, payload_hash,
    signature_verified, schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    'OKPOS', 'OKPOS',
    v_okpos_order_id, v_tx_type,
    p_raw_payload,
    encode(digest(
      p_raw_payload::text, 'sha256'
    ), 'hex'),
    true, true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- route by tx_type
  case v_tx_type
    when 'NEW_ORDER' then
      -- normalize OKpos → common format
      v_normalized := jsonb_build_object(
        'orderId', v_okpos_order_id,
        'totalAmount', coalesce(
          p_raw_payload->>'totalAmount', '0'
        ),
        'orderItems', coalesce(
          p_raw_payload->'items',
          p_raw_payload->'orderItems',
          '[]'::jsonb
        ),
        'requestMsg', coalesce(
          p_raw_payload->>'requestMsg',
          p_raw_payload->>'memo', ''
        ),
        'orderType', coalesce(
          p_raw_payload->>'orderType', 'TAKEOUT'
        ),
        'platform', 'OKPOS'
      );

      -- route to intake
      v_order_result :=
        catchmenu_integrations.intake_delivery_order(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_provider_type := 'DELIVERY_BAEMIN',
          p_provider_order_id := v_okpos_order_id,
          p_provider_raw_payload := v_normalized,
          p_correlation_id := p_correlation_id
        );

      -- update tx status
      update catchmenu_integrations.okpos_transactions
      set
        order_id = (v_order_result->>'order_id')::uuid,
        processing_status = case
          when (v_order_result->>'success')::boolean
            then 'COMPLETED'
          else 'FAILED'
        end,
        processing_error = case
          when not (v_order_result->>'success')::boolean
            then v_order_result->>'error_key'
          else null
        end,
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

    when 'ORDER_CANCEL' then
      -- 취소 처리
      update catchmenu_integrations.okpos_transactions
      set
        okpos_status = 'CANCELLED',
        processing_status = 'COMPLETED',
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'order_cancel_noted',
        'okpos_order_id', v_okpos_order_id
      );

    else
      -- unknown type → log and ignore
      update catchmenu_integrations.okpos_transactions
      set
        processing_status = 'IGNORED',
        processed_at = now(),
        updated_at = now()
      where id = v_tx_id;

      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'ignored',
        'tx_type', v_tx_type
      );
  end case;

  -- update gateway event
  update catchmenu_gateway.provider_raw_events
  set
    processing_status = case
      when (v_order_result->>'success')::boolean
        then 'ACCEPTED'
      else 'REJECTED'
    end,
    accepted_at = case
      when (v_order_result->>'success')::boolean
        then now()
      else null
    end
  where id = v_provider_event_id;

  -- update heartbeat
  update catchmenu_integrations.pos_store_configs
  set
    last_order_pushed_at = now(),
    last_heartbeat_at = now(),
    consecutive_failures = case
      when (v_order_result->>'success')::boolean
        then 0
      else consecutive_failures + 1
    end,
    last_error_at = case
      when not (v_order_result->>'success')::boolean
        then now()
      else last_error_at
    end,
    last_error_message = case
      when not (v_order_result->>'success')::boolean
        then v_order_result->>'error_key'
      else null
    end
  where id = v_config.id;

  return jsonb_build_object(
    'success', (v_order_result->>'success')::boolean,
    'tx_id', v_tx_id,
    'okpos_order_id', v_okpos_order_id,
    'tx_type', v_tx_type,
    'provider_event_id', v_provider_event_id,
    'order_result', v_order_result,
    'message_code', 'okpos_order_processed'
  );
end;
$$;


create or replace function
  catchmenu_integrations.process_toss_pos_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_payload jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_gateway,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_config record;
  v_tx_id uuid;
  v_provider_event_id uuid;
  v_toss_pos_order_id text;
  v_tx_type text;
  v_normalized jsonb;
  v_order_result jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- feature flag 확인
  if not catchmenu_common.is_feature_enabled(
    p_tenant_id, 'TOSS_POS_INTEGRATION'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'feature_not_enabled',
      'feature_code', 'TOSS_POS_INTEGRATION'
    );
  end if;

  -- POS config 확인
  select psc.id, psc.config_status,
         psc.merchant_id, psc.terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs psc
  where psc.store_id = p_store_id
    and psc.tenant_id = p_tenant_id
    and psc.provider_code = 'TOSS_POS'
    and psc.is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'toss_pos_not_configured',
      'message', '토스 POS 연동이 설정되지 않았습니다'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 토스 POS 페이로드 파싱
  -- Toss POS payload: orderId, items[], amount,
  -- paymentKey, txType
  v_toss_pos_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'orderNo'
  );
  v_tx_type := coalesce(
    p_raw_payload->>'txType', 'NEW_ORDER'
  );

  if v_toss_pos_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_toss_pos_order_id'
    );
  end if;

  -- store raw transaction
  insert into catchmenu_integrations.toss_pos_transactions (
    tenant_id, store_id,
    toss_pos_order_id,
    toss_pos_terminal_id, toss_pos_merchant_id,
    toss_pos_tx_type,
    toss_payment_key,
    total_amount, card_amount,
    toss_pos_status, raw_request,
    processing_status,
    toss_pos_ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_toss_pos_order_id,
    v_config.terminal_id,
    v_config.merchant_id,
    v_tx_type,
    p_raw_payload->>'paymentKey',
    (p_raw_payload->>'amount')::int,
    (p_raw_payload->>'cardAmount')::int,
    'RECEIVED', p_raw_payload,
    'PROCESSING',
    now(),
    v_business_day, v_timezone
  )
  on conflict (store_id, toss_pos_order_id)
  do update set
    processing_status = 'PROCESSING',
    updated_at = now()
  returning id into v_tx_id;

  -- store in gateway
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload, payload_hash,
    signature_verified, schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    'TOSS_POS', 'TOSS_POS',
    v_toss_pos_order_id, v_tx_type,
    p_raw_payload,
    encode(digest(
      p_raw_payload::text, 'sha256'
    ), 'hex'),
    true, true,
    'VALIDATING',
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- normalize for common processing
  v_normalized := jsonb_build_object(
    'orderId', v_toss_pos_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'amount', '0'
    ),
    'orderItems', coalesce(
      p_raw_payload->'items',
      '[]'::jsonb
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'memo', ''
    ),
    'orderType', coalesce(
      p_raw_payload->>'orderType', 'TAKEOUT'
    ),
    'paymentKey', p_raw_payload->>'paymentKey',
    'platform', 'TOSS_POS'
  );

  -- route by tx_type
  case v_tx_type
    when 'NEW_ORDER', 'PAYMENT_CONFIRM' then
      v_order_result :=
        catchmenu_integrations.intake_delivery_order(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_provider_type := 'DELIVERY_BAEMIN',
          p_provider_order_id := v_toss_pos_order_id,
          p_provider_raw_payload := v_normalized,
          p_correlation_id := p_correlation_id
        );

    when 'ORDER_CANCEL', 'PAYMENT_CANCEL' then
      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'cancel_noted',
        'toss_pos_order_id', v_toss_pos_order_id
      );

    else
      v_order_result := jsonb_build_object(
        'success', true,
        'action', 'ignored',
        'tx_type', v_tx_type
      );
  end case;

  -- update tx
  update catchmenu_integrations.toss_pos_transactions
  set
    order_id = case
      when v_order_result->>'order_id' is not null
        then (v_order_result->>'order_id')::uuid
      else null
    end,
    processing_status = case
      when (v_order_result->>'success')::boolean
        then 'COMPLETED'
      else 'FAILED'
    end,
    processed_at = now(),
    updated_at = now()
  where id = v_tx_id;

  -- update gateway
  update catchmenu_gateway.provider_raw_events
  set
    processing_status = 'ACCEPTED',
    accepted_at = now()
  where id = v_provider_event_id;

  -- update heartbeat
  update catchmenu_integrations.pos_store_configs
  set
    last_order_pushed_at = now(),
    last_heartbeat_at = now(),
    consecutive_failures = case
      when (v_order_result->>'success')::boolean
        then 0
      else consecutive_failures + 1
    end
  where id = v_config.id;

  return jsonb_build_object(
    'success', (v_order_result->>'success')::boolean,
    'tx_id', v_tx_id,
    'toss_pos_order_id', v_toss_pos_order_id,
    'tx_type', v_tx_type,
    'order_result', v_order_result,
    'message_code', 'toss_pos_order_processed'
  );
end;
$$;


-- grants
do $$
begin
  grant select on
    catchmenu_integrations.pos_provider_registry
    to authenticated;
  grant select on
    catchmenu_common.feature_flags
    to authenticated;

  revoke all on function
    catchmenu_common.is_feature_enabled(uuid, text)
    from public;
  grant execute on function
    catchmenu_common.is_feature_enabled(uuid, text)
    to authenticated;

  revoke all on function
    catchmenu_common.get_tenant_plan(uuid)
    from public;
  grant execute on function
    catchmenu_common.get_tenant_plan(uuid)
    to authenticated;

  revoke all on function
    catchmenu_integrations.register_pos_provider(
      uuid, uuid, text, text, text, text,
      boolean, boolean, boolean, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.register_pos_provider(
      uuid, uuid, text, text, text, text,
      boolean, boolean, boolean, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_pos_config(uuid, uuid)
    from public;
  grant execute on function
    catchmenu_integrations.get_pos_config(uuid, uuid)
    to authenticated;

  revoke all on function
    catchmenu_integrations.process_okpos_order(
      uuid, uuid, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_okpos_order(
      uuid, uuid, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.process_toss_pos_order(
      uuid, uuid, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_toss_pos_order(
      uuid, uuid, jsonb, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.get_tenant_plan(uuid) is
  'Returns tenant plan and feature activation status.
   saas_ready = true 조건:
   required_for_saas = true 인 모든 기능 활성화 시.
   현재 required_for_saas 기능:
   - CUSTOMER_MEMBERSHIP_APP (1-B차)
   - DELIVERY_INTEGRATION (1-B차)
   - AI_CUSTOMER_CENTER (5차) ← 핵심
   - DIGITAL_SOP (5차)
   예상 saas_ready: 2028년 중~2029년 초.';

comment on function
  catchmenu_integrations.process_okpos_order(
    uuid, uuid, jsonb, text
  ) is
  'OKpos 주문 수신 처리.
   1차 MVP 핵심 연동.
   feature_flag OKPOS_INTEGRATION 확인 후 처리.
   Gateway 샌드박스 경유 → 내부 원장 반영.
   특허1: 외부 POS → Gateway → 내부 원장.';