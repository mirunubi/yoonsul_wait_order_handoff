# 601904_Evidence_Stage2_ERD_Survey_Codex.md

Status: Active
Lifecycle: Evidence
Last Updated: 2026-09-02

## §0 성격

| 항목 | 기록 |
|---|---|
| 근거 | `000701` §47.1 2단계 Codex 조사 |
| 조사 축 | 라이브 스키마 실측 |
| 범위 | 조사만 수행. ERD 작성 0건 |
| 입력 문서 | `601901_Register_Stage0_Evidence_Collection.md`, `601902_Register_Stage1_Business_Rules.md` |
| 열람 제외 | `601803`, `601903` 열람 0건 |
| DB 조작 | read-only catalog 조회만 수행; 쓰기 0건 |
| 함수 실행 | 호출 금지 7함수와 추가 금지 3함수 실행 0건 |
| 물리명 | 신규 테이블·컬럼·제약명 제안 0건 |

이 문서는 현재 라이브 스키마가 `TI-1`~`TI-11`을 강제하는지 기록한다. SQL 객체의 존재와 규칙의 강제 여부를 분리해 기록한다.

## §1 측정 환경

| 항목 | 실측값 |
|---|---|
| 컨테이너 | `supabase_db_yoonsul_wait_order_handoff` |
| 컨테이너 ID | `b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec` |
| 이미지 | `public.ecr.aws/supabase/postgres:17.6.1.156` |
| PostgreSQL | `PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit` |
| database / user | `postgres` / `postgres` |
| 측정 시각 | `2026-09-02 13:25:13.042543+00` (`2026-09-02 22:25:13.042543 KST`) |
| `SHOW default_transaction_read_only` | `on` |
| migration success | 170건 |
| latest migration | `0171_merchant_account_foundation.sql`, `2026-08-30 11:46:47.552241+00` |
| 접속 방법 | `PGOPTIONS=-c default_transaction_read_only=on`, `psql -v ON_ERROR_STOP=1` |

## §2 C1 — TI-N의 강제 가능성

| TI-N | `601902` 요구 | 측정 결과 | 현재 강제 근거 또는 부재 사실 |
|---|---|---|---|
| `TI-1` | 원천 정책 3건을 이 나선의 직접 구속으로 채택 | 측정 불가 | 정책 문서의 채택 지위는 PostgreSQL 제약·RLS·함수 실행 상태가 표현하는 속성이 아니다. 문서 입력 외 DB 측정값이 없다. |
| `TI-2` | `isolation_state`는 tenant-wide 2값만 표현하고 부분 containment는 별도 scope 책임 | 강제되지 않는다 | `chk_tenants_isolation_state`가 `NONE`,`ISOLATED` 2값을 강제한다. catchmenu 스키마에서 이름에 isolation/containment/circuit/quarantine을 포함한 테이블은 0건이며, 관련 컬럼 검색 결과 isolation 관련 컬럼은 `tenants.isolation_state` 1건이다. 부분 containment 표현 및 escalation 관계를 강제하는 측정 객체는 0건이다. |
| `TI-3` | 자동 platform/security system 또는 authorized platform-security Human만 발동; `AUTHORITY_ALLOWED`만 실행 | 강제되지 않는다 | `isolate_tenant`는 SECURITY DEFINER이고 `authenticated`에 EXECUTE가 있다. 함수 본문은 `AUTHORITY_ALLOWED`, `AUTHORITY_REVIEW_REQUIRED`, `AUTHORITY_MULTI_PARTY_REQUIRED`를 포함하지 않는다. authority gate 결과를 참조하는 제약·트리거는 0건이다. |
| `TI-4` | 자동 단독 해제 금지; evidence·Human authority·tenant scope·audit 및 필요 시 독립 승인 | 강제되지 않는다 | 동일 `isolate_tenant(...,p_isolate boolean,...)`가 발동과 해제 경로를 가진다. 함수 EXECUTE는 `authenticated`에 있고, 해제자와 발동자의 분리 또는 다자 승인을 검사하는 관련 제약·트리거는 0건이다. 함수 호출은 금지되어 실행 검증하지 않았다. |
| `TI-5` | 발동과 해제의 비대칭; 자동 발동 주체에 해제 권한 자동 부여 금지 | 강제되지 않는다 | 발동과 해제가 단일 함수의 `p_isolate` boolean으로 분기한다. 발동·해제별 별도 ACL이나 authority 결과 검사는 catalog와 본문 정적 검색에서 0건이다. |
| `TI-6` | stable action identity 입력을 검증한 뒤 server가 canonical idempotency key 파생 | 강제되지 않는다 | `isolate_tenant` 본문은 `idempotency_keys`와 stable action identity를 참조하지 않는다. `idempotency_keys`를 쓰는 함수는 `intake_delivery_order` 1건이며 isolation transition 함수가 아니다. |
| `TI-7` | provider `merchant_id`와 SaaS Merchant Account를 다른 identity domain으로 취급하고 mapping을 통해 연결 | 강제되지 않는다 | `catchmenu_integrations.pos_store_configs.merchant_id text`와 `catchmenu_hq.stores.merchant_account_id uuid`가 별도 컬럼으로 존재한다. 후자는 Merchant Account FK 1건이 있고, 두 컬럼 사이 직접 FK·UNIQUE·CHECK·mapping 제약은 0건이다. |
| `TI-8` | scope envelope와 action별 필요 dimension 존재; 필요한 scope 누락 시 mutation 금지 | 강제되지 않는다 | 대상 5테이블에 tenant/store FK와 RLS policy가 존재하지만 모든 함수 transition에 적용되는 scope envelope 객체는 없다. `isolate_tenant`는 tenant 인자를 받지만 authority·policy·evidence context를 검사하는 본문 문자열과 제약은 0건이다. |
| `TI-9` | cross-tenant contamination을 격리 발동 사유에 포함하되 작은 containment는 자동 tenant-wide 승격 금지 | 강제되지 않는다 | `security_threats` CHECK에는 `TENANT_BOUNDARY_VIOLATION`, `EXTERNAL_CONTAMINATION` 값이 있다. 이 값과 `tenants.isolation_state` 전이를 연결하거나 escalation scope를 검사하는 FK·트리거·함수 참조는 0건이다. |
| `TI-10` | 격리 발동·해제 audit에 tenant/store/actor/role/surface/device/target/action/scope/authority/policy/evidence 기록 | 강제되지 않는다 | `security_audit_log`는 tenant/store/actor/resource/action/detail을 가진다. actor role, surface, device, previous scope, new scope, authority reference, policy reference, evidence reference 명명 컬럼은 0건이다. `event_detail` JSONB에 이 키들을 요구하는 CHECK는 0건이다. |
| `TI-11` | Stage 7 Human Approval 전에 `010004` §24 11항 선언 | 측정 불가 | Stage 7 승인 문서의 선언 여부는 이 라이브 relational schema의 제약·RLS·함수 속성이 아니다. 이번 입력 문서와 DB catalog만으로 실행 전 승인 기록의 미래 존재 여부를 측정할 수 없다. |

§2의 11행은 모두 측정 결과와 근거 또는 측정 불가 사유를 가진다. 공란은 0건이다.

## §3 C2 — 제약 실측

### §3.1 테이블별 제약·인덱스 집계

| 테이블 | PK | FK | UNIQUE | CHECK | 인덱스 | tenant 일치 강제 |
|---|---:|---:|---:|---:|---:|---|
| `catchmenu_hq.tenants` | 1 | 0 | 1 | 4 | 2 | 자기 PK만 존재; 다른 scope와의 tenant 일치 대상 없음 |
| `catchmenu_common.security_threats` | 1 | 0 | 0 | 4 | 3 | `tenant_id`는 nullable이며 FK 0건 |
| `catchmenu_common.security_audit_log` | 1 | 1 | 0 | 1 | 3 | tenant 존재만 단일 FK로 검사; store와 tenant의 동시 일치 제약 0건 |
| `catchmenu_common.idempotency_keys` | 1 | 3 | 1 | 7 | 6 | UNIQUE에 tenant 포함; store/device FK는 각각 단일 컬럼이며 tenant 동시 일치 제약 0건 |
| `catchmenu_common.offline_queue` | 1 | 2 | 0 | 2 | 3 | tenant/store FK가 각각 단일 컬럼; 두 값의 동시 일치 제약 0건 |

### §3.2 FK 전수

| 테이블 | FK | 로컬 컬럼 수 | 참조 | ON UPDATE | ON DELETE | tenant 동시 일치 |
|---|---|---:|---|---|---|---|
| `security_audit_log` | `security_audit_log_tenant_id_fkey` | 1 | `tenant_id` → `catchmenu_hq.tenants(id)` | NO ACTION | NO ACTION | 해당 없음 — tenant 단일 FK |
| `idempotency_keys` | `idempotency_keys_tenant_id_fkey` | 1 | `tenant_id` → `catchmenu_hq.tenants(id)` | NO ACTION | NO ACTION | tenant 존재만 검사 |
| `idempotency_keys` | `idempotency_keys_store_id_fkey` | 1 | `store_id` → `catchmenu_hq.stores(id)` | NO ACTION | NO ACTION | tenant_id와 store_id 동시 검사 0건 |
| `idempotency_keys` | `idempotency_keys_source_device_id_fkey` | 1 | `source_device_id` → `catchmenu_store.device_registry(id)` | NO ACTION | NO ACTION | tenant_id와 device_id 동시 검사 0건 |
| `offline_queue` | `offline_queue_tenant_id_fkey` | 1 | `tenant_id` → `catchmenu_hq.tenants(id)` | NO ACTION | NO ACTION | tenant 존재만 검사 |
| `offline_queue` | `offline_queue_store_id_fkey` | 1 | `store_id` → `catchmenu_hq.stores(id)` | NO ACTION | NO ACTION | tenant_id와 store_id 동시 검사 0건 |

FK 6건은 모두 단일 컬럼이다. 복합 FK는 0건이다.

### §3.3 PK·UNIQUE·CHECK 전수

| 테이블 | 이름 | 종류 | 정의 |
|---|---|---|---|
| `tenants` | `tenants_pkey` | PK | `PRIMARY KEY (id)` |
| `tenants` | `tenants_tenant_code_key` | UNIQUE | `UNIQUE (tenant_code)` |
| `tenants` | `chk_tenants_isolation_state` | CHECK | `isolation_state` ∈ `NONE`,`ISOLATED` |
| `tenants` | `chk_tenants_status` | CHECK | `tenant_status` ∈ `ACTIVE`,`TRIAL`,`SUSPENDED`,`CANCELLED`,`TERMINATED` |
| `tenants` | `chk_tenants_plan` | CHECK | `plan_tier` 4값 |
| `tenants` | `chk_tenants_type` | CHECK | `tenant_type` 4값 |
| `security_threats` | `security_threats_pkey` | PK | `PRIMARY KEY (id)` |
| `security_threats` | `chk_threat_stage` | CHECK | 1 이상 4 이하 |
| `security_threats` | `chk_threat_severity` | CHECK | 5값 |
| `security_threats` | `chk_threat_status` | CHECK | 5값 |
| `security_threats` | `chk_threat_type` | CHECK | 16값; `TENANT_BOUNDARY_VIOLATION`,`EXTERNAL_CONTAMINATION` 포함 |
| `security_audit_log` | `security_audit_log_pkey` | PK | `PRIMARY KEY (id)` |
| `security_audit_log` | `chk_event_severity` | CHECK | `INFO`,`WARNING`,`ERROR`,`CRITICAL` |
| `idempotency_keys` | `idempotency_keys_pkey` | PK | `PRIMARY KEY (id)` |
| `idempotency_keys` | `uq_idempotency_key` | UNIQUE | `UNIQUE (tenant_id,key_domain,idempotency_key)` |
| `idempotency_keys` | `chk_idempotency_domain` | CHECK | 11값 |
| `idempotency_keys` | `chk_idempotency_scope` | CHECK | `GLOBAL`,`TENANT`,`STORE`,`SESSION` |
| `idempotency_keys` | `chk_idempotency_status` | CHECK | 5값 |
| `idempotency_keys` | `chk_max_replay` | CHECK | `max_replay_allowed >= 0` |
| `idempotency_keys` | `chk_replay_count` | CHECK | `replay_count >= 0` |
| `idempotency_keys` | `chk_idempotency_result_object` | CHECK | null 또는 JSON object |
| `idempotency_keys` | `chk_idempotency_error_object` | CHECK | null 또는 JSON object |
| `offline_queue` | `offline_queue_pkey` | PK | `PRIMARY KEY (id)` |
| `offline_queue` | `chk_action_type` | CHECK | 12값 |
| `offline_queue` | `chk_queue_status` | CHECK | 6값 |

### §3.4 인덱스 전수

| 테이블 | 인덱스 |
|---|---|
| `tenants` | `tenants_pkey(id)` UNIQUE; `tenants_tenant_code_key(tenant_code)` UNIQUE |
| `security_threats` | `security_threats_pkey(id)` UNIQUE; `idx_threats_fatal(threat_severity,detected_at DESC)` partial; `idx_threats_open(tenant_id,threat_status,detected_at DESC)` partial |
| `security_audit_log` | `security_audit_log_pkey(id)` UNIQUE; `idx_security_audit_tenant(tenant_id,event_severity,created_at DESC)`; `idx_security_audit_violation(is_violation,created_at DESC)` partial |
| `idempotency_keys` | `idempotency_keys_pkey(id)` UNIQUE; `uq_idempotency_key(tenant_id,key_domain,idempotency_key)` UNIQUE; `idx_idempotency_tenant_domain(tenant_id,key_domain)`; `idx_idempotency_correlation(correlation_id)` partial; `idx_idempotency_expires(expires_at)` partial; `idx_idempotency_provider_event(provider_event_id)` partial |
| `offline_queue` | `offline_queue_pkey(id)` UNIQUE; `idx_offline_queue_store(store_id,queue_status,action_priority DESC,queued_at)` partial; `idx_offline_queue_expire(expires_at)` partial |

## §4 C3 — RLS·권한 실측

### §4.1 RLS·policy

| 테이블 | relrowsecurity | relforcerowsecurity | policy 수 | policy 정의 |
|---|---|---|---:|---|
| `tenants` | true | true | 1 | `tenants_select_own`; authenticated SELECT; `id = current_tenant_id()` |
| `security_threats` | true | true | 1 | `threats_hq_read`; authenticated SELECT; `tenant_id IS NULL OR tenant_id = current_tenant_id()` |
| `security_audit_log` | true | true | 1 | `security_audit_isolation`; authenticated ALL; `tenant_id = current_tenant_id()` |
| `idempotency_keys` | true | true | 1 | `idempotency_keys_store_isolation`; authenticated ALL; `tenant_id = current_tenant_id()` |
| `offline_queue` | true | true | 1 | `offline_queue_isolation`; authenticated ALL; `tenant_id = current_tenant_id() AND store_id = current_store_id()` |

다섯 policy는 모두 PERMISSIVE다. `with_check`는 5건 모두 null이다.

### §4.2 table GRANT·role 속성

| 테이블 | information_schema에 나타난 grantee | 권한 |
|---|---|---|
| `tenants` | `postgres` | 전 table privilege, grantable YES |
| `security_threats` | `postgres` | 전 table privilege, grantable YES |
| `security_audit_log` | `postgres` | 전 table privilege, grantable YES |
| `idempotency_keys` | `postgres` | 전 table privilege, grantable YES |
| `offline_queue` | `postgres` | 전 table privilege, grantable YES |

| role | rolsuper | rolcanlogin | rolbypassrls |
|---|---|---|---|
| `anon` | false | false | false |
| `authenticated` | false | false | false |
| `service_role` | false | false | true |
| `postgres` | false | true | true |

`has_table_privilege`로 조회한 SELECT·INSERT·UPDATE·DELETE는 다섯 테이블 모두 `postgres=true`, `anon=false`, `authenticated=false`, `service_role=false`다. policy의 role 지정은 table privilege를 부여하지 않는다. 따라서 authenticated의 다섯 테이블 직접 접근 권한은 현재 0건이다. SECURITY DEFINER 함수의 EXECUTE 권한은 §5에 별도로 기록한다.

## §5 C4 — 함수·트리거

### §5.1 `tenant_status`·`isolation_state` 참조 함수 전수

| 함수 | `tenant_status` | `isolation_state` | prosecdef | search_path | proacl |
|---|---|---|---|---|---|
| `catchmenu_common.get_hq_dashboard(text)` | 참조 | 미참조 | true | `catchmenu_common, catchmenu_hq` | `postgres`, `service_role` |
| `catchmenu_common.get_saas_revenue_report(date,date,text)` | 참조 | 미참조 | true | `catchmenu_common, catchmenu_hq` | `postgres`, `service_role` |
| `catchmenu_common.get_system_health_all(text)` | 참조 | 미참조 | true | `catchmenu_common, catchmenu_hq` | `postgres`, `service_role` |
| `catchmenu_common.get_tenant_list(text,text,text,integer,integer,text)` | 참조 | 미참조 | true | `catchmenu_common, catchmenu_hq` | `postgres`, `service_role` |
| `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` | 참조·WRITE 문자열 관측 | 미참조 | true | `catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` | `postgres`, `authenticated` |
| `catchmenu_common.manage_subscription(uuid,text,text,text,uuid,text)` | 참조·WRITE 문자열 관측 | 미참조 | true | `catchmenu_common, catchmenu_hq, catchmenu_ledger` | `postgres`, `service_role` |
| `catchmenu_common.provision_tenant(text,text,text,text,text,text,text,text,text,text,text)` | 참조·INSERT 문자열 관측 | 미참조 | true | `catchmenu_common, catchmenu_hq, catchmenu_store, catchmenu_ledger` | `postgres`, `authenticated` |

함수 수는 `tenant_status` 7건, `isolation_state` 0건이다. `provision_tenant`는 호출하지 않았다.

### §5.2 `security_audit_log` 참조 함수 전수

| 함수 | 참조 형태 | prosecdef | search_path | proacl |
|---|---|---|---|---|
| `catchmenu_common.check_tenant_quota(uuid,text,integer,text)` | INSERT | true | `catchmenu_common` | `postgres`, `authenticated` |
| `catchmenu_common.enforce_rate_limit(uuid,text,integer,integer,text,text)` | INSERT | true | `catchmenu_common` | `postgres`, `authenticated` |
| `catchmenu_common.get_tenant_health(uuid,text)` | READ | true | `catchmenu_common, catchmenu_hq, catchmenu_pos, catchmenu_payment` | `postgres`, `authenticated` |
| `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` | INSERT | true | `catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` | `postgres`, `authenticated` |
| `catchmenu_common.register_device(uuid,uuid,text,text,text,text,text,text,text)` | INSERT | true | `catchmenu_common, catchmenu_store, catchmenu_ledger, catchmenu_hq` | `postgres`, `authenticated` |
| `catchmenu_common.run_integration_test(uuid,uuid,text,text)` | READ | true | `catchmenu_common, catchmenu_pos, catchmenu_kds, catchmenu_payment, catchmenu_store, catchmenu_knowledge` | `postgres`, `authenticated` |
| `catchmenu_common.run_saas_launch_checklist(uuid,uuid,text)` | READ | true | `catchmenu_common, catchmenu_hq, catchmenu_pos, catchmenu_kds, catchmenu_payment, catchmenu_store, catchmenu_knowledge, catchmenu_integrations` | `postgres`, `authenticated` |
| `catchmenu_common.run_security_audit(uuid,uuid,text,text)` | INSERT | true | `catchmenu_common, catchmenu_hq, catchmenu_store` | `postgres`, `authenticated` |
| `catchmenu_common.verify_device_trust(uuid,uuid,uuid,text,text)` | INSERT | true | `catchmenu_common, catchmenu_store` | `postgres`, `authenticated` |
| `catchmenu_integrations.confirm_toss_payment_legacy_604260(uuid,uuid,text,text,integer,jsonb,text,text)` | INSERT | true | `catchmenu_integrations, catchmenu_payment, catchmenu_common` | `postgres` |
| `catchmenu_integrations.process_toss_webhook(uuid,uuid,text,jsonb,text,text)` | INSERT | true | `catchmenu_integrations, catchmenu_common` | `postgres`, `authenticated` |
| `catchmenu_payment.confirm_payment_webhook(uuid,uuid,jsonb,text,text)` | INSERT | true | `catchmenu_payment, catchmenu_common` | `postgres`, `authenticated` |

본문 문자열 기준 참조 함수는 12건이며 INSERT 형태는 9건, READ 형태는 3건이다.

### §5.3 `idempotency_keys` 참조 함수 전수

| 함수 | 참조 형태 | prosecdef | search_path | proacl |
|---|---|---|---|---|
| `catchmenu_integrations.intake_delivery_order(uuid,uuid,text,text,jsonb,uuid,text)` | INSERT | true | `catchmenu_integrations, catchmenu_gateway, catchmenu_pos, catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common, catchmenu_hq` | `postgres`, `authenticated` |

참조 함수는 1건이다. isolation transition 함수의 참조는 0건이다.

### §5.4 트리거

| 대상 테이블 | 트리거 | 함수 | 정의 |
|---|---|---|---|
| `catchmenu_hq.tenants` | `trg_tenants_updated_at` | `catchmenu_common.set_updated_at()` | BEFORE UPDATE, FOR EACH ROW |

나머지 대상 4테이블의 사용자 트리거는 0건이다. `trg_tenants_updated_at`은 모든 tenants UPDATE에 실행되며 `updated_at`을 갱신한다. `tenant_status` 또는 `isolation_state` 전이를 구분하는 WHEN 조건은 없다.

### §5.5 실행 제외

| 함수군 | D 기록 |
|---|---|
| `isolate_tenant`, `manage_subscription`, `detect_threat`, `verify_security_token`, `gateway_audit_entry`, `record_van_transaction`, `check_staff_permission` | 미검증 — 호출 금지(`601505` §4) |
| `provision_tenant`, `create_franchise_store`, `onboard_tenant` | 미검증 — 추가 호출 금지 |

## §6 C5 — TI-N 대 실측 간극표

| TI-N | 요구 | 현재 강제 | 간극 |
|---|---|---|---|
| `TI-1` | 원천 정책 3건 직접 구속 | 측정 불가 | 정책 채택 지위는 DB schema 속성이 아님 |
| `TI-2` | tenant-wide 2값과 scoped containment 책임 분리 | 2값 CHECK만 강제 | 별도 scoped containment·escalation 강제 객체 0건 |
| `TI-3` | 두 발동 주체 class와 `AUTHORITY_ALLOWED` | 강제되지 않음 | `authenticated` EXECUTE 존재; authority-state 검사 0건 |
| `TI-4` | 자동 단독 해제·동일 발동자 단독 승인 금지 | 강제되지 않음 | actor 분리·evidence·다자 승인 검사 0건 |
| `TI-5` | 발동·해제 권한 비대칭 | 강제되지 않음 | 단일 boolean 분기 함수와 단일 ACL |
| `TI-6` | stable action identity 기반 server key 파생 | 강제되지 않음 | isolation 함수의 idempotency 참조 0건 |
| `TI-7` | 두 merchant identity domain 분리와 mapping | 별도 컬럼·타입만 존재 | 두 identity 사이 mapping 제약 0건 |
| `TI-8` | action별 scope envelope와 누락 시 mutation 금지 | 일부 테이블 RLS·FK만 존재 | transition 전반의 authority/policy/evidence scope 검사 0건 |
| `TI-9` | contamination 발동 사유와 scope별 escalation | threat type 값만 존재 | threat와 isolation transition 연결·escalation 검사 0건 |
| `TI-10` | 격리 audit context 전건 | 일부 명명 컬럼과 자유형 JSONB | 누락 명명 필드 및 JSON key CHECK 0건 |
| `TI-11` | Stage 7 전 §24 11항 선언 | 측정 불가 | 승인 문서 선언은 DB schema 측정 대상이 아님 |

간극을 채우는 방법은 기록하지 않았다.

## §7 실행 쿼리 전문

아래 쿼리는 모두 `PGOPTIONS="-c default_transaction_read_only=on"` 세션에서 실행했다.

```sql
SHOW default_transaction_read_only;
SELECT current_timestamp;
SELECT version();

SELECT count(*) FILTER (WHERE success), max(applied_at),
       (SELECT filename FROM catchmenu_meta.migration_history
        ORDER BY applied_at DESC LIMIT 1)
FROM catchmenu_meta.migration_history;

WITH tabs(s,t) AS (VALUES
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
SELECT n.nspname,c.relname,pg_get_userbyid(c.relowner),
       c.relrowsecurity,c.relforcerowsecurity
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN tabs x ON x.s=n.nspname AND x.t=c.relname;

WITH tabs(s,t) AS (VALUES
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
SELECT n.nspname,c.relname,k.conname,k.contype,
       pg_get_constraintdef(k.oid,true),cardinality(k.conkey),
       CASE WHEN k.confrelid<>0 THEN k.confrelid::regclass END,
       k.confupdtype,k.confdeltype
FROM pg_constraint k JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN tabs x ON x.s=n.nspname AND x.t=c.relname
ORDER BY n.nspname,c.relname,k.contype,k.conname;

SELECT schemaname,tablename,indexname,indexdef
FROM pg_indexes
WHERE (schemaname,tablename) IN (
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
ORDER BY schemaname,tablename,indexname;

SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check
FROM pg_policies
WHERE (schemaname,tablename) IN (
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
ORDER BY schemaname,tablename,policyname;

SELECT table_schema,table_name,grantee,privilege_type,is_grantable
FROM information_schema.role_table_grants
WHERE (table_schema,table_name) IN (
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
ORDER BY table_schema,table_name,grantee,privilege_type;

SELECT rolname,rolsuper,rolcanlogin,rolbypassrls
FROM pg_roles
WHERE rolname IN ('postgres','anon','authenticated','service_role')
ORDER BY rolname;

SELECT r.role_name,t.table_name,
       has_table_privilege(r.role_name,t.table_name,'SELECT'),
       has_table_privilege(r.role_name,t.table_name,'INSERT'),
       has_table_privilege(r.role_name,t.table_name,'UPDATE'),
       has_table_privilege(r.role_name,t.table_name,'DELETE')
FROM (VALUES ('anon'),('authenticated'),('service_role'),('postgres')) r(role_name)
CROSS JOIN (VALUES
 ('catchmenu_hq.tenants'),
 ('catchmenu_common.security_threats'),
 ('catchmenu_common.security_audit_log'),
 ('catchmenu_common.idempotency_keys'),
 ('catchmenu_common.offline_queue')
) t(table_name);

SELECT n.nspname,p.proname,p.oid::regprocedure,
       p.prosrc ILIKE '%tenant_status%',
       p.prosrc ILIKE '%isolation_state%',
       p.prosrc ILIKE '%security_audit_log%',
       p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+(catchmenu_common[.])?security_audit_log',
       p.prosrc ILIKE '%idempotency_keys%',
       p.prosrc ~* 'insert[[:space:]]+into[[:space:]]+(catchmenu_common[.])?idempotency_keys',
       p.prosecdef,p.proconfig,p.proacl
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ILIKE '%tenant_status%'
   OR p.prosrc ILIKE '%isolation_state%'
   OR p.prosrc ILIKE '%security_audit_log%'
   OR p.prosrc ILIKE '%idempotency_keys%'
ORDER BY n.nspname,p.proname;

WITH tabs(s,t) AS (VALUES
 ('catchmenu_hq','tenants'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys'),
 ('catchmenu_common','offline_queue')
)
SELECT n.nspname,c.relname,tg.tgname,tg.tgfoid::regprocedure,
       pg_get_triggerdef(tg.oid,true)
FROM pg_trigger tg JOIN pg_class c ON c.oid=tg.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN tabs x ON x.s=n.nspname AND x.t=c.relname
WHERE NOT tg.tgisinternal
ORDER BY n.nspname,c.relname,tg.tgname;

SELECT table_schema,table_name
FROM information_schema.tables
WHERE table_schema LIKE 'catchmenu%'
  AND (table_name ILIKE '%isolat%' OR table_name ILIKE '%contain%'
       OR table_name ILIKE '%circuit%' OR table_name ILIKE '%quarant%');

SELECT table_schema,table_name,column_name
FROM information_schema.columns
WHERE table_schema LIKE 'catchmenu%'
  AND (column_name ILIKE '%isolat%' OR column_name ILIKE '%contain%'
       OR column_name ILIKE '%circuit%' OR column_name ILIKE '%quarant%');

SELECT table_schema,table_name,column_name,data_type
FROM information_schema.columns
WHERE table_schema LIKE 'catchmenu%'
  AND column_name IN ('merchant_id','merchant_account_id')
ORDER BY table_schema,table_name,column_name;

SELECT conrelid::regclass,conname,pg_get_constraintdef(oid,true)
FROM pg_constraint
WHERE pg_get_constraintdef(oid,true) ILIKE '%merchant_id%'
   OR pg_get_constraintdef(oid,true) ILIKE '%merchant_account_id%';

SELECT
 count(*) FILTER (WHERE prosrc ILIKE '%AUTHORITY_ALLOWED%'),
 count(*) FILTER (WHERE prosrc ILIKE '%AUTHORITY_REVIEW_REQUIRED%'),
 count(*) FILTER (WHERE prosrc ILIKE '%AUTHORITY_MULTI_PARTY_REQUIRED%'),
 count(*) FILTER (WHERE prosrc ILIKE '%stable_action_identity%'),
 count(*) FILTER (WHERE prosrc ILIKE '%cross-tenant contamination%'
                  OR prosrc ILIKE '%cross_tenant_contamination%')
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname LIKE 'catchmenu%';
```

실행하지 않은 함수:

```text
isolate_tenant
manage_subscription
detect_threat
verify_security_token
gateway_audit_entry
record_van_transaction
check_staff_permission
provision_tenant
create_franchise_store
onboard_tenant
```

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 사용 |
|---|---|
| `601901_Register_Stage0_Evidence_Collection.md` | 원천 8건 채록 및 Pass 2 실측 비교 |
| `601902_Register_Stage1_Business_Rules.md` | `TI-1`~`TI-11` 요구 원문 |
| live PostgreSQL catalog | C1~C4 read-only 실측 |

`601803`과 `601903`은 열람하지 않았다.
