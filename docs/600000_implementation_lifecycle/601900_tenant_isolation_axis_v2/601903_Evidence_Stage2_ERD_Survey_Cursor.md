# 601903_Evidence_Stage2_ERD_Survey_Cursor.md

Status: Active
Lifecycle: Evidence
Last Updated: 2026-09-02

## §0 성격

`000701` §47.1 2단계 — Cursor 조사 산출물이다.

```text
조사만 한다. ERD 를 그리지 않는다.
결론 · 판정 · 물리명 제안을 하지 않는다.
601803 을 열지 않았다.
입력은 601902 · 601901 만이다.
```

DocumentType: `Evidence`

## §1 측정 환경

| 항목 | 실측값 |
|---|---|
| 컨테이너 이름 | `supabase_db_yoonsul_wait_order_handoff` |
| 컨테이너 ID | `b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec` |
| 이미지 | `public.ecr.aws/supabase/postgres:17.6.1.156` |
| DB version | `PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit` |
| 측정 시각 (UTC) | `2026-09-02 13:23:46.432266+00` |
| `SHOW default_transaction_read_only` | `on` |
| 최신 migration | `0171_merchant_account_foundation.sql`, success=`true`, applied_at=`2026-08-30 11:46:47.552241+00` |
| 접속 | `docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i ... psql -v ON_ERROR_STOP=1 -U postgres -d postgres` |
| 금지 함수 호출 | 0건 |
| 쓰기 쿼리 | 0건 |
| `601803` 열람 | 하지 않음 |

`601901` Pass 2 (§16~§21) 의 catalog 실측과 이번 세션 S3 재측정을 병기한다.
수치가 다르면 이 문서 §4 에 이번 세션 값을 우선 기록한다.

## §2 S1 — TI-N 이 요구하는 정보 요소

개념 수준만 적는다. 물리 테이블 · 컬럼 · 제약명을 붙이지 않는다.

### TI-1 — Source Doctrine 채택

| # | 알아야 할 정보 요소 |
|---|---|
| TI-1-a | 이 나선이 직접 구속으로 삼는 정책 집합 (`010630` · `010650` · `010660` + `600021` §2 의 5건) |
| TI-1-b | A3 reference 로 남는 정책 집합과 재개방 조건 |
| TI-1-c | 구속 채택의 Human 선언 식별자 (`HD-0-A-2R-1`) |

### TI-2 — tenant-wide isolation 과 scoped containment 의 책임 분리

| # | 알아야 할 정보 요소 |
|---|---|
| TI-2-a | tenant-wide isolation 상태값 집합 (`NONE` · `ISOLATED`) |
| TI-2-b | 그 상태가 tenant 전체에만 적용된다는 경계 |
| TI-2-c | 부분 containment 의 scope 후보 (store · route · device · actor · session · provider) |
| TI-2-d | 부분 containment 가 tenant-wide 와 별도 representation 이라는 분리 |
| TI-2-e | 부분 → tenant-wide escalation 이 별도 규칙이며 자동이 아니라는 사실 |
| TI-2-f | scoped containment 물리 표현이 Stage 4 소관이라는 유보 |

### TI-3 — 격리 발동 권한

| # | 알아야 할 정보 요소 |
|---|---|
| TI-3-a | 발동 허용 주체 둘 — automatic platform/security system · authorized platform-security Human |
| TI-3-b | 발동 금지 주체 — 일반 tenant user · store staff · support |
| TI-3-c | automatic 발동에 필요한 조건 — policy-defined trigger · evidence · tenant scope · idempotency · audit |
| TI-3-d | authority gate 결과 — 실행 허용은 `AUTHORITY_ALLOWED` 만 |
| TI-3-e | 실행 금지 gate 결과 — `AUTHORITY_REVIEW_REQUIRED` · `AUTHORITY_MULTI_PARTY_REQUIRED` |
| TI-3-f | `AUTHORITY_PARTIAL_ALLOWED` 와 scoped containment 관계는 열린 질문 (OQ-1) |

### TI-4 — 격리 해제 권한

| # | 알아야 할 정보 요소 |
|---|---|
| TI-4-a | 원인 · 위험 해소 evidence |
| TI-4-b | explicit Human authority |
| TI-4-c | tenant scope 검증 |
| TI-4-d | audit |
| TI-4-e | 필요 시 independent / multi-party approval |
| TI-4-f | 수동 발동 actor 와 release approver 의 비동일성 (자기 단독 해제 금지) |
| TI-4-g | 자동 단독 해제 금지 |
| TI-4-h | role ID · approver 수는 Stage 4 · `0-C` 유보 |

### TI-5 — 발동과 해제의 비대칭

| # | 알아야 할 정보 요소 |
|---|---|
| TI-5-a | 발동 목적 — 확산 방지 · 신속성 · 자동화 허용 |
| TI-5-b | 해제 목적 — 재신뢰 · 더 높은 위험 · TI-4 요건 |
| TI-5-c | 자동 발동 주체가 해제 권한을 자동 상속하지 않는다는 사실 |

### TI-6 — idempotency key 파생

| # | 알아야 할 정보 요소 |
|---|---|
| TI-6-a | stable action identity 입력 — automatic 경로의 trigger_event_id 또는 evidence_packet_id |
| TI-6-b | stable action identity 입력 — Human/manual 경로의 command_request_id 또는 authority_decision_id |
| TI-6-c | 신뢰 경계 안에서의 검증 단계 |
| TI-6-d | canonical key 파생 입력 집합 — tenant_id · operation · target identity · stable action identity · payload_hash · policy_version |
| TI-6-e | caller 가 canonical key 를 자유롭게 지정하지 않는다는 사실 |
| TI-6-f | 파라미터명 · 타입 · hash 조합 · 기존 함수 유지는 Stage 4 유보 |

### TI-7 — merchant 어휘 구분

| # | 알아야 할 정보 요소 |
|---|---|
| TI-7-a | provider-side merchant identifier (`010640` merchant_id) |
| TI-7-b | CatchMenu SaaS 고객 관계 (`000170` Merchant Account) |
| TI-7-c | 두 identity domain 이 별개라는 사실 |
| TI-7-d | provider event 의 merchant_id 를 tenant · store · legal entity · provider mapping 으로 내부 context 에 연결한다는 규칙 |
| TI-7-e | 물리 컬럼 · FK 는 Stage 4 유보 |

### TI-8 — scope envelope 의무 강도

| # | 알아야 할 정보 요소 |
|---|---|
| TI-8-a | scope envelope 존재 의무 (MUST) |
| TI-8-b | 해당 action 에 필요한 scope dimension 의무 (MUST) |
| TI-8-c | `010640` §5 전 후보 필드 무조건 보유는 NOT REQUIRED |
| TI-8-d | applicable 하지 않은 dimension 생략 가능 |
| TI-8-e | 필요한 scope 누락 시 처리 · mutation 금지 |
| TI-8-f | tenant isolation transition 에 적용되는 context 묶음 — tenant scope · actor/system identity · authority · policy · evidence · audit |
| TI-8-g | store · legal entity · provider 는 사건이 그 scope 에 걸릴 때 필수 |
| TI-8-h | 「필드」가 반드시 DB 컬럼을 뜻하지 않음 · 물리 운반은 Stage 4 유보 |

### TI-9 — 격리 발동 사유에 cross-tenant contamination

| # | 알아야 할 정보 요소 |
|---|---|
| TI-9-a | contamination 탐지 유형 — unexpected tenant id · wrong-tenant vector · export row scope mismatch · audit context missing 등 (`010004` §20) |
| TI-9-b | 그러한 탐지가 격리 발동 사유로 인정된다는 사실 |
| TI-9-c | tenant-wide 보다 작은 containment action — projection block · export disable · vector retrieval disable |
| TI-9-d | 작은 action 은 scoped containment 책임이며 자동 승격되지 않음 |
| TI-9-e | 어느 오염 유형이 tenant-wide escalate 인지는 Stage 4 · OQ-2 유보 |

### TI-10 — 격리 전이의 audit 필드

| # | 알아야 할 정보 요소 |
|---|---|
| TI-10-a | audit 에 남겨야 할 항목 — tenant id · store id · actor id · actor role · surface · device · target object id · type · action · previous scope · new scope · authority reference · policy reference · evidence reference (`010004` §19) |
| TI-10-b | isolation_state 변경이 「new scope if changed」 사건이라는 사실 |
| TI-10-c | 발동 · 해제 모두 위 항목을 감사 가능하게 남긴다는 의무 |
| TI-10-d | 기존 audit 자산에 일부만 있다는 Pass 2 관측 (아래 §3) |
| TI-10-e | 기존 확장 vs 별도 표현은 Stage 4 유보 · 「필드」≠ 반드시 DB 컬럼 |

### TI-11 — `010004` §24 게이트 판정

| # | 알아야 할 정보 요소 |
|---|---|
| TI-11-a | `010004` §26 · §29 가 runtime 구현을 유보했다는 사실 |
| TI-11-b | §24 11항 선언이 해제 조건이라는 사실 |
| TI-11-c | 이 나선이 §24 적용 대상이라는 Human 판정 |
| TI-11-d | 11항 구체 선언 내용은 Stage 4 산출물 후 Stage 7 승인 문서에 기록 · 이 단계에서는 채우지 않음 |
| TI-11-e | `601901` 에 §24 원문 11항이 채록되어 있다는 사실 |

## §3 S2 — 기존 자산 수용 가능성

대상 자산 (조사 지정):

```text
catchmenu_hq.tenants                  tenant_status · isolation_state
catchmenu_common.security_threats
catchmenu_common.security_audit_log
catchmenu_common.idempotency_keys
catchmenu_common.offline_queue
```

> 문구 규칙: 「새로 만들어야 한다」고 쓰지 않는다.
> 「기존 자산에서 확인되지 않는다」로만 쓴다.

| TI 정보 요소 | 수용 | 관측 |
|---|---|---|
| TI-2-a tenant-wide 상태 `NONE`/`ISOLATED` | 기존 자산에 있다 | `tenants.isolation_state` CHECK 2값. 이번 실측 · `601901` §17.1 일치 |
| TI-2-b tenant 전체 적용 경계 | 부분적으로 있다 | 상태 컬럼은 tenant 행에 있다. scoped containment 별도 representation 은 기존 자산에서 확인되지 않는다 |
| TI-2-c~e scoped containment / escalation | 기존 자산에서 확인되지 않는다 | `security_threats.block_scope` · store/device 컬럼은 있으나 TI-2 가 말하는 별도 scoped containment representation · escalation rule 저장소로는 확인되지 않는다 |
| TI-3-a~b 발동 주체 구분 | 기존 자산에서 확인되지 않는다 | authority gate 결과 · actor 유형을 강제하는 컬럼/제약이 지정 5자산에서 확인되지 않는다. `601901` §21.1 — 금지 7함수 prosrc 에 authority/capability 문자열 0건 |
| TI-3-c evidence · idempotency · audit 조건 | 부분적으로 있다 | evidence 패킷 전용 자산은 지정 목록에서 확인되지 않는다. `idempotency_keys` · `security_audit_log` 는 존재. trigger↔evidence↔audit 를 한 전이로 묶는 표현은 확인되지 않는다 |
| TI-3-d~e AUTHORITY_* 상태 | 기존 자산에서 확인되지 않는다 | `601901` §21.1 — `SCOPE_*` 상태 문자열 포함 함수 0건. AUTHORITY_* 컬럼도 지정 자산에서 확인되지 않는다 |
| TI-4-a 해소 evidence | 기존 자산에서 확인되지 않는다 | release evidence 전용 필드가 지정 자산에서 확인되지 않는다. `security_threats.resolution_note` · `resolved_by` 는 threat 해소용이며 TI-4 의 isolation release evidence 와 동일 개념으로 확인되지 않는다 |
| TI-4-b~e Human authority · scope · audit · multi-party | 부분적으로 있다 | audit 로그 자산은 있다. Human authority · multi-party approval · release actor≠initiator 강제 표현은 지정 자산에서 확인되지 않는다 |
| TI-4-g 자동 단독 해제 금지 | 기존 자산에서 확인되지 않는다 | 상태 컬럼만으로는 해제 경로 권한 비대칭이 표현되지 않는다. `601901` §18 — `isolate_tenant` 가 `p_isolate boolean` 로 양방향 경로를 갖는다는 catalog 사실만 있다 (함수 호출은 하지 않음) |
| TI-5 비대칭 | 기존 자산에서 확인되지 않는다 | 발동/해제 권한 비대칭을 담는 전용 표현이 지정 자산에서 확인되지 않는다 |
| TI-6-a~b stable action identity | 부분적으로 있다 | `idempotency_keys` 에 `idempotency_key` · `provider_event_id` · `correlation_id` · `request_hash` 등이 있다. trigger_event_id / evidence_packet_id / command_request_id / authority_decision_id 라는 이름의 입력 슬롯은 확인되지 않는다 |
| TI-6-d canonical 파생 입력 집합 | 부분적으로 있다 | tenant_id · operation_type · request_hash 는 있다. target identity · stable action identity · policy_version 전용 컬럼은 확인되지 않는다. UNIQUE 는 `(tenant_id, key_domain, idempotency_key)` |
| TI-6-e caller 가 key 를 지정하지 않음 | 기존 자산에서 확인되지 않는다 | 테이블 스키마만으로는 파생 주체가 강제되지 않는다 |
| TI-7 merchant 어휘 구분 | 기존 자산에서 확인되지 않는다 | 지정 5자산에 provider merchant_id / Merchant Account 구분 표현이 없다. `601901` §4 는 `0171_merchant_account_foundation.sql` 존재를 별도 기록하나 이번 S2 지정 목록 밖이다 |
| TI-8 scope envelope | 부분적으로 있다 | tenant_id / store_id / device_id 가 자산마다 다르게 존재 (`601901` §20.1 · 이번 실측). authority · policy · evidence · audit context 를 envelope 로 묶는 표현은 확인되지 않는다 |
| TI-9 contamination 발동 사유 | 부분적으로 있다 | `security_threats.threat_type` CHECK 에 `TENANT_BOUNDARY_VIOLATION` · `EXTERNAL_CONTAMINATION` 등이 있다. `010004` §20 유형 전부와 tenant-wide escalate 판정 표현은 확인되지 않는다 |
| TI-9-c 작은 containment action | 부분적으로 있다 | `security_threats.block_scope` · `auto_blocked` 존재. projection/export/vector disable 전용 표현은 지정 자산에서 확인되지 않는다 |
| TI-10 audit 필드 전부 | 부분적으로 있다 | `security_audit_log` 에 tenant_id · store_id · actor_id · actor_type · resource_type · resource_id · audit_event · event_detail 등 존재. **확인되지 않는 항목** — actor role · authority reference · policy reference · evidence reference · previous scope · new scope · surface/device (전용 컬럼명). `601901` §21.1 · TI-10 본문과 일치 |
| TI-11 §24 게이트 | 기존 자산에서 확인되지 않는다 | 문서 · Human 판정 영역. DB 자산으로 §24 11항 선언을 담는 구조는 지정 목록에서 확인되지 않는다 |
| TI-1 Source Doctrine | 기존 자산에서 확인되지 않는다 | 문서 · Register 영역 |

### S2 보조 관측 — `tenants` 상태축 (이번 실측)

| 컬럼 | nullable | default | CHECK |
|---|---|---|---|
| `tenant_status` | NO | `'TRIAL'` | ACTIVE · TRIAL · SUSPENDED · CANCELLED · TERMINATED |
| `isolation_state` | NO | `'NONE'` | NONE · ISOLATED |

`601901` §17.2: `isolation_state` 를 prosrc 에서 참조하는 FUNCTION **0건**.

## §4 S3 — 기존 관계

측정 대상: `tenants` ↔ `security_threats` · `security_audit_log` · `idempotency_keys` (및 지정된 `offline_queue`).

### §4.1 tenants ← 자산 FK (방향: 자산 → tenants)

| 자산 | FK 유무 | conname | 방향 | 단일/복합 | 정의 |
|---|---|---|---|---|---|
| `security_threats` | **없음 (0건)** | — | — | — | `tenant_id` 컬럼은 있으나 nullable · FK 0건 (`601901` §20.1 · 이번 실측) |
| `security_audit_log` | 있음 | `security_audit_log_tenant_id_fkey` | audit → tenants | 단일 `tenant_id` | `FOREIGN KEY (tenant_id) REFERENCES catchmenu_hq.tenants(id)` |
| `idempotency_keys` | 있음 | `idempotency_keys_tenant_id_fkey` | idempotency → tenants | 단일 `tenant_id` | 동일 패턴 |
| `offline_queue` | 있음 | `offline_queue_tenant_id_fkey` | queue → tenants | 단일 `tenant_id` | 동일 패턴 |

역방향 (tenants → 위 자산) FK: **0건**.

### §4.2 부가 FK (tenant 일치 강제 여부 관측용)

| 자산 | FK | 대상 | 컬럼 수 |
|---|---|---|---|
| `idempotency_keys` | `idempotency_keys_store_id_fkey` | `catchmenu_hq.stores(id)` | 1 |
| `idempotency_keys` | `idempotency_keys_source_device_id_fkey` | `catchmenu_store.device_registry(id)` | 1 |
| `offline_queue` | `offline_queue_store_id_fkey` | `catchmenu_hq.stores(id)` | 1 |
| `security_audit_log` | store FK | — | **0건** (`store_id` nullable · FK 없음) |
| `security_threats` | store/device FK | — | **0건** |

복합 FK (`tenant_id`+`store_id` 동시 참조로 tenant 일치 강제): 위 4자산에서 **0건**.
모든 관측 FK 의 `fk_col_count` = 1.

### §4.3 UNIQUE / tenant scope

| 자산 | 관측 |
|---|---|
| `idempotency_keys` | `UNIQUE (tenant_id, key_domain, idempotency_key)` — tenant 포함. `store_id` 는 UNIQUE 구성열 아님 |
| 기타 3자산 | tenant 일치 강제 UNIQUE/복합 FK 없음 |

### §4.4 S6-7 관련 사실 기록

`601902` §2 S6-7: 「새 isolation 관련 객체가 여러 tenant identifier 를 가질 경우 cross-tenant inconsistent relation 을 허용하지 않는다.」

기존 자산에서 관측된 사실:

```text
tenant_id FK 와 store_id FK 가 각각 단일 컬럼으로 분리된 곳이 있다
(idempotency_keys · offline_queue).
두 FK 를 묶어 store 의 tenant 와 row 의 tenant 일치를 강제하는
복합 제약은 이번 측정에서 0건이다.
security_threats 는 tenant_id FK 자체가 0건이다.
```

판정하지 않는다. ERD 착수 시 S6-7 대조 근거로만 남긴다.

## §5 S4 — 인접 도메인 접점

출처: `601901` §10.2 에 채록된 `601702` 원문.
`601702` 원본 파일은 이 작업에서 추가로 열지 않았다.
충돌 여부를 판정하지 않는다. 접점만 기록한다.

### §5.1 `601702` §1.26 — Store 구조 부모

채록 요지 (`601901` §10.2):

```text
Tenant 1:1 MerchantAccount 1:N Store
Tenant 는 Store 의 두 번째 구조 부모가 아니라 필수 격리 scope
모든 Store 는 Tenant scope 를 보유·검증
```

`TI-2` scope 후보와의 접점:

| TI-2 scope 후보 | 접점 기록 |
|---|---|
| store | §1.26 이 Store 를 MerchantAccount 자식 · Tenant 격리 scope 로 둔다. TI-2 의 store scoped containment 후보는 이 Store 축과 만난다 |
| (기타) | §1.26 본문은 route · device · actor · session · provider 를 열거하지 않는다 |

### §5.2 `601702` §1.27 — Store 상태 3축

채록 요지: Store Service Status · Store Operating Status · Trial Status 를 독립 개념으로 구분.

접점:

```text
TI-2 의 tenant-wide isolation_state 와
§1.27 의 Store 상태 3축은 서로 다른 질문이다.
601702 §1.28 이 IsolationState 를 상위 상태 대체물로 쓰지 말라고 명시한다
(아래 §5.3).
```

### §5.3 `601702` §1.28 — 계층 상태 분리

채록 요지:

```text
TenantStatus ≠ MerchantAccountStatus ≠ StoreServiceStatus
≠ StoreOperatingStatus ≠ TrialStatus ≠ IsolationState
상위 상태로 하위 상태를 대체하지 않는다
```

접점:

```text
TI-2 가 tenant.isolation_state 를 tenant-wide 만으로 제한한 것과
§1.28 의 IsolationState 독립 축 선언이 같은 분리 계열로 만난다.
scoped containment 를 Store 상태 3축에 흡수하는지 여부는
이 조사에서 판정하지 않는다.
```

### §5.4 `601702` §1.42 · §1.43 — 네 시스템 경계 · provider

`601901` §10.1 heading:

```text
§1.42  네 시스템의 경계를 어휘로 고정한다
§1.43  외부 시스템 연결은 CM-PLAT 의 tenant/store 경계에 귀속된다
```

§1.43 채록 요지 (`601901` §10.2):

```text
외부 provider credential · merchant/store mapping 은 플랫폼 구조의 일부
연결은 tenant/store 단위로 귀속
```

접점:

| TI-2 scope 후보 | 접점 기록 |
|---|---|
| provider | §1.43 이 provider mapping 을 tenant/store 귀속으로 둔다. TI-2 provider scoped containment · TI-7 merchant 어휘와 만난다 |
| store | tenant/store 단위 귀속이 TI-2 store scope · TI-8 store dimension 과 만난다 |
| route · device · actor · session | §1.42·§1.43 채록 범위에서는 직접 열거되지 않음 (`601901` heading/요지 기준) |

### §5.5 TI-7 과의 인접

`601902` TI-7: provider-side merchant_id ≠ SaaS Merchant Account.
`601702` §1.22 (`601901` §10.2): Tenant ≠ MerchantAccount (이번 나선 1:1).
`601702` §1.43: provider mapping 은 tenant/store 귀속.

접점만 기록한다. 동일 식별자 취급 여부는 판정하지 않는다.

## §6 S5 — ERD 착수 전 선결 항목

아래는 `601902` §6 OQ · `601901` §14 Q-P 중,
**2단계 ERD 가 개념 경계를 그리려면 먼저 정해져야 하는 것**만 표시한다.
정하지 않는다.

| # | 출처 | 내용 | ERD 선결로 표시하는 이유 (사실) |
|---|---|---|---|
| P-1 | OQ-1 | `AUTHORITY_PARTIAL_ALLOWED` 가 scoped containment 를 허용하는가 | TI-2 / TI-3 경계 — scoped representation 을 ERD 에 넣을지 tenant-wide 만 그릴지 갈림 |
| P-2 | OQ-2 | `010004` §20 어느 오염 유형이 tenant-wide escalate 인가 | TI-9 — contamination → tenant-wide vs scoped 화살표 대상 |
| P-3 | OQ-3 | `010650` §38 anti-pattern 중 이 나선 강제 범위 | TI-4 / TI-5 — release · 자기해제 금지 등 관계 강도 |
| P-4 | TI-2-f · HD-0-A-2R-2 | scoped containment 물리 표현은 Stage 4 소관 | ERD 가 scoped 박스를 그릴지 · 점선 유보로 둘지 |
| P-5 | TI-4-h | role ID · approver 수 · EXECUTE ACL 은 Stage 4 · `0-C` | authority actor 노드 세밀도 |
| P-6 | TI-6-f | idempotency 파라미터 · hash · 기존 함수 유지 | idempotency 기록과 transition 의 연결 방식 |
| P-7 | TI-7-e | provider merchant mapping 물리 구조 | TI-7 연결 화살표의 앵커 |
| P-8 | TI-8-h · TI-10-e | 「필드」의 물리 운반 (컬럼 vs 패킷 vs 로그) | audit · envelope 를 어느 자산 상자에 붙일지 |
| P-9 | TI-10 · `601901` Pass 2 | audit 결측 항목을 기존 로그 확장 vs 병행 표현 | TI-10 상자 개수 · 관계 |
| P-10 | TI-11 | §24 11항 선언은 Stage 7 전 · Stage 4 후 | ERD 본문이 아니라 게이트 체크리스트이나 runtime 범위 표시에 영향 |
| P-11 | Q-P9 (처분: TI-3·TI-4) | authority state ↔ 발동·해제 canonical 매핑의 물리 주체 | TI-3/4 swimlane |
| P-12 | Q-P10 (처분: TI-2) | `010650` containment 단위 ↔ isolation_state 대응 | TI-2 상자 분해 |
| P-13 | Q-P11 (처분: TI-6) | key 제출 vs 파생 주체 | TI-6 화살표 방향 |

`601902` §3 이 governance 이월로 둔 Q-P1 · Q-P2 · Q-P3 · Q-P7 은
문서 provenance 문제이며 ERD 개념 경계 선결로 표시하지 않는다.

**§6 선결 표시 건수: 13건 (P-1 ~ P-13).**

## §7 실행 쿼리 전문

```sql
SHOW default_transaction_read_only;
SELECT now() AS measured_at;
SELECT version();
SELECT filename, success, applied_at
FROM catchmenu_meta.migration_history
ORDER BY applied_at DESC NULLS LAST
LIMIT 1;

SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='catchmenu_hq' AND table_name='tenants'
  AND column_name IN ('tenant_status','isolation_state')
ORDER BY ordinal_position;

SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid='catchmenu_hq.tenants'::regclass
  AND (pg_get_constraintdef(oid) ILIKE '%tenant_status%'
       OR pg_get_constraintdef(oid) ILIKE '%isolation_state%');

SELECT n.nspname AS fk_schema, c.relname AS fk_table, k.conname,
       pg_get_constraintdef(k.oid) AS def,
       (SELECT array_agg(a.attname ORDER BY x.n)
          FROM unnest(k.conkey) WITH ORDINALITY AS x(attnum,n)
          JOIN pg_attribute a ON a.attrelid=k.conrelid AND a.attnum=x.attnum) AS fk_cols,
       (SELECT array_agg(a.attname ORDER BY x.n)
          FROM unnest(k.confkey) WITH ORDINALITY AS x(attnum,n)
          JOIN pg_attribute a ON a.attrelid=k.confrelid AND a.attnum=x.attnum) AS ref_cols,
       nr.nspname AS ref_schema, cr.relname AS ref_table
FROM pg_constraint k
JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN pg_class cr ON cr.oid=k.confrelid
JOIN pg_namespace nr ON nr.oid=cr.relnamespace
WHERE k.contype='f'
  AND ((n.nspname='catchmenu_common'
        AND c.relname IN ('security_threats','security_audit_log','idempotency_keys','offline_queue')
        AND nr.nspname='catchmenu_hq' AND cr.relname='tenants')
    OR (nr.nspname='catchmenu_common'
        AND cr.relname IN ('security_threats','security_audit_log','idempotency_keys','offline_queue')
        AND n.nspname='catchmenu_hq' AND c.relname='tenants'))
ORDER BY fk_table, conname;

SELECT table_name, column_name, is_nullable, data_type
FROM information_schema.columns
WHERE table_schema='catchmenu_common'
  AND table_name IN ('security_threats','security_audit_log','idempotency_keys','offline_queue')
  AND column_name IN ('tenant_id','store_id','device_id')
ORDER BY table_name, column_name;

SELECT c.relname, k.conname, k.contype, pg_get_constraintdef(k.oid)
FROM pg_constraint k
JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='catchmenu_common'
  AND c.relname IN ('security_threats','security_audit_log','idempotency_keys','offline_queue')
  AND k.contype IN ('f','u','p','c')
ORDER BY c.relname, k.contype, k.conname;

SELECT c.relname, array_length(k.conkey,1) AS fk_col_count, pg_get_constraintdef(k.oid)
FROM pg_constraint k
JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='catchmenu_common'
  AND c.relname IN ('security_threats','security_audit_log','idempotency_keys','offline_queue')
  AND k.contype='f'
ORDER BY 1;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='catchmenu_common' AND table_name='security_audit_log'
ORDER BY ordinal_position;
```

`601901` §23 에 기록된 Pass 2 쿼리 전문도 동일 자산 catalog 근거로 참조한다.
이번 세션에서 금지 함수 · `provision_tenant` · `create_franchise_store` · `onboard_tenant` 는 호출하지 않았다.

## §8 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 지위 |
|---|---|---|
| `601902_Register_Stage1_Business_Rules.md` | TI-1~TI-11 · §2 S6 · §6 OQ · HD | ACTIVE — 입력 |
| `601901_Register_Stage0_Evidence_Collection.md` | Pass 1/1.5/2 실측 · §10.2 `601702` 채록 · §14 Q-P · §17~§21 | ACTIVE — 입력 |
| live PostgreSQL catalog (read-only) | §1 · §3 · §4 · §7 | 실측 |
| `000701` | §46 · §47.1 | ACTIVE — 절차 |
| `601803` | — | **열지 않음** |
| `601801` · `601809`~`601812` | — | 승계하지 않음 · 열지 않음 |
