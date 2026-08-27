# 601802_Register_Stage0_Evidence_Collection.md

Status: Active
Lifecycle: Register
Last Updated: 2026-08-27

## §0 용도

`000701` §48 증거수집 산출물이다. 0-A-2(`601800`) 2단계 ERD 직전에 수행한 사실 등록부이며 판단·설계·결론을 기록하지 않는다.

> ⚠️ 1단계 선언(`601801` `HG-A-1`~`HG-A-9`)은 정책 선언이다.
> 이 문서는 라이브 DB와 저장소에서 관측한 사실을 그 선언과 분리해 기록한다.

## §1 분류 기준 (`000701` §48.1)

| 등급 | 이 문서에서 기록하는 의미 |
|---|---|
| A | 관련 문서 존재 여부와 문서가 쓰는 표현 |
| B | 라이브 DB 또는 migration의 SQL 객체 존재 여부 |
| C | 문서 표현과 라이브 객체의 일치·불일치 관측 |
| D | 로컬 실행 검증 여부. 호출 금지 함수는 미검증 사유 명시 |
| E | DB 내부·앱 코드 호출자와 ACL/RLS 관측 |

재사용 판정 열은 두지 않았다. A~E 관측 자체만 기록한다.

## §2 금지사항 (`000701` §48.3)

| # | 금지사항 | 수행 기록 |
|---:|---|---|
| 1 | 문서 존재를 구현으로 간주 | 문서와 라이브 객체를 A/B로 분리 |
| 2 | A~E 중 일부를 건너뛰고 결론 도출 | §4에 5군 전부 A~E 기록 |
| 3 | 표 없이 산문만으로 대상 설명 | 대상·객체·분류를 표로 기록 |
| 4 | `601500` 결론을 정답으로 전제 | `601500`은 권위보류 문서로 표시하고 라이브 카탈로그를 별도 기록 |
| 5 | 문서 노후·모순 은폐 | §10에 관측 사실 기록 |

호출 금지 함수 10건은 실행하지 않았다.

```text
isolate_tenant / manage_subscription / detect_threat /
verify_security_token / gateway_audit_entry /
record_van_transaction / check_staff_permission /
provision_tenant / create_franchise_store / onboard_tenant
```

## §3 측정 환경

| 항목 | 실측값 |
|---|---|
| 컨테이너 ID | `fb5b03ea152e5dc51e5093ea315e6698724a0a47ecc19c1c126dac1f11499857` |
| 이미지 | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| PostgreSQL | `17.6` |
| database | `postgres` |
| 조회 시각 | `2026-08-27 23:57:32 KST` (`2026-08-27 14:57:32+00`) |
| `SHOW default_transaction_read_only` | `on` |
| 최신 migration | `0171_merchant_account_foundation.sql`, applied `2026-08-24 02:25:14.371355+00` |
| 접속 명령 | `docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres` |

## §4 대상별 요약표 (`000701` §48.2)

| 대상군 | A 문서 | B SQL 객체 | C 문서↔객체 | D 로컬 실행 | E 호출자·권한 |
|---|---|---|---|---|---|
| 1. `isolate_tenant`·`manage_subscription` | 있음 — `601801` `HG-A-3`,`HG-A-6`; 권위보류 근거 `601505` §4 | 두 함수 모두 라이브 존재 | 불일치 관측 — 두 함수 모두 `tenant_status`를 쓰며 `isolation_state` 참조 0건; `manage_subscription`은 phantom `company_name` 참조 | **미검증 — 호출 금지(`601505` §4)** | DB 호출자: `isolate_tenant` 2함수, `manage_subscription` 0함수. 함수 ACL은 §5. 앱 코드 literal 0건 |
| 2. 상태 컬럼 소비자 | 있음 — `601801` `HG-A-1`~`HG-A-9`; 권위보류 `601502`·`601503` | 컬럼 2개, CHECK 2개, 함수 소비자 7개 | CHECK 허용값은 문서의 5×2 정의역과 동일; 소비 함수는 `tenant_status`만 참조 | 컬럼·제약·정의 조회 성공. 소비 함수 호출은 미수행 | DB 함수 7개; VIEW/MATVIEW/TRIGGER 0개; 권한은 각 함수 ACL에 따름 |
| 3. 과금·구독 7테이블 | 있음 — `601801` `HG-A-3`~`HG-A-6` | 7개 모두 라이브 존재 | 테이블·컬럼은 §7에 기록; 정책 선언의 동작 실행 일치는 미검증 | 행 수·catalog 조회 성공; 쓰기/함수 호출 미수행 | 참조 함수·RLS·정책·GRANT를 §7에 기록 |
| 4. 격리 관련 5자산 | 있음 — `601801` `HG-A-7`; `offline_queue` 재사용 미승인 명시 | 5개 모두 라이브 존재 | `offline_queue`는 네트워크/업무 action 재전송 컬럼을 보유; isolation 전용 컬럼은 관측되지 않음 | 행 수·catalog 조회 성공; enqueue/flush 호출 미수행 | `offline_queue` 참조 함수 5개; RLS·정책·GRANT를 §8에 기록 |
| 5. 호출 금지 7함수 | 있음 — 권위보류 `601505` §4 | 7개 모두 라이브 존재 | 정적 불일치 2종: `company_name` phantom, `p_reason` named-argument 불일치. 나머지는 §9 | **7건 전부 미검증 — 호출 금지(`601505` §4)** | DB 호출 관계와 EXECUTE ACL을 §9에 기록; 비문서 앱 코드 literal 0건 |

## §5 대상 1 — `isolate_tenant` · `manage_subscription`

### §5.1 함수 카탈로그

| 함수 | signature → 반환형 | md5 / 길이 | SECURITY DEFINER / search_path | EXECUTE ACL |
|---|---|---|---|---|
| `catchmenu_common.isolate_tenant` | `(p_tenant_id uuid, p_isolation_reason text, p_isolate boolean, p_actor_id uuid, p_locale text) → jsonb` | `f53ea7f556e89cec883b9ca6b482ca3e` / 2763 | true / `catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` | `postgres`, `authenticated` |
| `catchmenu_common.manage_subscription` | `(p_tenant_id uuid, p_action text, p_plan_tier text, p_reason text, p_actor_id uuid, p_locale text) → jsonb` | `3ceb5089e1c2305628db36e485be9bcd` / 4520 | true / `catchmenu_common, catchmenu_hq, catchmenu_ledger` | `postgres`, `service_role` |

### §5.2 참조·변경 사실

| 함수 | 읽기/쓰기 대상 | 상태 컬럼 사용 | phantom·호출 인자 관측 |
|---|---|---|---|
| `isolate_tenant` | `catchmenu_hq.tenants` UPDATE; `catchmenu_common.security_audit_log` INSERT; `catchmenu_ledger.events` INSERT | `tenant_status` WRITE; `isolation_state` READ/WRITE 0건 | 테이블·컬럼 phantom 0건. `tenant_status`에 `ISOLATED` 또는 `ACTIVE`를 쓰는 본문이며 라이브 CHECK 허용값에 `ISOLATED`가 없음 |
| `manage_subscription` | `tenants` SELECT/UPDATE; `subscription_plans` SELECT; `tenant_plan_configs` UPDATE/INSERT; `subscription_invoices` INSERT; ledger event INSERT | `tenant_status` READ/WRITE; `isolation_state` 0건 | `tenants.company_name`은 라이브 컬럼에 없음. `isolate_tenant(... p_reason := ...)` 호출 2곳은 실제 필수 인자 `p_isolation_reason`과 이름 불일치 |

### §5.3 호출자

| 피호출 함수 | DB 함수 본문에서 발견한 직접 호출자 | 비문서 앱 코드 검색 |
|---|---|---|
| `isolate_tenant` | `catchmenu_common.detect_threat`, `catchmenu_common.manage_subscription` | 194개 비문서·비migration 파일 검색 결과 0건 |
| `manage_subscription` | 0건 | 0건 |

### §5.4 A~E

| 대상 | A | B | C | D | E |
|---|---|---|---|---|---|
| `isolate_tenant` | `HG-A-3`; `601505` §4 | 라이브 함수 존재 | 문서는 상업 상태 비변경을 선언하나 함수는 `tenant_status` WRITE, `isolation_state` 0참조 | 미검증 — 호출 금지 | DB 호출자 2; ACL 2 role |
| `manage_subscription` | `HG-A-6`; `601505` §4 | 라이브 함수 존재 | 문서는 격리 비변경을 선언; 함수도 `isolation_state` 0참조. 단 `tenant_status`와 구독 테이블을 쓰며 phantom 1컬럼 존재 | 미검증 — 호출 금지 | DB 호출자 0; ACL 2 role |

## §6 대상 2 — `tenant_status` · `isolation_state` 소비자

### §6.1 컬럼·CHECK

| 컬럼 | 타입·NULL·default | CHECK 허용값 |
|---|---|---|
| `catchmenu_hq.tenants.tenant_status` | text, NOT NULL, `'TRIAL'` | `ACTIVE`, `TRIAL`, `SUSPENDED`, `CANCELLED`, `TERMINATED` |
| `catchmenu_hq.tenants.isolation_state` | text, NOT NULL, `'NONE'` | `NONE`, `ISOLATED` |

### §6.2 함수·뷰·트리거 소비자

| # | 객체 | `tenant_status` | `isolation_state` |
|---:|---|---|---|
| 1 | `catchmenu_common.get_hq_dashboard(p_locale text)` | 참조 | 미참조 |
| 2 | `catchmenu_common.get_saas_revenue_report(p_from_date date,p_to_date date,p_locale text)` | 참조 | 미참조 |
| 3 | `catchmenu_common.get_system_health_all(p_locale text)` | 참조 | 미참조 |
| 4 | `catchmenu_common.get_tenant_list(...)` | 참조 | 미참조 |
| 5 | `catchmenu_common.isolate_tenant(...)` | 참조 | 미참조 |
| 6 | `catchmenu_common.manage_subscription(...)` | 참조 | 미참조 |
| 7 | `catchmenu_common.provision_tenant(...)` | 참조 | 미참조 |
| — | VIEW | 0건 | 0건 |
| — | MATVIEW | 0건 | 0건 |
| — | 사용자 TRIGGER 정의 | 0건 | 0건 |

### §6.3 `is_registered` 위치

| 종류 | 실명 | 관측 |
|---|---|---|
| COLUMN | `catchmenu_common.pg_cron_jobs.is_registered` | 존재 |
| FUNCTION | `catchmenu_common.register_all_pg_cron_jobs()` | 본문에서 참조 |
| FUNCTION | `catchmenu_common.run_integration_test(uuid,uuid,text)` | 본문에서 참조 |
| FUNCTION | `catchmenu_knowledge.upsert_document_embedding(...)` | 본문 문자열에서 참조 |
| VIEW/MATVIEW | — | 0건 |

### §6.4 A~E

| 대상 | A | B | C | D | E |
|---|---|---|---|---|---|
| 두 상태 컬럼 | `601801` 5×2 선언 | 컬럼·CHECK 존재 | 허용값 집합 일치; 실제 소비는 `tenant_status` 7함수, `isolation_state` 0함수 | catalog 조회 성공; 소비 함수 실행 미수행 | 소비 함수 7; view/matview/trigger 0 |
| `is_registered` | 권위보류 `601502`/`601503`에 역논리 관측 | 컬럼과 참조 함수 3개 존재 | 문서의 과거 catalog 값은 이번 행 데이터 재측정 범위에 포함하지 않음 | 등록 함수 호출 미수행 | DB 함수 참조 3; 앱 호출자 미측정 |

## §7 대상 3 — 과금 · 구독 테이블

### §7.1 컬럼·데이터

`N`은 NOT NULL, `Y`는 nullable이다. 괄호 안은 default가 있을 때 그 값이다.

| 테이블 | 컬럼 수 | 컬럼 목록 (`이름:type:nullability`) | 행 수 | `tenant_id` |
|---|---:|---|---:|---|
| `subscription_plans` | 24 | `id:uuid:N`, `plan_code:text:N`, `plan_name:text:N`, `plan_tier:text:N`, `plan_type:text:N(RECURRING)`, `monthly_fee:int:N(0)`, `annual_fee:int:Y`, `currency:text:N(KRW)`, `max_stores:int:N(1)`, `max_devices_per_store:int:N(5)`, `max_staff_per_store:int:N(10)`, `max_menu_items:int:N(100)`, `max_monthly_orders:int:Y`, `max_monthly_customers:int:Y`, `included_features:jsonb:N([])`, `addon_features:jsonb:Y([])`, `is_publicly_available:boolean:N(false)`, `available_from_phase:text:N(PHASE_1B)`, `display_order:int:N(0)`, `is_recommended:boolean:N(false)`, `plan_description:text:Y`, `is_active:boolean:N(true)`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 8 | 없음 |
| `subscription_invoices` | 22 | `id:uuid:N`, `tenant_id:uuid:N`, `invoice_number:text:N`, `invoice_type:text:N(SUBSCRIPTION)`, `plan_code:text:N`, `plan_tier:text:N`, `billing_period_start:date:N`, `billing_period_end:date:N`, `base_amount:int:N(0)`, `addon_amount:int:N(0)`, `discount_amount:int:N(0)`, `tax_amount:int:N(0)`, `total_amount:int:N(0)`, `currency:text:N(KRW)`, `invoice_status:text:N(DRAFT)`, `due_date:date:Y`, `paid_at:timestamptz:Y`, `payment_method:text:Y`, `payment_reference:text:Y`, `invoice_note:text:Y`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 0 | 있음, FK→`tenants.id` |
| `tenant_plan_configs` | 22 | `id:uuid:N`, `tenant_id:uuid:N`, `plan_tier:text:N(STARTER)`, `plan_status:text:N(TRIAL)`, `trial_ends_at:timestamptz:Y`, `subscription_starts_at:timestamptz:Y`, `subscription_ends_at:timestamptz:Y`, `monthly_fee:int:Y`, `currency:text:N(KRW)`, `enabled_features:jsonb:N([])`, `max_stores:int:N(1)`, `max_devices_per_store:int:N(5)`, `max_staff_per_store:int:N(10)`, `max_menu_items:int:N(100)`, `max_monthly_orders:int:Y`, `is_white_label:boolean:N(false)`, `white_label_partner_code:text:Y`, `white_label_brand_name:text:Y`, `sales_channel:text:Y`, `contract_note:text:Y`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 1 | 있음, FK→`tenants.id`, UNIQUE |
| `tenant_quotas` | 18 | `id:uuid:N`, `tenant_id:uuid:N`, `resource_type:text:N`, `quota_limit:int:N`, `quota_unit:text:N(COUNT)`, `quota_period:text:N(MONTHLY)`, `current_usage:int:N(0)`, `usage_reset_at:timestamptz:Y`, `last_usage_at:timestamptz:Y`, `warning_threshold_pct:int:N(80)`, `critical_threshold_pct:int:N(95)`, `overage_policy:text:N(BLOCK)`, `overage_charge_per_unit:int:Y`, `alert_sent_warning:boolean:N(false)`, `alert_sent_critical:boolean:N(false)`, `is_active:boolean:N(true)`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 0 | 있음, FK→`tenants.id` |
| `tenant_rate_limits` | 16 | `id:uuid:N`, `tenant_id:uuid:N`, `limit_key:text:N`, `rpc_name:text:Y`, `limit_scope:text:N(TENANT)`, `max_requests:int:N`, `window_seconds:int:N`, `current_count:int:N(0)`, `window_start_at:timestamptz:N(now)`, `window_end_at:timestamptz:N(now+1m)`, `violation_count:int:N(0)`, `last_violation_at:timestamptz:Y`, `is_blocked:boolean:N(false)`, `blocked_until:timestamptz:Y`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 0 | 있음, FK→`tenants.id` |
| `usage_records` | 18 | `id:uuid:N`, `tenant_id:uuid:N`, `store_id:uuid:Y`, `usage_date:date:N`, `usage_month:text:N`, `order_count:int:N(0)`, `takeout_order_count:int:N(0)`, `delivery_order_count:int:N(0)`, `customer_count:int:N(0)`, `new_customer_count:int:N(0)`, `kds_ticket_count:int:N(0)`, `ai_query_count:int:N(0)`, `menu_item_count:int:N(0)`, `active_staff_count:int:N(0)`, `gross_revenue:int:N(0)`, `net_revenue:int:N(0)`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 0 | 있음, FK→`tenants.id` |
| `white_label_configs` | 21 | `id:uuid:N`, `tenant_id:uuid:N`, `partner_code:text:N`, `partner_name:text:N`, `partner_type:text:N`, `brand_name:text:N`, `brand_logo_url:text:Y`, `brand_primary_color:text:Y`, `brand_secondary_color:text:Y`, `custom_domain:text:Y`, `revenue_share_pct:numeric:Y`, `min_store_count:int:N(1)`, `contract_start_date:date:Y`, `contract_end_date:date:Y`, `allowed_features:jsonb:Y([])`, `max_stores:int:Y`, `contract_status:text:N(NEGOTIATING)`, `contract_document_url:text:Y`, `notes:text:Y`, `created_at:timestamptz:N(now)`, `updated_at:timestamptz:N(now)` | 0 | 있음, FK→`tenants.id`, UNIQUE |

### §7.2 제약

| 테이블 | PK / FK / UNIQUE / CHECK |
|---|---|
| `subscription_plans` | PK `id`; UNIQUE `plan_code`; CHECK `plan_tier`={TRIAL,STARTER,PRO,ENTERPRISE,BASIC,FRANCHISE}, `plan_type`={FREE,RECURRING,ANNUAL,CUSTOM} |
| `subscription_invoices` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `invoice_number`; CHECK `invoice_type`={SUBSCRIPTION,ADDON,SETUP_FEE,REFUND,CREDIT}, `invoice_status`={DRAFT,ISSUED,PAID,OVERDUE,CANCELLED,REFUNDED} |
| `tenant_plan_configs` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `tenant_id`; CHECK `plan_tier`={STARTER,PRO,ENTERPRISE,TRIAL}, `plan_status`={TRIAL,ACTIVE,SUSPENDED,CANCELLED,EXPIRED} |
| `tenant_quotas` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `(tenant_id,resource_type,quota_period)`; CHECK `resource_type` 10값, `quota_period`={HOURLY,DAILY,MONTHLY,ANNUAL,UNLIMITED}, `overage_policy`={BLOCK,WARN_ONLY,CHARGE,UPGRADE_PROMPT} |
| `tenant_rate_limits` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `(tenant_id,limit_key)`; CHECK `limit_scope`={TENANT,STORE,USER,IP,RPC} |
| `usage_records` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `(tenant_id,store_id,usage_date)`; CHECK 0건 |
| `white_label_configs` | PK `id`; FK `tenant_id→tenants.id`; UNIQUE `tenant_id`, `partner_code`; CHECK `partner_type`={FRANCHISE_HQ,POS_VENDOR,DISTRIBUTOR,DIRECT}, `contract_status`={NEGOTIATING,SIGNED,ACTIVE,SUSPENDED,TERMINATED} |

### §7.3 RLS·정책·GRANT·참조 함수

| 테이블 | RLS enable/force | policy 수·역할 | 명시 GRANT grantee | DB 참조 함수 수 |
|---|---|---|---|---:|
| `subscription_plans` | false/false | 0 | `authenticated:SELECT`, `postgres:*` | 3 |
| `subscription_invoices` | true/true | 2 — authenticated tenant filter; service_role true | `postgres:*` | 7 |
| `tenant_plan_configs` | true/true | 2 — authenticated tenant filter; service_role true | `postgres:*` | 14 |
| `tenant_quotas` | true/true | 1 — authenticated tenant filter | `postgres:*` | 6 |
| `tenant_rate_limits` | true/true | 1 — authenticated tenant filter | `postgres:*` | 3 |
| `usage_records` | true/true | 1 — authenticated tenant filter | `postgres:*` | 2 |
| `white_label_configs` | true/true | 1 — authenticated tenant filter | `postgres:*` | 0 |

### §7.4 A~E

| 대상 | A | B | C | D | E |
|---|---|---|---|---|---|
| 과금·구독 7테이블 | `HG-A-3`~`HG-A-6` | 7/7 존재 | 구조·행 수 기록 완료; 정책 동작 부합 여부는 실행하지 않음 | catalog/SELECT count 성공; mutation·RPC 미수행 | tenant 테이블 6/7에 tenant FK; RLS 6/7; 함수 참조 35건(중복 포함) |

## §8 대상 4 — 격리 관련 기존 자산

### §8.1 컬럼·데이터

| 테이블 | 컬럼 수 | 컬럼 목록 (`이름:type:nullability`) | 행 수 | `tenant_id` |
|---|---:|---|---:|---|
| `offline_queue` | 16 | `id:uuid:N`, `tenant_id:uuid:N`, `store_id:uuid:N`, `device_id:uuid:Y`, `action_type:text:N`, `action_payload:jsonb:N`, `action_priority:int:N`, `queue_status:text:N`, `retry_count:int:N`, `max_retries:int:N`, `local_temp_id:text:Y`, `server_result_id:uuid:Y`, `queued_at:timestamptz:N`, `flushed_at:timestamptz:Y`, `error_detail:text:Y`, `expires_at:timestamptz:N(now+24h)` | 0 | 있음, FK→`tenants.id` |
| `security_threats` | 24 | `id`, `tenant_id:Y`, `store_id:Y`, `device_id:Y`, `threat_stage`, `threat_type`, `threat_severity`, `detected_at`, `detection_source`, `threat_vector:Y`, `threat_payload:Y`, `affected_resource:Y`, `affected_resource_id:Y`, `auto_blocked`, `block_applied_at:Y`, `block_duration_minutes:Y`, `block_scope:Y`, `threat_status`, `resolved_at:Y`, `resolved_by:Y`, `resolution_note:Y`, `is_escalated`, `escalated_at:Y`, `escalation_level:Y` | 0 | 있음, nullable, FK 없음 |
| `security_audit_log` | 16 | `id`, `tenant_id:N`, `store_id:Y`, `audit_event`, `event_severity`, `event_source`, `actor_type:Y`, `actor_id:Y`, `actor_ip:Y`, `resource_type:Y`, `resource_id:Y`, `event_detail:Y`, `is_violation`, `was_blocked`, `action_taken:Y`, `created_at` | 0 | 있음, FK→`tenants.id` |
| `idempotency_keys` | 21 | `id`, `tenant_id:N`, `store_id:Y`, `idempotency_key`, `key_domain`, `key_scope`, `operation_type`, `request_hash:Y`, `processing_status`, `result_payload:Y`, `error_payload:Y`, `first_received_at`, `last_received_at`, `completed_at:Y`, `replay_count`, `max_replay_allowed`, `source_device_id:Y`, `provider_event_id:Y`, `correlation_id:Y`, `expires_at:Y`, `created_at` | 0 | 있음, FK→`tenants.id` |
| `tenant_onboarding_log` | 11 | `id`, `tenant_id:N`, `onboarding_step`, `step_status`, `step_order`, `completed_at:Y`, `completed_by:Y`, `step_data:Y`, `step_note:Y`, `created_at`, `updated_at` | 0 | 있음, FK→`tenants.id` |

### §8.2 제약·권한

| 테이블 | PK/FK/UNIQUE/CHECK 요약 | RLS enable/force; policy | GRANT |
|---|---|---|
| `offline_queue` | PK; FK tenant/store; CHECK action_type 12값, queue_status 6값 | true/true; authenticated tenant+store filter 1 | `postgres:*` |
| `security_threats` | PK; CHECK stage 1~4, severity 5값, status 5값, type 16값 | true/true; authenticated tenant/null SELECT 1 | `postgres:*` |
| `security_audit_log` | PK; FK tenant; CHECK severity 4값 | true/true; authenticated tenant filter 1 | `postgres:*` |
| `idempotency_keys` | PK; FK tenant/store/device; UNIQUE `(tenant_id,key_domain,idempotency_key)`; CHECK domain/scope/status/count/json 형태 | true/true; authenticated tenant filter 1 | `postgres:*` |
| `tenant_onboarding_log` | PK; FK tenant; UNIQUE `(tenant_id,onboarding_step)`; CHECK status 5값 | true/true; authenticated tenant filter 1 | `postgres:*` |

### §8.3 `offline_queue` 관측

| 항목 | 관측값 |
|---|---|
| 실패·작업 범위 | `action_type` CHECK: 주문 생성/항목/취소, KDS 상태, waiting 생성/상태, 수기결제, 현금영수증, 배너/탭 로그, stamp, diagnostic |
| 상태 | `PENDING`,`PROCESSING`,`COMPLETED`,`FAILED`,`EXPIRED`,`SKIPPED` |
| 보존기간 컬럼 | `expires_at`, default `now()+24 hours` |
| 정리 배치 | 이름/본문에서 `offline_queue`를 참조하는 별도 cron·cleanup 함수 0건 |
| 넣는 함수 | `enqueue_offline_action`, `flush_offline_queue`, `report_network_status` 본문에 INSERT 문자열 관측 |
| 읽기/처리 함수 | `flush_offline_queue`, `get_fallback_config`, `get_network_dashboard`, `run_final_validation` |
| isolation 전용 표식 | `isolation_state`, quarantine, review 컬럼 0건 |

### §8.4 A~E

| 대상 | A | B | C | D | E |
|---|---|---|---|---|---|
| 격리 관련 5자산 | `HG-A-7`; offline_queue 재사용 미승인 | 5/5 존재 | `offline_queue`는 네트워크·업무 action/retry/24h 만료 구조로 관측 | catalog/행 수 조회 성공; 함수 호출 미수행 | 참조 함수: offline 5+, threats 3, audit 13, idempotency 1, onboarding 3; 전부 RLS FORCE |

## §9 대상 5 — 호출 금지 함수 7건

### §9.1 함수·정적 분석·호출자

| 함수 | 존재·schema·signature·md5 | 정적 phantom/불일치 | DB 직접 호출자 | D |
|---|---|---|---|---|
| `isolate_tenant` | 존재; `catchmenu_common`; §5.1; `f53ea7...` | 컬럼 phantom 0; CHECK 밖 값 `ISOLATED`를 `tenant_status`에 쓰는 경로 | `detect_threat`, `manage_subscription` | 미검증 — 호출 금지 |
| `manage_subscription` | 존재; `catchmenu_common`; §5.1; `3ceb50...` | `tenants.company_name` phantom; `isolate_tenant` 호출 named arg `p_reason` 불일치 2곳 | 0 | 미검증 — 호출 금지 |
| `detect_threat` | 존재; `catchmenu_common`; `(text,int,text,text,jsonb,uuid,uuid,uuid,text,text)`; `992c78c881be2f23bcac8050b60ad2b7` | 참조 테이블 존재; FATAL 경로의 `isolate_tenant` named arg `p_reason` 불일치 | `gateway_audit_entry`, `verify_security_token`, `record_van_transaction`, `check_staff_permission` | 미검증 — 호출 금지 |
| `verify_security_token` | 존재; `catchmenu_common`; `(text,text,text,boolean)`; `b5c978db183d70e025ff97cc2bd1785f` | `security_tokens` 존재; `detect_threat` 호출 존재; 정적 table/column phantom 0건 | 0 | 미검증 — 호출 금지 |
| `gateway_audit_entry` | 존재; `catchmenu_common`; 15인자; `bbfac99ac170a83d988c610435a00732` | `gateway_audit_log` 존재; `detect_threat` 호출 존재; 정적 table/column phantom 0건 | 0 | 미검증 — 호출 금지 |
| `record_van_transaction` | 존재; `catchmenu_payment`; 18인자; `ef4d5ab3048ff13485e1cbf33579301f` | `van_transactions`,`provider_raw_events`,`events` 참조 객체 존재; `detect_threat` 호출 존재; 정적 phantom 0건 | 0 | 미검증 — 호출 금지 |
| `check_staff_permission` | 존재; `catchmenu_store`; `(uuid,uuid,uuid,text,int,text)`; `297947c8bca176dab515b1f22353cb5b` | `staff`,`staff_permission_matrix`,`staff_permission_logs` 존재; `detect_threat` 호출 존재; 정적 phantom 0건 | 0 | 미검증 — 호출 금지 |

### §9.2 권한

| 함수 | SECURITY DEFINER | search_path | EXECUTE grantee 관측 |
|---|---|---|---|
| `isolate_tenant` | true | common,hq,ledger,audit | postgres, authenticated |
| `manage_subscription` | true | common,hq,ledger | postgres, service_role |
| `detect_threat` | true | common | PUBLIC, postgres, authenticated |
| `verify_security_token` | true | common | PUBLIC, postgres, authenticated |
| `gateway_audit_entry` | true | common | PUBLIC, postgres, authenticated |
| `record_van_transaction` | true | payment,common,ledger | PUBLIC, postgres, authenticated |
| `check_staff_permission` | true | store,common | PUBLIC, postgres, authenticated |

### §9.3 A~E

| 대상 | A | B | C | D | E |
|---|---|---|---|---|---|
| 호출 금지 7함수 | `601505` §4(권위보류 증거) | 7/7 라이브 존재 | 정적 phantom 1컬럼 + named-argument 불일치 3호출부 + CHECK 밖 write 1경로 | 7/7 미검증 — 호출 금지 | DB 호출 edge 6개; 함수별 ACL 관측; 비문서 앱 코드 literal 0건 |

## §10 문서 노후 · 모순 관측

| # | 문서 위치 | 관측 사실 |
|---:|---|---|
| 1 | `601801` §3 | 본문 첫 문장은 `HG-A-1 through HG-A-8 are approved`라고 쓰고 같은 블록 5항과 별도 판정자 줄에서 `HG-A-9`를 추가 기록한다 |
| 2 | 권위보류 `601503` §2.4 | `isolate_tenant`는 `isolation_state`만, `manage_subscription`은 `tenant_status`만 변경한다고 기술한다. 라이브 함수에서 전자는 `tenant_status`만 참조하고 후자는 `isolation_state` 0참조다 |
| 3 | 권위보류 `601502`/`601503` | `is_registered` 역논리를 과거 관측으로 기록한다. 라이브에는 `pg_cron_jobs.is_registered`와 참조 함수 3개가 존재한다 |
| 4 | `601801` `HG-A-7` | `offline_queue` 재사용을 승인하지 않는다고 명시한다. 라이브 `offline_queue`에는 네트워크·업무 action/retry/24h 만료 컬럼이 있고 isolation 전용 컬럼은 없다 |

## §11 실행 쿼리 전문

모든 psql 실행에 다음 옵션을 공통 사용했다.

```powershell
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
```

```sql
SHOW default_transaction_read_only;
SELECT current_database(), current_timestamp;
SELECT version();
SELECT * FROM catchmenu_meta.migration_history ORDER BY 1 DESC LIMIT 1;

SELECT n.nspname,p.proname,
       pg_get_function_identity_arguments(p.oid),
       pg_get_function_result(p.oid),p.prosecdef,p.proconfig,
       md5(p.prosrc),length(p.prosrc),pg_get_userbyid(p.proowner),p.proacl
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname IN (
  'isolate_tenant','manage_subscription','detect_threat',
  'verify_security_token','gateway_audit_entry',
  'record_van_transaction','check_staff_permission',
  'provision_tenant','create_franchise_store','onboard_tenant'
) ORDER BY 1,2,3;

SELECT n.nspname,p.proname,pg_get_function_identity_arguments(p.oid),
       p.prosrc ILIKE '%tenant_status%',
       p.prosrc ILIKE '%isolation_state%'
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND (p.prosrc ILIKE '%tenant_status%' OR p.prosrc ILIKE '%isolation_state%')
ORDER BY 1,2,3;

SELECT schemaname,viewname FROM pg_views
WHERE definition ILIKE '%tenant_status%' OR definition ILIKE '%isolation_state%';
SELECT schemaname,matviewname FROM pg_matviews
WHERE definition ILIKE '%tenant_status%' OR definition ILIKE '%isolation_state%';
SELECT n.nspname,c.relname,t.tgname,pg_get_triggerdef(t.oid)
FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND pg_get_triggerdef(t.oid) ~* '(tenant_status|isolation_state)';

SELECT conname,pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid='catchmenu_hq.tenants'::regclass AND contype='c';

SELECT table_schema,table_name,column_name FROM information_schema.columns
WHERE column_name='is_registered';
SELECT n.nspname,p.proname,pg_get_function_identity_arguments(p.oid)
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ILIKE '%is_registered%';

-- 아래 targets CTE는 대상 12개 테이블에 공통 사용했다.
WITH targets(t) AS (VALUES
 ('subscription_plans'),('subscription_invoices'),('tenant_plan_configs'),
 ('tenant_quotas'),('tenant_rate_limits'),('usage_records'),
 ('white_label_configs'),('offline_queue'),('security_threats'),
 ('security_audit_log'),('idempotency_keys'),('tenant_onboarding_log'))
SELECT c.table_name,c.ordinal_position,c.column_name,c.data_type,
       c.is_nullable,c.column_default
FROM information_schema.columns c JOIN targets x ON x.t=c.table_name
WHERE c.table_schema='catchmenu_common'
ORDER BY c.table_name,c.ordinal_position;

WITH targets(t) AS (VALUES
 ('subscription_plans'),('subscription_invoices'),('tenant_plan_configs'),
 ('tenant_quotas'),('tenant_rate_limits'),('usage_records'),
 ('white_label_configs'),('offline_queue'),('security_threats'),
 ('security_audit_log'),('idempotency_keys'),('tenant_onboarding_log'))
SELECT c.relname,con.contype,con.conname,pg_get_constraintdef(con.oid)
FROM pg_constraint con JOIN pg_class c ON c.oid=con.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace JOIN targets x ON x.t=c.relname
WHERE n.nspname='catchmenu_common'
ORDER BY c.relname,con.contype,con.conname;

SELECT schemaname,tablename,policyname,roles,cmd,qual,with_check
FROM pg_policies
WHERE schemaname='catchmenu_common'
  AND tablename IN (
   'subscription_plans','subscription_invoices','tenant_plan_configs',
   'tenant_quotas','tenant_rate_limits','usage_records','white_label_configs',
   'offline_queue','security_threats','security_audit_log',
   'idempotency_keys','tenant_onboarding_log')
ORDER BY tablename,policyname;

-- 각 대상 테이블은 SELECT count(*)로 전수 행 수를 측정했다.
SELECT count(*) FROM catchmenu_common.subscription_plans;
SELECT count(*) FROM catchmenu_common.subscription_invoices;
SELECT count(*) FROM catchmenu_common.tenant_plan_configs;
SELECT count(*) FROM catchmenu_common.tenant_quotas;
SELECT count(*) FROM catchmenu_common.tenant_rate_limits;
SELECT count(*) FROM catchmenu_common.usage_records;
SELECT count(*) FROM catchmenu_common.white_label_configs;
SELECT count(*) FROM catchmenu_common.offline_queue;
SELECT count(*) FROM catchmenu_common.security_threats;
SELECT count(*) FROM catchmenu_common.security_audit_log;
SELECT count(*) FROM catchmenu_common.idempotency_keys;
SELECT count(*) FROM catchmenu_common.tenant_onboarding_log;

WITH names(name) AS (VALUES
 ('isolate_tenant'),('manage_subscription'),('detect_threat'),
 ('verify_security_token'),('gateway_audit_entry'),
 ('record_van_transaction'),('check_staff_permission'))
SELECT names.name,n.nspname,p.proname,
       pg_get_function_identity_arguments(p.oid)
FROM names JOIN pg_proc p ON position(names.name in lower(p.prosrc))>0
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname<>names.name ORDER BY 1,2,3;
```

저장소 호출자 검색 명령:

```powershell
rg -n -g '!docs/**' -g '!sql/migrations/**' -g '!tools/**' -g '!*.md' "isolate_tenant|manage_subscription|detect_threat|verify_security_token|gateway_audit_entry|record_van_transaction|check_staff_permission" .
```

## §12 근거 문서 목록 (`000701` §46)

| 문서 | 사용 위치 | 권위 표시 |
|---|---|---|
| `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §46, §48, §48.1~§48.3 | ACTIVE |
| `docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | 범위·진입점 | 본 워크패킷 |
| `docs/600000_implementation_lifecycle/601800_tenant_lifecycle_rpc_alignment/601801_Register_Stage1_Business_Rules.md` | `HG-A-1`~`HG-A-9` | 본 워크패킷 |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | §4 호출 금지와 정적 방벽의 과거 기록 | 권위보류 — evidence로만 사용 |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | 상태축·`is_registered` 과거 관측 | 권위보류 — evidence로만 사용 |
| `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | 상태 컬럼 책임의 과거 서술 | 권위보류 — evidence로만 사용 |
| `sql/migrations/0090_create_multitenant_isolation_rpc.sql` | `isolate_tenant` 계보 | SQL evidence |
| `sql/migrations/0112_create_hq_admin_rpc.sql` | `manage_subscription` 계보 | SQL evidence |
| `sql/migrations/0121_create_security_pipeline.sql` | `detect_threat` 계보 | SQL evidence |
| `sql/migrations/0168_create_operational_authority_foundation.sql` | 두 상태 컬럼·CHECK 계보 | SQL evidence |

