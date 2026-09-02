# 601901_Register_Stage0_Evidence_Collection.md

Status: Active
Lifecycle: Register
Last Updated: 2026-09-02

## §0 용도 · baseline

| 항목 | 기록 |
|---|---|
| 용도 | `000701` §48 증거수집 |
| baseline commit | `e6573af57432ad7d496ae0a9ad5739047ecf0eec` |
| Pass 1 | 문서 축 — A1 5건 · A2 · A3 · A4 |
| Pass 1.5 | A3 중 3건을 A1으로 승격해 조사 |
| Pass 2 | 실측 축 — 완료(2026-09-02); B~E 재측정 |
| DB 접속 | read-only 접속·catalog/행 수 조회 수행; 금지 함수 호출 0건 |
| 문서 성격 | 사실 등록부. 판단·설계·Human Rule 생성 없음 |
| 조사 기준 | baseline commit의 blob과 tree |
| 조사 문서 수 | 50건 — provenance 대상 46건 + 통제문서 4건 |

> ⚠️ `601800`은 Human Rule을 앞에 놓았다.
> `601900`은 원천문서 증거 → DB 증거 → Human Rule 순서로 간다.

## §1 분류 기준 (`000701` §48.1)

| 분류 | 정의 | 이번 Pass |
|---|---|---|
| A | 문서만 존재 | 기록함 |
| B | SQL 객체 존재 | Pass 2 대기 |
| C | SQL 객체와 문서가 일치 | Pass 2 대기 |
| D | 로컬 DB에서 실행 검증 | Pass 2 대기 |
| E | 호출자·권한까지 포함한 통합 검증 | Pass 2 대기 |

## §2 금지사항 (`000701` §48.3 + 이번 Pass)

| # | 금지사항 | 수행 기록 |
|---:|---|---|
| 1 | 문서 존재를 구현 완료로 간주 | 하지 않음 |
| 2 | A~E를 생략하고 재사용 결론 도출 | 하지 않음; B~E는 `Pass 2 대기` |
| 3 | 대상별 표 없이 산문으로만 기록 | 하지 않음 |
| 4 | `601801`의 Human Rule 식별자를 정답으로 사용 | 하지 않음 |
| 5 | `601802` 값을 재측정 없이 복사 | 하지 않음 |
| 6 | `601816` finding을 설계 결론으로 변환 | 하지 않음 |
| 7 | source 문서의 `AUTHORITY SUSPENDED` 블록을 원천 정책으로 승격 | 하지 않음 |
| 8 | 새 업무규칙 생성 | 하지 않음 |

## §3 Source Provenance Inventory

### §3.1 A1 Mandatory Source Doctrine

`600021` §2가 강제한 5건이다.

| # | 정확한 경로 | 현재 지위 | 전체 절 구조 | 관련 절 | suspended block |
|---:|---|---|---|---|---|
| 1 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | 혼재 | Purpose; §2~§29 | §2~§7, §19~§21, §24~§25, §27, §29 | §4.1 내부 1개 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | ACTIVE | Purpose; §2~§42 | §2~§9, §15, §29~§38, §40~§42 | 없음 |
| 3 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | 혼재 | Purpose; 후대 개정 블록; 원 정책 §1~§33 | 원 정책 §3~§8, §12~§17, §20~§27, §31~§33 | L10의 후대 블록 내부 1개 |
| 4 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | 혼재 | Purpose; 원 정책 §1~§13; 후대 개정 블록; 원 정책 §14~§39 | 원 정책 §3~§16, §25~§33, §39 | L385의 후대 블록 내부 1개 |
| 5 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | ACTIVE | Purpose; 원 정책 §1~§37 | §3~§17, §20~§31, §37 | 없음 |

### §3.1' A1' Discovered Direct Source

`010640` §41에서 발견했고 직접 관련이 확인된 3건이다.
**`Stage 0`이 authority를 부여하지 않는다. Human이 1단계에서 채택 여부를 판정한다.**

| # | 정확한 경로 | 현재 지위 | 전체 절 구조 | 관련 절 | suspended block |
|---:|---|---|---|---|---|
| 1 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010630_Policy_Authority_Capability_Gate.md` | ACTIVE | Purpose; §2~§44 | §2~§6, §9, §13, §18, §21~§22, §24, §28~§30, §35, §39, §44 | 없음 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010650_Policy_Failure_Containment_Circuit_Breaker.md` | ACTIVE | Purpose; §2~§42 | §2~§7, §16~§18, §27, §29~§33, §35~§36, §42 | 없음 |
| 3 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | ACTIVE | Purpose; §2~§44 | §2~§16, §29, §31~§33, §36~§38, §44 | 없음 |

> ⚠️ **`A1` 과 `A1'` 을 구분하는 이유**
>
> ```text
> 600021 §2 가 요구한 것   5건
> 조사 중 발견한 것         3건
> ```
>
> **「발견했고 직접 관련이 확인됐다」와
> 「상위 규정이 요구했다」는 다르다.**
>
> **`Stage 0` 은 사실 등록부이며 authority 를 만드는 단계가 아니다.**
> **세 문서의 조사 내용은 유효한 evidence 이나
> 그것을 이 나선의 구속으로 삼을지는 Human 이 1단계에서 정한다.**

### §3.2 A2 Upstream Human Declaration

| # | 정확한 경로 | 현재 지위 | 전체 절 구조 | 관련 절 | suspended block |
|---:|---|---|---|---|---|
| 1 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | ACTIVE | §0; §1.1~§1.45; §2.1~§2.4; §3~§5 | §1 전건, 특히 §1.22·§1.26·§1.27·§1.28·§1.40·§1.43 | 문서 자체 block 없음; §3이 `601500` suspended 상태를 기록 |

### §3.3 A3 Discovery Inventory

`010640` §41이 직접 선행·후속·참조 관계로 열거한 문서만 기록한다.

| # | 정확한 경로 | 현재 지위 | 발견 위치 | authority 처리 |
|---:|---|---|---|---|
| 1 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010610_Policy_Cross_Room_Event_Bus_And_Evidence_Packet_Routing.md` | ACTIVE | `010640` §41 references | A3 유지 — 격리 중 event 전달; Integration Isolation 이월 소관 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010620_Policy_Command_Query_Projection_Separation.md` | ACTIVE | `010640` §41 references | A3 유지 — projection separation; 1단계가 필요하면 본다 |
| 3 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010670_Policy_Safe_Projection_I18n_Routing.md` | ACTIVE | `010640` §41 prepares | A3 유지 — safe projection·i18n; 1단계가 필요하면 본다 |
| 4 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010680_Audit_Correlation_Nightly_Batch.md` | ACTIVE | `010640` §41 prepares | A3 유지 — audit correlation; R-6과 인접하며 1단계가 필요하면 본다 |
| 5 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010690_Policy_Cross_Room_Plumbing_Closure.md` | ACTIVE | `010640` §41 prepares | A3 유지 — closure; 1단계가 필요하면 본다 |

### §3.4 A4 Suspended Evidence

| 대역 | 문서 수 | 현재 지위 | 확인 근거 | 사용 범위 |
|---|---:|---|---|---|
| `601500` | 13 | SUSPENDED | `600020` §1.1; 대역 Readme·Baseline Summary의 suspended 표시 | 사실·raw evidence만 |
| `601600` | 2 | 혼재 | 파일 자체는 Active이나 `601500` 결과를 상위 문서에 역전파한 대역; 삽입 결과는 source 문서 안에서 suspended wrapper로 구분됨 | 후대 삽입 위치 식별만 |
| `601800` | 17 | SUSPENDED | `601800` Readme 상단; `600021` §1·§2 | finding 목록만; 설계 판정 승계 안 함 |

## §4 대상별 A~E 요약표

| 대상 | A 문서 | B SQL 객체 | C 문서↔SQL | D 로컬 실행 | E 호출자·권한 | 현재 기록 |
|---|---|---|---|---|---|---|
| Tenant isolation doctrine | `010004` 존재 | `tenants` 상태축 2컬럼·CHECK 2건, 관련 자산 4테이블 존재 | audit 자산에 tenant·actor·resource·event detail 필드 존재; `isolate_tenant`는 `tenant_status`를 쓰고 `isolation_state`는 참조하지 않음 | catalog·행 수 조회 성공; 상태 변경 실행은 read-only 범위 밖 | 상태 소비 함수 7건; asset RLS·policy·ACL은 §17·§20 | B~E 실측 |
| Tenant scope envelope | `010640` 존재 | 두 상태축과 tenant/store scope 컬럼·FK·RLS 존재 | 상태 CHECK는 5값·2값; `idempotency_keys` UNIQUE에 tenant 포함, store는 포함되지 않음 | catalog 조회 성공; scope mutation은 실행하지 않음 | authenticated policy 4건; 함수 ACL·호출자는 §18~§21 | B~E 실측 |
| Company/business unit/legal entity | `000150` 존재 | `tenants` 및 함수의 tenant/legal-entity 관련 catalog 존재 | 이번 6군에서 company/business-unit 전체 물리 모델은 측정 대상이 아님 | 대상 catalog 조회만 수행; 업무 동작 미실행 | 측정 대상 함수·자산의 권한만 §18~§21에 기록 | 부분 실측 — 범위 명시 |
| Merchant account/company/store | `000170` 존재 | 최신 migration `0171_merchant_account_foundation.sql`; asset에 store scope 컬럼 존재 | `idempotency_keys`는 tenant UNIQUE scope를 가지며 store_id는 별도 FK | migration·catalog 조회 성공; merchant 동작 미실행 | 측정 대상 policy/ACL만 기록 | 부분 실측 — 범위 명시 |
| Cross-business boundary | `000190` 존재 | 이번 6군의 SQL 객체 존재 여부는 §17~§21에 기록 | cross-business 전체 객체 대응은 이번 측정 대상이 아님 | 대상 catalog 조회만 수행 | 비문서 앱 코드의 7함수 literal 호출자 0건 | 부분 실측 — 범위 명시 |
| Upstream Human declarations | `601702` 45건 존재 | 두 상태축·7함수·4자산의 물리 존재 확인 | Human 선언을 정답으로 사용하지 않고 A1 8건과 실측만 대조 | 호출 금지 7함수는 미검증; catalog 조회만 성공 | 정적 DB 호출 edge 6건; 앱 코드 literal 0건 | B~E 실측 |
| Suspended prior evidence | `601500`·`601600`·`601800` 존재 | `601802` 대상값을 현재 DB에서 재측정 | §22에 old/new만 병기; suspended 판정은 승계하지 않음 | 과거 값을 실행 증거로 사용하지 않음 | 과거·현재 호출자/ACL 차이는 §22 | REMEASURED 비교 |
| Authority capability gate | `010630` 존재 — A1' 승격(2026-09-02) | 7함수 전부 SECURITY DEFINER; 명시 search_path·ACL 존재 | PUBLIC EXECUTE 5함수, authenticated 6함수, service_role 1함수; 구체 gate 실행은 미검증 | 7함수 전부 미검증 — 호출 금지(`601505` §4) | DB 호출 edge 6건; 비문서 앱 코드 literal 0건 | B~E 실측 |
| Failure containment circuit breaker | `010650` 존재 — A1' 승격(2026-09-02) | `offline_queue`·`security_threats`·`security_audit_log` 존재; tenant/store/device scope 컬럼 존재 | 자산 4건 모두 RLS+FORCE RLS; `security_threats.tenant_id`는 nullable·FK 없음 | catalog·행 수 조회 성공; containment 함수는 호출하지 않음 | policy 각 1건; 참조 함수 목록은 §20 | B~E 실측 |
| Idempotency·retry·replay·reconciliation | `010660` 존재 — A1' 승격(2026-09-02) | `idempotency_keys` 21컬럼·12제약·RLS policy 1건 | tenant_id NOT NULL·FK·UNIQUE `(tenant_id,key_domain,idempotency_key)`; store_id는 nullable FK이고 UNIQUE에는 없음 | catalog·행 수 조회 성공; retry/replay 실행은 하지 않음 | authenticated ALL policy 1건; postgres table grants | B~E 실측 |

## §5 A1 상세 — 010004

### §5.1 전체 절 구조

| 구간 | 절 |
|---|---|
| 서두 | Purpose |
| 격리 핵심 | §2 Core Principle; §3 SaaS Isolation Threat; §4 Mandatory Context Fields; §4.1 Global Tables; §5 MD-Level Isolation Rule; §6 Tenant Isolation Layers; §7 Deny-By-Default Rule |
| 도메인 경계 | §8 Store; §9 Franchise OS; §10 Admin/Support; §11 Provider; §12 Device; §13 CMS/i18n; §14 Payment/Financial; §15 AI; §16 pgvector; §17 Analytics; §18 Export; §19 Audit |
| containment·검증 | §20 Cross-Tenant Containment; §21 Test Principle; §22 MD Readiness; §23 Four-Side Skeleton; §24 Runtime Authorization; §25 Anti-Patterns; §26 Runtime Deferral; §27 Validation; §28 Relationships; §29 Final Rule |

### §5.2 관련 절 원문

`§2 Core Principle`:

```text
Tenant isolation is not an optional security feature.

Tenant isolation is the platform spine.

Every object must know its tenant.
Every store-scoped object must know its store.
Every query must be scoped.
Every command must be scoped.
Every projection must be scoped.
Every admin view must be scoped.
Every provider event must be scoped.
Every audit event must be scoped.
Every AI context must be scoped.
Every vector retrieval must be scoped.
Every export must be scoped.

No tenant may ever see, infer, retrieve, aggregate, search, export, or act upon another tenant’s data unless a separately authorized cross-tenant governance role exists.

Default rule:

`CROSS_TENANT_ACCESS_DENIED`
```

`§4 Mandatory Context Fields` 원문 표:

| Field | Requirement |
|---|---|
| `tenant_id` | Required for all tenant-owned objects |
| `store_id` | Required for store-scoped objects |
| `brand_id` | Required when brand context matters |
| `operating_group_id` | Required when operational grouping matters |
| `legal_entity_id` | Required when settlement/legal ownership matters |
| `device_id` | Required for device-originated records |
| `surface_id` | Required for surface-originated records |
| `provider_id` | Required for provider-originated records |
| `actor_id` | Required for human/system action records |
| `scope_class` | Required for visibility classification |
| `authority_context` | Required for mutation/review actions |

`§5 MD-Level Isolation Rule` 원문 14항:

```text
1. Who owns this object?
2. Which tenant owns it?
3. Which store owns it, if any?
4. Which surface created it?
5. Which device created it, if any?
6. Which actor can view it?
7. Which actor can mutate it?
8. Which role can review it?
9. Which projection may expose it?
10. Which export may include it?
11. Which AI/vector context may reference it?
12. Which audit event records access or mutation?
13. Which fallback/reconciliation process may touch it?
14. Which cross-tenant access is explicitly prohibited?
```

`§7 Deny-By-Default Rule`:

```text
Every tenant-scoped object must default to:

`DENY_UNLESS_CONTEXT_MATCHES`

Allowed access requires:

- authenticated actor
- resolved tenant context
- resolved store context if applicable
- valid role
- valid authority
- valid surface/device context if applicable
- policy permission
- Safe Projection rule
- audit requirement if sensitive
- no containment block
- no suspension block

If context cannot be resolved, access must fail closed.

Fail closed is mandatory.
```

`§19 Audit Isolation Rule`:

```text
Audit event should record:

- tenant id
- store id if applicable
- actor id
- actor role
- surface/device
- target object id
- target object type
- action
- previous scope
- new scope if changed
- authority reference
- policy reference
- evidence reference
- cross-scope attempt if any

Cross-tenant access attempts must be auditable.

Failed access is also security evidence.
```

`§20 Cross-Tenant Containment Rule`:

```text
If cross-tenant contamination is suspected, containment must trigger.

Possible triggers:

- unexpected tenant id in response
- wrong store data rendered
- vector result from wrong tenant
- support view shows wrong tenant
- export row scope mismatch
- provider callback attached to wrong store
- device context mismatch
- CMS target mismatch
- financial report mismatch
- audit context missing

Containment actions may include:

- block projection
- suspend affected view
- quarantine event
- disable export
- disable vector retrieval
- disable AI context
- require admin/security review
- preserve evidence
- notify internal incident route

Containment is not resolution.
```

`§24 Relationship To Runtime Authorization` 원문 11항:

```text
- tenant isolation impact
- store isolation impact
- context fields
- access model
- RLS or equivalent policy expectation
- Safe Projection scope
- audit scope
- export scope
- AI/vector scope if applicable
- isolation validation plan
- rollback/containment plan
```

```text
If tenant isolation is missing, coding must be blocked.
```

`§29 Final Rule`:

```text
A Store A record must never appear in Store B context.

Tenant A data must never appear in Tenant B context.

Cross-tenant access is denied by default.

If tenant isolation cannot be proven, the feature is not ready.

Runtime implementation remains deferred until a separate explicit authorization packet with tenant isolation validation is approved.
```

### §5.3 내부 모순·애매점·제외

| 항목 | 원문상 사실 |
|---|---|
| 혼재 | §4.1 안에 2026-08-11 해설과 `AUTHORITY SUSPENDED` wrapper가 함께 존재 |
| 애매점 | §4.1의 전역 테이블 판별 기준 중 어느 문장이 원 정책이고 어느 문장이 `601600` 역전파인지 문서 본문만으로 문장별 표식되지 않음 |
| 제외 | §8~§18 개별 도메인 절은 전체 구조에는 기록했으나 Pass 1의 tenant isolation axis 직접 인용에서는 제외 |

## §6 A1 상세 — 010640

### §6.1 전체 절 구조

| 구간 | 절 |
|---|---|
| 서두 | Purpose; §2 Core Position; §3 Applicability; §4 Dimension Catalog; §5 Mandatory Fields; §6 Validation States |
| scope 경계 | §7 Tenant; §8 Store; §9 Legal Entity; §10 Operating Group; §11 Brand/Franchise; §12 Provider; §13 Device; §14 Surface; §15 Actor/Role; §16 Customer; §17 Public Service Identity; §18 AI; §19 pgvector; §20 Analytics; §21 CMS/i18n; §22 Export; §23 Retention; §24 DR; §25 Sharding; §26 Offline; §27 Sensor; §28 Physical; §29 Financial Ledger |
| 전달·검증 | §30 Scope Hash; §31 Propagation; §32 Downscoping; §33 Escalation; §34 Cross-Tenant Aggregation; §35 Conflict; §36 Audit; §37 Reason Codes; §38 Anti-Patterns; §39 Runtime Deferral; §40 Validation; §41 Relationships; §42 Final Rule |

### §6.2 관련 절 원문

`§2 Core Position`:

```text
Every object must carry scope before it can be trusted.

No tenant scope, no processing.
No store scope for store-level action, no processing.
No legal entity scope for financial action, no financial finality.
No provider scope for provider event, no provider matching.
No device scope for device-originated event, no device trust.
No audience scope for projection, no visibility.
No authority context for command, no mutation.
No scope match, no cross-room routing.
No proven isolation, no SaaS readiness.

Tenant isolation is not a database feature only.

It is an envelope that wraps every data movement.
```

`§4 Scope Dimension Catalog` 중 원문 관련 행:

| Scope Dimension | Meaning |
|---|---|
| `tenant_id` | SaaS tenant/customer organization |
| `store_id` | Individual store or outlet |
| `brand_id` | Brand identity or product line |
| `operating_group_id` | Operational grouping such as region/business unit |
| `legal_entity_id` | Legal/accounting/tax entity |
| `company_id` | Company or corporate entity if separate from legal entity |
| `franchise_group_id` | Franchise network or master group |
| `franchise_hq_id` | Franchise headquarters context |
| `provider_id` | PG/VAN/card/bank/provider |
| `merchant_id` | Provider-side merchant account |
| `actor_id` | Acting user/system |
| `authority_scope` | Scope within which action is allowed |

`§6 Scope Validation State Skeleton`:

| State | Meaning |
|---|---|
| `SCOPE_NOT_EVALUATED` | Scope not evaluated |
| `SCOPE_VALIDATING` | Scope validation in progress |
| `SCOPE_VALID` | Scope valid |
| `SCOPE_PARTIAL_VALID` | Scope valid only for limited operation |
| `SCOPE_MISSING` | Required scope missing |
| `SCOPE_MISMATCH` | Scope mismatch |
| `SCOPE_CROSS_TENANT_DENIED` | Cross-tenant access denied |
| `SCOPE_STORE_MISMATCH` | Store scope mismatch |
| `SCOPE_LEGAL_ENTITY_MISMATCH` | Legal entity mismatch |
| `SCOPE_PROVIDER_MISMATCH` | Provider mismatch |
| `SCOPE_DEVICE_MISMATCH` | Device mismatch |
| `SCOPE_VISIBILITY_DENIED` | Visibility denied |
| `SCOPE_AUTHORITY_DENIED` | Authority denied |
| `SCOPE_REVIEW_REQUIRED` | Human/security review required |
| `SCOPE_QUARANTINED` | Quarantined for safety |
| `SCOPE_DLQ_REQUIRED` | DLQ required |

`§7 Tenant Isolation Boundary`:

```text
Tenant A data must not appear in Tenant B context.
Tenant A command must not mutate Tenant B object.
Tenant A export must not include Tenant B record.
Tenant A AI context must not retrieve Tenant B private data.
Tenant A pgvector query must not retrieve Tenant B private vector source.
Tenant A support case must not open Tenant B evidence.
Tenant A provider event must not match Tenant B merchant mapping.

Default rule:

    CROSS_TENANT_ACCESS_DENIED
```

`§31 Scope Propagation Boundary`:

```text
Scope must propagate across:

- command
- event
- evidence packet
- audit
- projection
- query response
- reconciliation case
- DLQ record
- export
- archive
- AI context
- vector record
- analytics read model

Scope must not be dropped between rooms.

Scope drop is a routing failure.
```

`§35 Scope Conflict Boundary`:

```text
Scope conflict occurs when identifiers disagree.

Examples:

- event tenant id differs from object tenant id
- provider merchant maps to different tenant
- device assigned to different store
- actor role belongs to different tenant
- payment legal entity differs from settlement legal entity
- export includes out-of-scope row
- AI context retrieves wrong tenant
- vector result crosses tenant boundary
- sensor event zone mismatches table/order

Scope conflict must fail closed.
```

`§42 Final Rule`:

```text
If scope is missing, mismatched, dropped, unverifiable, or cross-tenant unsafe, the object must be denied, quarantined, or routed to DLQ.

Tenant isolation is not optional.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
```

### §6.3 내부 모순·애매점·제외

| 항목 | 원문상 사실 |
|---|---|
| suspended block | 없음 |
| 애매점 | §4는 `merchant_id`를 provider-side merchant account로 정의하며 `000170`의 CatchMenu `Merchant Account`와 명칭 범위가 다름 |
| 애매점 | §5는 “should carry”, §2·§42는 “must”를 사용하며 적용 강도의 문구가 혼재 |
| 제외 | §10~§28의 개별 scope 절은 전체 구조에 기록하고, 직접 인용은 tenant/store/legal/actor/financial 및 전달·충돌 절로 한정 |

## §7 A1 상세 — 000150

### §7.1 전체 절 구조

원 정책은 §1 Purpose, §2 Scope, §3 Core Principle, §4 Company Boundary, §5 Parent Group Context, §6 Business Unit Boundary, §7 Legal Entity Boundary, §8 Why These Must Be Separate, §9 Operating Status, §10 Service Business Boundary, §11 Franchise OS Boundary, §12 Affiliated Store, §13 External Merchant, §14 Trial, §15 Production, §16 Company Authority, §17 Legal Authority, §18 Business Unit Responsibility, §19 Team Assignment, §20 Operator Context, §21 Audit, §22 Cross-Business Link, §23 Default Denial, §24 Federation, §25 MVP, §26 Entities, §27 Identity Access, §28 HQ, §29 Merchant Ops, §30 Owner Console, §31 Entry Media, §32 Risk, §33 Final Rule로 구성된다.

### §7.2 관련 원 정책 원문

```text
3\. Core Principle

CatchMenu must be modeled as its own operating business.

Core rule:

CatchMenu belongs to a business boundary.
Franchise OS belongs to another business boundary.
Shared group ownership does not merge operating authority.
```

```text
5\. Parent Group Context

Parent group must not provide automatic system authority.

Core rule:

Parent group is an ownership or strategy context.
It is not automatic access authority.
```

```text
7\. Legal Entity Boundary

Legal entity defines legal, contract, billing, tax, and liability identity.

Legal entity should be distinct from company and business unit.

Core rule:

Legal entity is contract identity.
Business unit is operational responsibility.
Company is operating business context.
```

```text
12\. Shared Yoonsul-Affiliated Store Case

Same physical store may have different system identities in different business contexts.
```

```text
13\. External Merchant Case

External SaaS merchant is not a Yoonsul franchisee by default.
```

```text
22\. Cross-Business Link

A link is not authority.
Authority requires role and scope.
```

```text
23\. Cross-Business Access Denial By Default

Franchise OS admin
→ no CatchMenu admin authority by default

CatchMenu admin
→ no Franchise OS admin authority by default

Access must be granted explicitly.
```

```text
33\. Final Rule

Define the operating company.
Separate business unit from legal entity.
Separate CatchMenu from Franchise OS.
Allow explicit links.
Deny implicit authority.
Support external SaaS merchants.
Preserve audit.
Prepare HQ and Identity Access on top of this structure.
```

### §7.3 내부 모순·애매점·제외

| 항목 | 기록 |
|---|---|
| 원 정책 경계 | baseline L73부터 numbered §1~§33 |
| 후대 삽입 | baseline L10~L70: suspended wrapper와 2026-08-11 구현 대응 개정 |
| 혼재 | 후대 삽입이 `601500`·`601501`·migration `0168`을 근거로 하나 wrapper가 구현 대응표·테이블명·판정식·상태값을 인용 금지로 표시 |
| 제외 | 후대 삽입의 구현 대응표를 원 정책으로 사용하지 않음 |

## §8 A1 상세 — 000170

### §8.1 전체 절 구조

원 정책은 §1 Purpose, §2 Scope, §3 Core Principle, §4 Merchant Account, §5 Account Types, §6 Merchant Company, §7 Merchant Store, §8 Single-Store, §9 Multi-Store, §10 Trial, §11 Production, §12 External, §13 Affiliated Store, §14 Service Status, §15 Operating Status, §16 Trial Status, §17 Enabled Stage, §18 Menu Context, §19 Owner, §20 Users, §21 Staff Viewer, §22 Contact, §23 Address, §24 Hours, §25 Plan, §26 Entry Media, §27 Runtime, §28 Owner Console, §29 Merchant Ops, §30 HQ, §31 Cross-Business Link, §32 Deletion, §33 Audit, §34 Failure, §35 Support, §36 MVP, §37 Entities, §38 Risk, §39 Final Rule로 구성된다.

### §8.2 관련 원 정책 원문

```text
3\. Core Principle

Merchant account, merchant company, and merchant store are different concepts.

Merchant Account is the SaaS customer relationship.
Merchant Company is the business or owner entity.
Merchant Store is the physical or operating location.

These must not be collapsed into one record.
```

```text
4\. Merchant Account Definition

Merchant Account is the top-level customer relationship in CatchMenu.

Merchant Account is the root context for Owner Console and Merchant Ops.
```

```text
7\. Merchant Store Definition

A merchant account may have one or more merchant stores.

Core rule:

Store is the runtime context.
Merchant Account is the customer relationship context.
```

```text
12\. External Merchant Boundary

External SaaS merchant is not a Yoonsul franchisee by default.
```

```text
13\. Yoonsul-Affiliated Store

Same physical location may have separate system identities.
The relationship must be explicit.
```

```text
25\. Service Plan Relationship

Plan affects feature availability.
Plan does not replace service status.
```

```text
31\. Cross-Business Link To Franchise OS

Cross-business link is reference.
Cross-business link is not permission.
```

```text
39\. Final Rule

Create Merchant Account as customer relationship.
Create Merchant Store as runtime location.
Use Merchant Company when business/legal grouping is needed.
Track trial and service status.
Scope owner access to account/store.
Link Entry Media to store context.
Link Franchise OS only explicitly.
Preserve merchant history.
Do not collapse merchant, company, and store into one concept.
```

### §8.3 내부 모순·애매점·제외

| 항목 | 기록 |
|---|---|
| 원 정책 경계 | §1~§13 뒤에 후대 삽입이 끼고, 원 정책 §14~§39가 이어짐 |
| 후대 삽입 | baseline L385~L449: suspended wrapper와 2026-08-11 상태 어휘 개정 |
| 명시된 충돌 | wrapper는 §14~§16의 `SUPERSEDED` 선언을 철회한다고 쓰지만, 바로 아래 후대 heading은 여전히 `SUPERSEDED`라고 씀 |
| 제외 | 후대 삽입의 구현 상태 3축·판정식·상태값 표는 원 정책으로 사용하지 않음 |

## §9 A1 상세 — 000190

### §9.1 전체 절 구조

Purpose와 numbered §1~§37로 구성된다. 핵심 구간은 §3 Core Principle, §4 Business Boundary, §5 Franchise OS, §6 CatchMenu, §7 Group, §8 External Merchant, §9 Affiliated Store, §10 Link, §11 User Link, §12 Role, §13 Permission, §14 Visibility, §15 Support, §16 Audit, §17 Leakage, §18 Philosophy, §19 Shared Components, §20 Federation, §21 Source of Truth, §22 Yoonsul Store, §23 External Store, §24 Reporting, §25 Support Case, §26 Incident, §27 Link Status, §28 Preconditions, §29 Deactivation, §30 Failure Events, §31 Audit Events, §32 Signals, §33 Evidence, §34 MVP, §35 Entities, §36 Risk, §37 Final Rule이다.

### §9.2 관련 절 원문

```text
3\. Core Principle

Same group does not mean same authority.

Shared ownership may create relationship.
Only explicit role and scope create authority.
```

```text
4\. Business Boundary Summary

Separate by default.
Federate by explicit design.
```

```text
8\. External Merchant Boundary

External SaaS merchant is a CatchMenu customer.
External SaaS merchant is not a Franchise OS store by default.
```

```text
10\. Cross-Business Link

Cross-business link is reference.
Cross-business link is not permission.
```

```text
13\. Permission Separation

Permission belongs to a business scope.
```

```text
17\. Authority Leakage Prohibition

No implicit cross-business authority.
```

```text
20\. Federation Definition

Federation must define:

source of truth
data ownership
permission mapping
audit ownership
support visibility
failure handling
revocation method

Federation is designed.
Federation is not assumed.
```

```text
21\. Source Of Truth Rule

Every shared data element needs a source of truth.
```

```text
27\. Cross-Business Link Status

A suspended or invalidated link must not continue to grant data flow or inferred relationship.

Broken link must fail closed.
```

```text
37\. Final Rule

Separate the businesses.
Link explicitly.
Deny implicit authority.
Preserve source of truth.
Audit every cross-business link.
Protect external merchants.
Protect Franchise OS data.
Federate later by design, not by accident.
```

### §9.3 내부 모순·애매점·제외

| 항목 | 기록 |
|---|---|
| suspended block | 없음 |
| 애매점 | Suggested conceptual entities와 실제 물리 모델의 대응은 이 Pass에서 측정하지 않음 |
| 제외 | §24~§36의 상세 reporting/support/entity 후보는 전체 구조에만 기록; tenant isolation axis 직접 원문은 boundary·authority·link·fail-closed 절로 한정 |

## §9.1 A1' 상세 — 010630 Authority Capability Gate

### §9.1.1 식별 · 지위 · 전체 절 구조

| 항목 | 기록 |
|---|---|
| 정확한 경로 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010630_Policy_Authority_Capability_Gate.md` |
| 현재 지위 | ACTIVE — A3에서 A1으로 승격(2026-09-02) |
| 승격 기록 근거 | 격리 발동 권한과 같은 주제를 다룸 |
| 전체 절 구조 | Purpose; §2 Core Position; §3 Scope; §4 Authority Gate Catalog; §5 Authority Context; §6 Authority Decision States; §7 Identity Gate; §8 Role Gate; §9 Scope Gate; §10 Feature Entitlement Gate; §11 Policy Gate; §12 State Transition Gate; §13 Evidence Gate; §14 Risk Gate; §15 Device Trust Gate; §16 Provider Readiness Gate; §17 Financial Limit Gate; §18 Multi-Party Approval Gate; §19 Privacy Visibility Gate; §20 Safety Gate; §21 Idempotency Gate; §22 Audit Gate; §23 Time Window Gate; §24 Circuit Breaker Gate; §25 Compliance Gate; §26 Human Review Gate; §27 Authority Evaluation Order; §28 Default Denial Rules; §29 Authority Decision Output; §30 Reason Code Policy; §31 Authority Decision Audit; §32 Authority Decision Caching; §33 Policy Version Binding; §34 Authority Invalidation; §35 Break-Glass Access; §36 Service Account Authority; §37 AI Authority Boundary; §38 Device Authority Boundary; §39 Testing Requirements; §40 Observability; §41 Suggested Conceptual Entities; §42 Example Authority Decisions; §43 Mandatory Failure Rules; §44 Final Rule |

### §9.1.2 0-A-2 관련 절 — 원문

```text
## 2. Core Position

Capability must be separated from authority.

The correct rule is:

Feature available does not mean actor authorized.  
Role exists does not mean action permitted.  
Device connected does not mean device trusted.  
Provider configured does not mean provider verified.  
AI recommendation does not mean approval.  
Sensor confidence does not mean execution authority.  
Projection visibility does not mean mutation authority.  
Support access does not mean ownership.  
Admin access does not mean financial authority.  
Tenant entitlement does not mean compliance readiness.  
Capability flag does not override policy gate.  
Authority must be explicit, scoped, evidenced, and auditable.  

The platform must gate every high-impact action through context-aware authority checks.

---
```

```text
## 5. Authority Context Boundary

Every command must carry authority context.

Recommended authority context fields:

| Field | Meaning |
|---|---|
| `actor_id` | Acting user/system |
| `actor_type` | Customer, staff, owner, HQ, support, finance, security, system |
| `role_id` | Role assigned |
| `role_scope` | Scope of role |
| `tenant_id` | Tenant context |
| `store_id` | Store context |
| `brand_id` | Brand context |
| `operating_group_id` | Operating group context |
| `legal_entity_id` | Legal/accounting context |
| `surface_id` | UI/API/device surface |
| `device_id` | Device used |
| `session_id` | Session context |
| `feature_id` | Feature being invoked |
| `capability_id` | Capability being used |
| `policy_version` | Active policy version |
| `risk_state` | Risk state |
| `approval_context` | Approval references |
| `evidence_packet_id` | Supporting evidence |
| `authority_decision_id` | Gate decision id |

No high-impact command may execute without authority context.

---
```

```text
## 6. Authority Decision State Skeleton

Recommended authority decision states:

| State | Meaning |
|---|---|
| `AUTHORITY_NOT_EVALUATED` | Gate not evaluated |
| `AUTHORITY_EVALUATING` | Gate evaluation in progress |
| `AUTHORITY_ALLOWED` | Allowed |
| `AUTHORITY_DENIED` | Denied |
| `AUTHORITY_PARTIAL_ALLOWED` | Allowed only in limited scope |
| `AUTHORITY_REVIEW_REQUIRED` | Human review required |
| `AUTHORITY_MULTI_PARTY_REQUIRED` | Multi-party approval required |
| `AUTHORITY_EVIDENCE_REQUIRED` | Evidence missing |
| `AUTHORITY_RISK_HOLD` | Held due to risk |
| `AUTHORITY_POLICY_BLOCKED` | Blocked by policy |
| `AUTHORITY_SCOPE_MISMATCH` | Tenant/store/legal scope mismatch |
| `AUTHORITY_DEVICE_UNTRUSTED` | Device trust failed |
| `AUTHORITY_PROVIDER_UNREADY` | Provider not ready |
| `AUTHORITY_CIRCUIT_OPEN` | Circuit breaker blocks route |
| `AUTHORITY_DLQ_REQUIRED` | Gate result must route to DLQ |

Authority denied must be auditable.

---
```

```text
## 9. Scope Gate Boundary

Scope gate checks whether the actor may act in the requested context.

Scope dimensions:

- tenant
- store
- brand
- operating group
- legal entity
- device
- provider
- region
- franchise HQ
- customer session
- financial account
- supplier
- policy family

Default rule:

    DENY_UNLESS_SCOPE_MATCHES

If scope cannot be proven, deny or quarantine.

---
```

```text
## 18. Multi-Party Approval Gate Boundary

Multi-party approval gate applies to high-risk actions.

Actions may include:

- policy activation
- payout rule change
- provider credential change
- settlement account change
- large manual adjustment
- trigger/audit control modification
- WORM/retention change
- DR failover promotion
- split payout configuration
- fast payout risk model activation
- high-value refund approval
- privileged access
- direct DB maintenance window
- security containment release

One person must not control critical financial or security changes alone.

---
```

```text
## 21. Idempotency Gate Boundary

Idempotency gate checks duplicate-safe execution.

High-risk duplicate cases:

- payment capture
- refund request
- auth release
- payout
- split payout
- supplier order
- KDS ticket
- IoT command
- no-show penalty
- manual adjustment
- policy activation
- DR replay
- export delivery

Duplicate action must return existing result or route to review.

It must not execute twice.

---
```

```text
## 22. Audit Gate Boundary

Audit gate checks whether the action can be traced.

If required audit cannot be recorded, high-impact action must be blocked or routed to fallback.

Audit gate applies to:

- financial movement
- policy change
- manual adjustment
- privileged access
- provider callback acceptance
- export
- security containment
- sensor-derived billing candidate
- IoT command
- supplier order
- no-show penalty
- fast payout

No audit, no high-impact action.

---
```

```text
## 28. Deny-By-Default Rule

Default authority decision is denial.

Recommended default:

    DENY_UNLESS_EXPLICITLY_ALLOWED

For tenant isolation:

    CROSS_TENANT_ACCESS_DENIED

For provider readiness:

    CAPABILITY_PROVIDER_EVIDENCE_REQUIRED

For sensor-derived billing:

    SENSOR_EVENT_REVIEW_REQUIRED

For AI execution:

    AI_AUTHORITY_DENIED

For physical device execution:

    SAFETY_GATE_REQUIRED

For financial finality:

    FINANCIAL_EVIDENCE_REQUIRED

---
```

```text
## 35. Authority Gate And Break-Glass Boundary

Break-glass authority is emergency-only.

Break-glass requires:

- emergency reason
- limited scope
- limited duration
- reauthentication
- multi-party or post-review if policy requires
- elevated audit
- notification
- reconciliation
- postmortem

Break-glass must not become normal admin workflow.

---
```

```text
## 44. Final Rule

Capability is not authority.

A feature may exist, a role may exist, a device may be connected, a provider may be configured, a projection may be visible, an AI may recommend, and a sensor may detect, but none of these alone authorizes action.

Every high-impact action must pass explicit identity, role, scope, entitlement, policy, state, evidence, risk, device, provider, amount, approval, privacy, safety, idempotency, audit, time, circuit breaker, compliance, and human-review gates as applicable.

Default is denial unless explicit authority is proven.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
```

### §9.1.3 suspended block · 분리 · 애매점 · 제외

| 항목 | 기록 |
|---|---|
| AUTHORITY SUSPENDED 블록 | 없음 |
| 원 정책과 후대 삽입 | 식별된 AUTHORITY SUSPENDED 후대 삽입 블록 0건; 위 인용은 문서 본문 절에서 옮김 |
| 문서 내부의 모순 · 애매점 | authority context의 필드가 “should include”로 표현되지만 마지막 문장은 authority context 없는 high-impact command를 금지함; 격리 발동·해제에 적용할 구체 capability_id와 승인 주체는 이 문서에서 열거하지 않음 |
| 제외한 절과 사유 | §7~§8, §10~§17, §19~§20, §23~§27, §29~§34, §36~§43은 전체 구조에는 기록했으며, 이번 승격 근거인 격리 발동 권한·scope·containment·audit·idempotency와 직접 맞닿은 절의 원문을 위에 옮김 |

## §9.2 A1' 상세 — 010650 Failure Containment Circuit Breaker

### §9.2.1 식별 · 지위 · 전체 절 구조

| 항목 | 기록 |
|---|---|
| 정확한 경로 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010650_Policy_Failure_Containment_Circuit_Breaker.md` |
| 현재 지위 | ACTIVE — A3에서 A1으로 승격(2026-09-02) |
| 승격 기록 근거 | 격리와 containment가 같은 주제를 다룸 |
| 전체 절 구조 | Purpose; §2 Core Position; §3 Scope; §4 Containment Families; §5 Circuit Breaker States; §6 Circuit Breaker Trigger Classes; §7 Circuit Decision Record; §8 Timeout Containment; §9 Provider Failure Containment; §10 Queue Backpressure; §11 DLQ Containment; §12 Financial Containment; §13 Authorization Unknown Containment; §14 Sensor Event Containment; §15 AI Failure Containment; §16 Security Quarantine; §17 Tenant Noisy Neighbor Containment; §18 Store-Local Containment; §19 Device Failure Containment; §20 IoT Containment; §21 Supplier Failure Containment; §22 Notification Failure Containment; §23 Export Failure Containment; §24 Projection Failure Containment; §25 Search Failure Containment; §26 Local Mode Containment; §27 Disaster Recovery Containment; §28 Containment Escalation; §29 Recovery Requirements; §30 Circuit Reclose Checklist; §31 DLQ Resolution; §32 Containment Evidence Packet; §33 Audit Requirements; §34 Observability; §35 Manual Containment Actions; §36 Containment Scope Rules; §37 Suggested Conceptual Entities; §38 Example Containment Scenarios; §39 Mandatory Failure Rules; §40 Policy Questions; §41 Boundary; §42 Final Rule |

### §9.2.2 0-A-2 관련 절 — 원문

```text
## 2. Core Position

Failure must be contained at the smallest safe boundary.

The correct rule is:

Failure is not permission to mutate.  
Timeout is not success.  
Timeout is not failure finality.  
Unknown state must be contained.  
Provider failure must not corrupt internal ledger.  
Store device failure must not stop tenant financial evidence.  
Tenant failure must not affect another tenant.  
Queue overload must not reach the financial core directly.  
Sensor false positive must not trigger billing.  
AI failure must not block operational truth.  
Circuit breaker protects the system, but does not resolve the incident.  
Containment is not recovery.  
Fallback is not silent mutation.  

The system must degrade, isolate, quarantine, and reconcile rather than crash, over-retry, or spread uncertainty.

---
```

```text
## 4. Failure Containment Catalog

The following containment families are required:

| Containment Family | Purpose |
|---|---|
| `ROUTE_CIRCUIT_BREAKER` | Stop unsafe repeated calls to failing route |
| `PROVIDER_CIRCUIT_BREAKER` | Isolate PG/VAN/bank/supplier/provider failures |
| `TENANT_CIRCUIT_BREAKER` | Isolate tenant-specific overload or compromise |
| `STORE_CIRCUIT_BREAKER` | Isolate store-level device/network/runtime failure |
| `DEVICE_CIRCUIT_BREAKER` | Block untrusted or failing device |
| `QUEUE_BACKPRESSURE` | Prevent queue overload from reaching core systems |
| `RATE_LIMIT_CONTAINMENT` | Limit abusive or excessive requests |
| `DLQ_CONTAINMENT` | Isolate malformed or unsafe messages |
| `SECURITY_QUARANTINE` | Quarantine suspected attack or compromise |
| `FINANCIAL_HOLD` | Hold financial finality until verified |
| `SENSOR_CONFIDENCE_HOLD` | Block high-impact action from uncertain sensor |
| `AI_ROUTE_DEGRADATION` | Disable AI advisory route without blocking truth |
| `LOCAL_FALLBACK_CONTAINMENT` | Allow limited store operation under local mode |
| `DR_FAILOVER_CONTAINMENT` | Prevent split-brain and duplicate processing |
| `POLICY_FREEZE` | Freeze risky policy mutation during incident |

Containment must be explicit, auditable, and reversible through approved recovery.

---
```

```text
## 5. Circuit Breaker State Skeleton

Recommended circuit breaker states:

| State | Meaning |
|---|---|
| `CIRCUIT_CLOSED` | Normal operation |
| `CIRCUIT_WARNING` | Error/latency rising |
| `CIRCUIT_OPEN` | Route blocked |
| `CIRCUIT_HALF_OPEN` | Limited probe allowed |
| `CIRCUIT_RECOVERING` | Recovery validation in progress |
| `CIRCUIT_FORCED_OPEN` | Manually/security-forced open |
| `CIRCUIT_PROVIDER_MAINTENANCE` | Provider maintenance |
| `CIRCUIT_DEGRADED` | Reduced capability mode |
| `CIRCUIT_UNKNOWN` | Circuit state uncertain |
| `CIRCUIT_REVIEW_REQUIRED` | Human/security review required |
| `CIRCUIT_CLOSED_VERIFIED` | Closed after verification |

Circuit close must require verification.

---
```

```text
## 16. Security Quarantine Boundary

Security quarantine applies when malicious or suspicious activity is detected.

Quarantine candidates:

- cross-tenant access attempt
- direct DB mutation attempt
- privileged action anomaly
- token replay
- Host header attack
- internal RPC exposure
- provider spoof
- device compromise
- queue secret leakage
- AI prompt injection risk
- sensor tampering
- WORM audit failure
- ledger hash mismatch
- admin/support abuse

Quarantine may isolate:

- session
- actor
- device
- tenant
- store
- route
- provider adapter
- queue topic
- export job
- policy change

Quarantine release requires authority gate and audit.

---
```

```text
## 17. Tenant Noisy Neighbor Containment Boundary

Tenant-specific overload must not harm other tenants.

Noisy neighbor signals:

- excessive API calls
- queue flooding
- export abuse
- analytics-heavy query
- AI/vector overuse
- provider retry storm
- device reconnect storm
- bulk import abuse
- malicious scanning
- abnormal payment attempts

Containment actions:

- tenant rate limit
- tenant queue isolation
- tenant circuit breaker
- downgrade non-critical features
- require review
- preserve tenant isolation
- notify platform operations

Tenant overload must be contained at tenant boundary.

---
```

```text
## 18. Store-Level Containment Boundary

Store-specific failure must not affect other stores.

Store-level containment applies to:

- internet outage
- POS failure
- KDS failure
- device infection
- printer failure
- staff account abuse
- local hub compromise
- store network attack
- sensor failure
- local mesh conflict

Containment actions:

- isolate store routes
- preserve tenant-level functions for other stores
- block cross-store propagation
- create store incident
- use local fallback
- require store recovery evidence

Store failure must not become tenant-wide failure unless scope demands escalation.

---
```

```text
## 29. Recovery Boundary

Recovery starts after containment.

Recovery must include:

- root cause candidate
- affected scope
- affected objects
- evidence packet
- reconciliation plan
- rollback/compensation plan
- authority decision
- human review if needed
- audit
- safe projection update
- postmortem if high impact

Recovery is not complete until verified.

---
```

```text
## 35. Relationship To Authority Gate

Containment actions must pass authority gate when high-impact.

Examples requiring authority:

- manual circuit open/close
- settlement hold release
- security quarantine release
- provider route re-enable
- policy freeze release
- DR failover promotion
- financial hold release
- tenant throttle override
- device reprovision
- fallback finalization

Containment can be automatic under policy.

Release often requires stronger authority.

---
```

```text
## 36. Relationship To Tenant Scope Envelope

Containment must be scoped.

Containment may apply to:

- route
- tenant
- store
- device
- provider
- actor
- session
- surface
- queue partition
- shard
- policy family
- event family

Containment must not over-block unrelated tenants/stores without reason.

Containment must not under-block affected scope.

---
```

```text
## 42. Final Rule

Failure must be contained before it spreads.

A provider outage must not corrupt internal ledger.

A tenant overload must not harm other tenants.

A store device failure must not stop financial evidence capture.

A sensor false positive must not trigger billing.

An AI failure must not block source truth.

A queue spike must not reach financial core uncontrolled.

A timeout must become uncertainty, not silent success or silent failure.

Circuit breaker, DLQ, quarantine, financial hold, degraded mode, fallback, and recovery are separate states.

Containment protects the platform, but recovery requires evidence, reconciliation, authority, audit, and verification.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
```

### §9.2.3 suspended block · 분리 · 애매점 · 제외

| 항목 | 기록 |
|---|---|
| AUTHORITY SUSPENDED 블록 | 없음 |
| 원 정책과 후대 삽입 | 식별된 AUTHORITY SUSPENDED 후대 삽입 블록 0건; 위 인용은 문서 본문 절에서 옮김 |
| 문서 내부의 모순 · 애매점 | §17은 tenant-local overload를 tenant boundary에서 contain하도록 요구하고 §18은 store-local failure를 가능한 한 store-local로 유지하도록 요구함; store에서 tenant로 범위를 넓히는 risk·scope 조건의 구체 판정식은 열거하지 않음 |
| 제외한 절과 사유 | §6~§15, §19~§28, §30~§34, §37~§41은 전체 구조에는 기록했으며, tenant/store 격리 경계·release authority·recovery와 직접 맞닿은 절의 원문을 위에 옮김 |

## §9.3 A1' 상세 — 010660 Idempotency Retry Replay Reconciliation

### §9.3.1 식별 · 지위 · 전체 절 구조

| 항목 | 기록 |
|---|---|
| 정확한 경로 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` |
| 현재 지위 | ACTIVE — A3에서 A1으로 승격(2026-09-02) |
| 승격 기록 근거 | Stage 6에서 멱등성 키 출처가 미해결로 기록된 주제 |
| 전체 절 구조 | Purpose; §2 Core Position; §3 Scope; §4 Idempotency Key Inputs; §5 Idempotency Record; §6 Idempotency States; §7 Retry Policy; §8 Retry Classes; §9 Retryable vs Non-Retryable; §10 Timeout and Unknown Outcome; §11 Duplicate Request Handling; §12 Replay Policy; §13 Replay Modes; §14 Reconciliation Policy; §15 Reconciliation Case; §16 Reconciliation States; §17 Payment Idempotency; §18 Refund Idempotency; §19 Authorization Release Idempotency; §20 Payout Idempotency; §21 Order Idempotency; §22 KDS Idempotency; §23 Supplier Idempotency; §24 Notification Idempotency; §25 Webhook Idempotency; §26 Sensor Event Idempotency; §27 IoT Command Idempotency; §28 Export Idempotency; §29 Projection Replay; §30 DR Replay; §31 Manual Replay Authority; §32 Reconciliation Close Checklist; §33 Audit Requirements; §34 Observability; §35 Failure Handling; §36 Idempotency Retention; §37 Scope-Bound Idempotency; §38 Abuse and Collision Protection; §39 Suggested Conceptual Entities; §40 Example Flows; §41 Testing Requirements; §42 Policy Questions; §43 Boundary; §44 Final Rule |

### §9.3.2 0-A-2 관련 절 — 원문

```text
## 2. Core Position

Idempotency and reconciliation are mandatory for every high-impact flow.

The correct rule is:

Retry is not new intent.  
Replay is not overwrite.  
Duplicate event is not duplicate action.  
Timeout is not success.  
Timeout is not final failure.  
Provider delay is not internal truth.  
Offline sync is not silent merge.  
Batch rerun is not mutation replay.  
Reconciliation is not overwrite.  
Correction is append-only amendment.  
DLQ is not deletion.  
Idempotency key protects action, not authority.  
Idempotency pass does not bypass policy.  
Reconciled means matched or reviewed, not guessed.  

Every high-impact command must be safe to retry, safe to detect as duplicate, safe to replay for evidence, and safe to reconcile when external truth arrives late.

---
```

```text
## 4. Idempotency Key Boundary

Idempotency key must identify one business action.

Recommended key inputs may include:

- tenant id
- store id
- actor/customer reference
- command type
- target object id
- payment/order/preorder id
- provider id
- amount/currency where applicable
- business date
- policy version
- payload hash
- request nonce
- source surface
- device id
- time bucket if policy requires

Idempotency key must not be reused across unrelated actions.

Idempotency key must not contain raw secrets.

---
```

```text
## 5. Idempotency Record Fields

Recommended idempotency record fields:

| Field | Meaning |
|---|---|
| `idempotency_record_id` | Internal record id |
| `idempotency_key` | Key submitted or derived |
| `tenant_id` | Tenant scope |
| `store_id` | Store scope if applicable |
| `actor_ref` | Actor/customer reference |
| `command_type` | Command family |
| `target_object_id` | Target object |
| `payload_hash` | Payload hash |
| `request_status` | Processing status |
| `first_seen_at` | First request time |
| `last_seen_at` | Last duplicate/retry time |
| `result_ref` | Result reference |
| `result_status` | Result status |
| `attempt_count` | Attempts |
| `conflict_marker` | Conflict status |
| `replay_allowed` | Whether replay allowed |
| `retention_class` | Retention class |
| `audit_ref` | Audit reference |

Idempotency record is evidence.

It is not authority by itself.

---
```

```text
## 6. Idempotency State Skeleton

Recommended states:

| State | Meaning |
|---|---|
| `IDEMPOTENCY_NOT_CHECKED` | No check yet |
| `IDEMPOTENCY_CHECKING` | Checking key |
| `IDEMPOTENCY_FIRST_SEEN` | First request |
| `IDEMPOTENCY_IN_PROGRESS` | Processing in progress |
| `IDEMPOTENCY_COMPLETED` | Completed with result |
| `IDEMPOTENCY_DUPLICATE_RETURN_RESULT` | Duplicate returns existing result |
| `IDEMPOTENCY_DUPLICATE_IN_PROGRESS` | Duplicate while still processing |
| `IDEMPOTENCY_PAYLOAD_CONFLICT` | Same key, different payload |
| `IDEMPOTENCY_SCOPE_CONFLICT` | Scope mismatch |
| `IDEMPOTENCY_EXPIRED` | Key expired |
| `IDEMPOTENCY_REPLAY_REVIEW_REQUIRED` | Replay requires review |
| `IDEMPOTENCY_DLQ_REQUIRED` | DLQ required |

Same key with different payload must not execute.

---
```

```text
## 7. Retry Boundary

Retry repeats an attempted action after temporary failure or uncertainty.

Retry must define:

- retryable error classes
- non-retryable error classes
- max retry count
- backoff policy
- jitter
- idempotency key
- circuit breaker state
- provider route state
- timeout state
- DLQ threshold
- human review threshold
- audit trail

Retry must not create a retry storm.

Retry must not duplicate payment, payout, supplier order, KDS ticket, or IoT command.

---
```

```text
## 10. Timeout Boundary

Timeout means result is unknown unless verified.

Timeout may occur in:

- payment authorization
- capture
- refund
- auth release
- provider callback wait
- POS handoff
- KDS handoff
- printer job
- IoT command
- supplier order
- payout
- split payout
- export generation
- queue worker
- database transaction
- DR/failover
- local sync
- AI/vector job

Timeout must create uncertainty state.

Timeout must not be marked success or final failure without verification.

---
```

```text
## 12. Replay Boundary

Replay reprocesses an existing event or command for recovery, audit, projection rebuild, or reconciliation.

Replay must never overwrite original history.

Replay must carry:

- original event id
- replay id
- replay reason
- replay actor/system
- replay scope
- replay window
- expected state
- current state
- idempotency result
- replay result
- reconciliation effect
- audit reference

Replay is controlled evidence processing.

Replay is not mutation unless a new command is explicitly produced and authorized.

---
```

```text
## 14. Reconciliation Boundary

Reconciliation compares conflicting or incomplete records.

Reconciliation may compare:

- internal ledger
- provider callback
- provider settlement file
- POS/terminal log
- OS/runtime log
- device signature log
- offline event chain
- KDS/POS state
- customer app state
- bank/account verification
- supplier invoice
- inventory receipt
- batch close snapshot
- WORM/hash chain
- AI/vector evidence reference
- sensor evidence
- support case

Reconciliation does not mutate source truth.

Reconciliation produces decision, amendment candidate, hold release, or review route.

---
```

```text
## 32. Reconciliation Closing Boundary

Before closing reconciliation case:

- evidence complete or exception documented
- state matched or amendment proposed
- financial hold resolved or maintained
- DLQ handled
- reviewer recorded if needed
- audit recorded
- projection updated
- batch/ledger references updated
- WORM/hash continuity preserved if critical

Closing without evidence is prohibited.

---
```

```text
## 37. Idempotency And Tenant Scope Boundary

Idempotency key must be scope-bound.

Same idempotency key in different tenants must not collide.

Same idempotency key across stores must be evaluated by scope.

Cross-tenant idempotency leakage is prohibited.

Idempotency record must carry tenant/store/legal scope.

---
```

```text
## 44. Final Rule

Every high-impact action must be idempotent, retry-safe, replay-safe, and reconciliation-ready.

Retry must not create duplicate execution.

Replay must not overwrite history.

Timeout must create uncertainty, not false success or false failure.

Provider delay must be reconciled.

Offline sync must be verified before central acceptance.

Batch replay must not silently change frozen truth.

Correction must be append-only amendment.

DLQ contains unsafe or unprocessable records.

Reconciliation converts uncertainty into evidence-supported resolution.

Runtime implementation remains deferred until a separate explicit authorization packet is approved.
```

### §9.3.3 suspended block · 분리 · 애매점 · 제외

| 항목 | 기록 |
|---|---|
| AUTHORITY SUSPENDED 블록 | 없음 |
| 원 정책과 후대 삽입 | 식별된 AUTHORITY SUSPENDED 후대 삽입 블록 0건; 위 인용은 문서 본문 절에서 옮김 |
| 문서 내부의 모순 · 애매점 | §4는 키 설계에 고려할 입력을 열거하지만 키를 누가 생성·제공하는지와 각 command family의 필수 조합은 정하지 않음; §36 retention boundary와 재사용 가능 시점의 구체 기간은 이 문서에서 수치화하지 않음 |
| 제외한 절과 사유 | §8~§9, §11, §13, §15~§31, §33~§36, §38~§43은 전체 구조에는 기록했으며, 미해결로 기록된 idempotency key 출처·scope·replay/reconciliation authority와 직접 맞닿은 절의 원문을 위에 옮김 |

## §10 A2 상세 — 601702

### §10.1 전체 절 구조

| 구간 | 구조 |
|---|---|
| §0 | 성격 |
| §1 | Human 선언 §1.1~§1.45 — 45건 |
| §2 | 이번 나선에서 정하지 않는 것 §2.1~§2.4 |
| §3 | `601500`과의 관계 |
| §4 | 근거 문서 목록 |
| §5 | 확정 기록 |

45건의 heading 전수:

| 번호 | 제목 |
|---:|---|
| 1 | 자연인은 `Person`이다 |
| 2 | 무수식 `Owner`를 금지한다 |
| 3 | 조직역할과 지분소유는 별개 개념이다 |
| 4 | 매장의 법적 운영주체와 시스템 권한은 다른 축이다 |
| 5 | 네 축은 서로 독립이다 |
| 6 | 가맹계약은 독립 개념이다 |
| 7 | 고객사 내부 권한과 프랜차이즈 횡단 권한은 분리한다 |
| 8 | Franchise HQ의 권한은 계약 기반 Scope이다 |
| 9 | `HQ` 어휘는 CatchMenu 관리 인터페이스에만 사용한다 |
| 10 | 세 세계를 하나의 조직도로 합치지 않는다 |
| 11 | 그룹 계열 관계는 SaaS 권한이 아니다 |
| 12 | 같은 실체가 두 시스템에서 다른 정체성을 가진다 |
| 13 | LegalEntity는 브랜드를 넘을 수 있다 |
| 14 | MerchantAccount 경계는 다른 축의 경계와 같다고 가정하지 않는다 |
| 15 | 신원은 JWT에서 해석하고 권한은 DB에서 확인한다 |
| 16 | Person · User · Staff는 서로 다른 개념이다 |
| 17 | Person의 존재론적 경계 |
| 18 | 0-B 인계 조건 및 근거 |
| 19 | Role · Permission · Scope는 삼각으로 평가한다 |
| 20 | Scope Type과 Scope Level의 혼합을 현재 정답으로 사용하지 않는다 |
| 21 | `company` / `business_unit`은 CatchMenu 내부 조직축이다 |
| 22 | Tenant와 MerchantAccount는 다른 개념이며 1:1로 시작한다 |
| 23 | MerchantAccount와 LegalEntity는 독립이다 |
| 24 | 각 Store는 현재 시점의 법적 운영주체를 명시한다 |
| 25 | `Merchant Company` 용어 정규화 |
| 26 | Store의 구조 부모는 MerchantAccount이며 Tenant는 격리 scope다 |
| 27 | Store 상태는 서로 다른 의미축으로 분리한다 |
| 28 | 상위 객체 상태로 하위 객체 상태를 대신하지 않는다 |
| 29 | `company` 어휘의 두 층위를 구분하고 고객사-side 의미를 정규화한다 |
| 30 | OperatingGroup은 독립 운영 grouping 축이며 persistence는 미결이다 |
| 31 | LegalEntity의 business identity source는 검증된 영업 intake다 |
| 32 | `store_operator_type`은 LegalEntity와 별개 축이다 |
| 33 | cross-business link는 참조이며 권한이 아니다 |
| 34 | Store의 법적 운영주체는 시점 관계다 |
| 35 | 금전 객체는 LegalEntity snapshot을 보유한다 |
| 36 | Store의 LegalEntity 변경과 Tenant 이전은 다른 사건이다 |
| 37 | `owners`를 `persons`로, `owner_id`를 `person_id`로 정규화한다 |
| 38 | `is_active`를 사람 레코드에서 제거한다 |
| 39 | `ownership_percent`를 역할 테이블에서 제거한다 |
| 40 | SaaS Architecture는 처음부터, SaaS Business Operations는 나중에 |
| 41 | 판별 기준 — 두 번째 음식점이 들어와도 그대로 쓸 수 있는가 |
| 42 | 네 시스템의 경계를 어휘로 고정한다 |
| 43 | 외부 시스템 연결은 CM-PLAT의 tenant/store 경계에 귀속된다 |
| 44 | `MerchantAccount`의 canonical 물리 정의 |
| 45 | `MerchantAccount`의 생성·배치·초기 보안 posture |

### §10.2 0-A-2 관련 절 원문

`§1.22`:

```text
`Tenant` 는 CatchMenu 의 **SaaS 고객조직 및 최상위 데이터 격리 경계**다.

`MerchantAccount` 는 **CatchMenu 서비스 계약·관리·권한 scope** 다.

**두 개념은 동일하지 않다.** 그러나 **이번 나선에서는 1:1 로 확정한다.**

**`Tenant` 는 보안상 같은 고객조직을 뜻하며 "같은 브랜드 식구들"을 뜻하지 않는다.**
```

`§1.26`:

```text
Tenant
  │ 1:1 (§1.22, 이번 나선)
  ▼
MerchantAccount
  │ 1:N
  ▼
Store
```

```text
**Tenant 는 Store 의 두 번째 구조 부모가 아니라 필수 격리 scope 다.**

> **Invariant**: 모든 Store 는 Tenant scope 를 보유하고 검증해야 한다.
```

`§1.27`:

```text
Store 의 상태를 하나의 범용 `store_status` 로 표현하지 않는다.
최소한 아래 **세 의미축을 서로 독립된 개념**으로 구분한다.
```

| 축 | 묻는 질문 |
|---|---|
| **Store Service Status** | 해당 Store에 대한 CatchMenu 서비스 제공 상태는 무엇인가 |
| **Store Operating Status** | 실제 음식점이 영업 중인가 |
| **Trial Status** | CatchMenu 체험·전환 lifecycle이 어디까지 갔는가 |

`§1.28`:

```text
TenantStatus
  ≠ MerchantAccountStatus
  ≠ StoreServiceStatus
  ≠ StoreOperatingStatus
  ≠ TrialStatus
  ≠ IsolationState

각 계층은 자신의 상태를 갖는다. 상위 상태를 하위 상태의 대체물로 사용하지 않는다.
```

`§1.40`:

```text
**멀티테넌시는 나중에 붙일 수 있는 기능이 아니라 데이터 모델의 뼈대다.**

1호점부터 반드시 SaaS 구조로 만드는 것

tenant / store
사용자 계정 · 로그인
tenant_id · store_id
Role / Permission / Scope
직원이 어느 tenant/store 소속인지
고객·멤버십 데이터의 tenant 귀속
메뉴·재고·직원·KDS 데이터의 tenant/store 귀속
Tenant 간 데이터 격리
외부 시스템 credential 및 merchant/store mapping
모든 핵심 객체의 ownership boundary
```

`§1.43`:

```text
외부 provider 의 credential 과 merchant/store mapping 은
**플랫폼 구조의 일부**이며 §1.40 의 뼈대에 포함된다.

**연결은 tenant/store 단위로 귀속된다.**
```

### §10.3 내부 모순·애매점·제외

| 항목 | 기록 |
|---|---|
| 현재 지위 | Active Register, Human 선언 45건 |
| 원천 정책과의 구분 | A1이 아니라 A2로 분리 |
| suspended 연계 | §3이 `601500`을 suspended 상태로 기록 |
| 제외 | `601801`의 Human Rule은 인용·사용하지 않음 |

## §11 A3 Discovery Inventory

### §11.1 전체 절 구조와 관련 지점

| 문서 | 전체 절 구조 | 0-A-2 관련 지점 | suspended block | 제외 사유 |
|---|---|---|---|---|
| `010610` | Purpose; §2~§42 | §6 Mandatory Event Envelope; §15 DLQ; §16 Quarantine; §22 Tenant Scope; §29 Audit; §31 Security | 없음 | A3 유지 — 격리 중 event 전달; Integration Isolation 이월 소관 |
| `010620` | Purpose; §2~§43 | §4 Command; §5 Fields; §14 Audit; §16 DLQ; §32~§34 gates; §37 Evidence-First | 없음 | A3 유지 — projection separation; 1단계가 필요하면 본다 |
| `010630` | Purpose; §2~§44 | §5 Authority Context; §6 Decision State; §9 Scope Gate; §13 Evidence; §21 Idempotency; §22 Audit; §24 Circuit Breaker; §28 Deny | 없음 | **A1 승격 (2026-09-02)** — 격리 발동 권한과 같은 주제 |
| `010650` | Purpose; §2~§42 | §3 Containment; §5~§7 Circuit Breaker; §16 Security Quarantine; §17 Tenant; §18 Store; §29 Recovery; §30 Reclose; §32 Evidence | 없음 | **A1 승격 (2026-09-02)** — 격리는 containment이며 이 문서가 containment 정책을 기록 |
| `010660` | Purpose; §2~§44 | §3~§17 idempotency/retry/replay/reconciliation; §29 Evidence; §36 Storm; §37 Tenant Scope | 없음 | **A1 승격 (2026-09-02)** — S6-8 멱등성 키 출처 미해결과 같은 주제 |
| `010670` | Purpose; §2~§46 | §3 Projection; §12 Masking; §16 Franchise HQ; §17 Support; §31 Freshness; §40 Tenant Scope | 없음 | A3 유지 — safe projection·i18n; 1단계가 필요하면 본다 |
| `010680` | Purpose; §2~§45 | §5 Correlation Key; §6 Audit Fields; §17 Security; §27 Gap; §28 Cross-Tenant Audit; §29 Evidence | 없음 | A3 유지 — audit correlation; R-6과 인접하며 1단계가 필요하면 본다 |
| `010690` | Purpose; §2~§28 | §10 Authority Gate; §11 Tenant Scope; §14 Containment; §15 Idempotency; §17 Audit; §18 Gate Order | 없음 | A3 유지 — closure; 1단계가 필요하면 본다 |

### §11.2 발견 근거 원문 (`010640` §41)

```text
This document follows:

- `10630 Authority Capability Gate Policy`

It prepares:

- `10650 Failure Containment Circuit Breaker Policy`
- `10660 Idempotency Retry Replay Reconciliation Policy`
- `10670 Safe Projection i18n Routing Policy`
- `10680 Audit Correlation Nightly Batch Policy`
- `10690 Cross-Room Plumbing Closure Policy`

It references:

- `10141 SaaS Tenant Isolation And Cross-Tenant Data Containment Beam Policy`
- `10610 Cross-Room Event Bus And Evidence Packet Routing Policy`
- `10620 Command Query Projection Separation Policy`
- `10630 Authority Capability Gate Policy`
```

## §12 A4 Suspended Evidence

### §12.1 601500 대역 — 13건

| 문서 | 현재 지위 | suspended block 위치 | 사용 |
|---|---|---|---|
| `601500_Readme_Operational_Authority_Foundation.md` | SUSPENDED | 대역 Readme 상단 | 상태·목록만 |
| `601501_ERD_Tenant_Company_HQ_Store.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601502_Overview_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601503_Logic_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601506_Verification_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601507_Verification_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601508_Audit_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | SUSPENDED by band | 개별 명시 없음 | evidence만 |
| `601510_AuditReview_Stage11B_Blind_Audit.md` | SUSPENDED by band | 개별 명시 없음 | finding evidence만 |
| `601511_AuditReview_Stage11A_Final.md` | SUSPENDED by band | 개별 명시 없음 | historical decision only |
| `601512_Baseline_Summary.md` | SUSPENDED | 상단 표시 | evidence만 |

### §12.2 601600 대역 — 2건

| 문서 | 파일 자체 지위 | provenance 사실 | 사용 |
|---|---|---|---|
| `601600_Readme_Upstream_Doctrine_Backpropagation.md` | Active | §1이 `601500`이 구현·검증한 구조를 상위 정본에 역전파한다고 기록 | 삽입 출처 식별 |
| `601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | 적용 완료 표기 | §3이 000150·000170·010004 등 5개 문서 개정 삽입 초안을 기록 | 삽입 출처 식별 |

### §12.3 601800 대역 — 17건

| 문서 | 개별 상태 | 대역 상태 | 이 Pass 사용 |
|---|---|---|---|
| `601800_Readme_Tenant_Lifecycle_Rpc_Alignment.md` | Suspended | SUSPENDED | 대역 상태 근거 |
| `601801_Register_Stage1_Business_Rules.md` | 파일 존재 | SUSPENDED | 사용하지 않음 |
| `601802_Register_Stage0_Evidence_Collection.md` | Active 표기 | SUSPENDED | 값 복사하지 않음; 구조만 확인 |
| `601803_Diagram_Tenant_Lifecycle_State_Machine.md` | 파일 존재 | SUSPENDED | 사용하지 않음 |
| `601804_Audit_Stage3_Adjacent_Domain_Codex.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601805_Audit_Stage3_Adjacent_Domain_Cowork.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601806_Audit_Stage3_Adjacent_Domain_Claude.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601807_Report_Stage3_Integration.md` | 파일 존재 | SUSPENDED | 판정 승계 안 함 |
| `601808_Report_Stage3_Impact_Reconciliation.md` | 파일 존재 | SUSPENDED | 판정 승계 안 함 |
| `601809_Overview_Tenant_Lifecycle_Rpc_Alignment.md` | 파일 존재 | SUSPENDED | 설계 결론 승계 안 함 |
| `601810_Logic_Tenant_Lifecycle_Rpc_Alignment.md` | 파일 존재 | SUSPENDED | 설계 결론 승계 안 함 |
| `601811_TestPlan_Tenant_Lifecycle_Rpc_Alignment.md` | 파일 존재 | SUSPENDED | 설계 결론 승계 안 함 |
| `601812_ChangeContract_Tenant_Lifecycle_Rpc_Alignment.md` | 파일 존재 | SUSPENDED | 설계 결론 승계 안 함 |
| `601813_Audit_Stage6_Contract_Verification_Codex.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601814_Audit_Stage6_Contract_Verification_Cowork.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601815_Audit_Stage6_Contract_Verification_Claude.md` | 파일 존재 | SUSPENDED | finding 원본 존재만 기록 |
| `601816_Report_Stage6_Round1_Integration.md` | Active 표기 | SUSPENDED | finding 15건·informational 25건의 목록 존재만 기록 |

### §12.4 601816 finding 목록

| ID | 원문이 기록한 사실 주제 | 설계 결론 전환 |
|---|---|---|
| S6-1 | 계약이 만든 객체에 쓰는 주체·호출 경로 없음 | 하지 않음 |
| S6-2 | `p_isolate := false`가 3요건을 거치지 않는 두 번째 해제 경로 | 하지 않음 |
| S6-3 | 공식 해제 경로의 플래그를 참으로 만드는 조작 없음 | 하지 않음 |
| S6-4 | 신규 함수 3건의 기본 PUBLIC EXECUTE와 owner-only 주장 충돌 | 하지 않음 |
| S6-5 | 네 함수의 보안속성 미확정 | 하지 않음 |
| S6-6 | `authenticated`가 실행 가능한 SECURITY DEFINER 경로 | 하지 않음 |
| S6-7 | 두 단일 컬럼 FK로 tenant 일치 미강제 | 하지 않음 |
| S6-8 | idempotency key 출처 미확정 | 하지 않음 |
| S6-9 | `p_operation` 정의역과 상태 매핑 미확정 | 하지 않음 |
| S6-10 | 해제 함수의 갱신·추가·감사 동작 미확정 | 하지 않음 |
| S6-11 | 상위 범위 문서와 하위 구현 요구 간 범위 공백 | 하지 않음 |
| S6-12 | 계약 입력 출처 부재 3건 | 하지 않음 |
| S6-13 | 사전조건 비교 기준 부재 | 하지 않음 |
| S6-14 | 하위 문서가 상위 OUT_OF_SCOPE 기록을 뒤집음 | 하지 않음 |
| S6-15 | baseline 함수 계수 근거 불일치 | 하지 않음 |

## §13 Suspended block 분리 결과

| 문서 | 원 정책 | 후대 삽입 | suspended 경계 | Pass 1 처리 |
|---|---|---|---|---|
| `000150` | baseline L73~L823, numbered §1~§33 | L10~L70, 2026-08-11 구현 대응·개념 이전 블록 | L10에서 `AUTHORITY SUSPENDED`; 구현 대응표·테이블명·판정식·상태값은 인용 금지 | §7.2는 원 정책만 인용; 후대 블록은 위치와 지위만 기록 |
| `000170` | baseline L10~L384의 §1~§13 및 L451~L1021의 §14~§39 | L385~L449, 상태 어휘 구현 대응·백로그 블록 | L385에서 `AUTHORITY SUSPENDED`; wrapper가 §14~§16 `SUPERSEDED` 선언을 철회 | §8.2는 원 정책만 인용; 후대 상태값·판정식은 사용하지 않음 |
| `010004` | §2~§29의 tenant isolation policy | §4.1의 2026-08-11 global table 해설 | §4.1 내부 wrapper가 `601500` 기반 구현 대응을 suspended로 표시 | §5.2는 §2·§4·§5·§7·§19·§20·§24·§29 원 정책을 인용; §4.1 구현 대응은 사용하지 않음 |
| `601800` 대역 | 해당 없음 | 대역 전체가 선행 0-A-2 산출물 | Readme 상단에서 전 문서 authority 없음 명시 | finding 존재만 A4에 기록 |

`600020` §1.2 원문:

```text
0-A 권위 보류에 따라 그것을 선행조건으로 삼은 판정도 함께 보류한다.

| 대상 | 기존 기록 | 현재 |
|---|---|---|
| 0-A-2 | 다음 필수 착수 | **HOLD** |
| 0-A-3 | 미착수 | **HOLD** |
| 0-B | 착수 가능 (0-A 완료로 선행조건 해소) | **HOLD** — 근거 소멸 |
```

## §14 Unresolved Provenance Questions

판정하지 않는다.

| # | 질문 | 확인된 배경 |
|---:|---|---|
| Q-P1 | `010004` §4.1에서 suspended wrapper 바깥 문장까지 어느 commit에서 삽입됐는가? | 문서 본문은 문장별 provenance를 표시하지 않음 |
| Q-P2 | `000150` 후대 삽입 중 “개념 구분 경고는 유효” 범위의 정확한 문장 경계는 어디인가? | wrapper는 범주만 표시함 |
| Q-P3 | `000170`의 “§14~§16 SUPERSEDED 철회”와 잔존한 `SUPERSEDED` heading을 후속 문서가 어떻게 인용해야 하는가? | 상반된 문구가 동시에 보존됨 |
| Q-P4 | `010640`의 `merchant_id`(provider-side merchant account)와 `000170`의 `Merchant Account` 사이에 canonical 용어 구분 문서가 있는가? | 두 문서가 다른 의미로 merchant account 어휘를 사용함 |
| Q-P5 | `010640` §5의 “should carry”와 §2·§42의 “must” 사이 적용 강도를 어느 절이 우선 정의하는가? | 문구 강도가 혼재함 |
| Q-P6 | A3 8건 중 `601900` 1단계가 mandatory authority로 채택해야 할 문서가 있는가? | `010640` §41은 관계만 기록하며 승격을 지시하지 않음 |
| Q-P7 | `601600` 파일 자체 Active 표기와 그 역전파 결과의 suspended wrapper 사이에서 대역 지위를 어떤 단위로 표현해야 하는가? | source에는 파일 지위와 삽입 내용 지위가 함께 존재함 |
| Q-P8 | `601816` 15 findings 중 Pass 2 재측정 대상으로 선택할 범위는 무엇인가? | 이번 Pass는 finding 존재만 기록하며 설계·검증 범위를 정하지 않음 |
| Q-P9 | `010630`의 권고 authority state와 실제 격리 발동·해제 authority 사이 canonical 매핑은 어디에서 정하는가? | `010630`은 state skeleton과 gate family를 기록하지만 이 나선의 물리 주체·호출 경로는 기록하지 않음 |
| Q-P10 | `010650`의 tenant/store/route containment 단위와 기존 isolation state 사이 대응은 어디에서 정하는가? | `010650`은 복수 containment scope와 circuit state를 기록함 |
| Q-P11 | `010660`의 idempotency key를 제출하는지 파생하는지, 파생한다면 어느 주체가 어떤 입력으로 만드는가? | §4는 recommended inputs, §5는 “submitted or derived”를 기록함 |
| Q-P12 | `010630`·`010650`·`010660`을 이 나선의 구속으로 채택할 것인가? | `600021` §2는 5건만 강제했다; 셋은 `010640` §41에서 발견했고 직접 관련이 확인됐다; 채택 여부는 1단계 Human 판정 대상이다 |

## §15 근거 문서 목록 (`000701` §46)

### §15.1 통제·착수 근거 — 4건

| 문서 | 사용 |
|---|---|
| `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §46, §48 |
| `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1.2 파생 HOLD |
| `docs/600000_implementation_lifecycle/600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | §2 mandatory source·승계 금지 |
| `docs/600000_implementation_lifecycle/601900_tenant_isolation_axis_v2/601900_Readme_Tenant_Isolation_Axis_V2.md` | §4 구속·§7 boundary references |

### §15.2 A1 — 5건

| 문서 | 포함 |
|---|---|
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | 포함 |
| `010640_Policy_Tenant_Scope_Envelope.md` | 포함 |
| `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | 포함 |
| `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | 포함 |
| `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | 포함 |

### §15.3 A2 — 1건

| 문서 | 포함 |
|---|---|
| `601702_Register_Stage1_Business_Rules.md` | Human 선언 45건 전건 heading 확인; A1과 분리 |

### §15.4 A3 — 8건

| 문서 | 포함 방식 |
|---|---|
| `010610` | discovery only |
| `010620` | discovery only |
| `010630` | discovery only |
| `010650` | discovery only |
| `010660` | discovery only |
| `010670` | discovery only |
| `010680` | discovery only |
| `010690` | discovery only |

### §15.5 A4 — 32건

| 대역 | 문서 수 | 포함 방식 |
|---|---:|---|
| `601500` | 13 | suspended evidence inventory |
| `601600` | 2 | backpropagation provenance inventory |
| `601800` | 17 | suspended evidence inventory; finding 존재만 |

### §15.6 제외 기록

| 대상 | 제외 사유 |
|---|---|
| DB·SQL runtime 측정 | Pass 2 범위 |
| `601802` 측정값 | 재측정 없이 복사 금지 |
| `601816` 판정 | finding을 설계 결론으로 변환 금지 |
| `601801` Human Rule | suspended 대역의 답을 정답으로 사용 금지 |
| `601500`·`601600` 후대 구현 대응 | suspended block을 원천 정책으로 승격 금지 |

## §16 R1 측정 환경

측정값은 아래 read-only 세션에서 취득했다.

| 항목 | 실측값 |
|---|---|
| 컨테이너 이름 | `supabase_db_yoonsul_wait_order_handoff` |
| 컨테이너 ID | `b67400e8c73e4ec7b9a25b172d71af347dd22d5e269d49859629fc3d8bd935ec` |
| 이미지 | `public.ecr.aws/supabase/postgres:17.6.1.156` |
| DB version | `PostgreSQL 17.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 15.2.0, 64-bit` |
| database/user | `postgres` / `postgres` |
| 측정 시각 | `2026-09-02 09:26:16.24973+00` (`2026-09-02 18:26:16.24973 KST`) |
| `SHOW default_transaction_read_only` | `on` |
| migration success | 170건 |
| latest migration | `0171_merchant_account_foundation.sql`, success=`true`, applied_at=`2026-08-30 11:46:47.552241+00`, applied_by=`postgres` |
| failed migration | 1건 — `0073_final_verification.sql`, applied_at=`2026-08-07 04:41:02.602728+00` |
| 접속 명령 | `docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres` |

### §16.1 catchmenu 스키마별 테이블 수

| schema | table 수 |
|---|---:|
| `catchmenu_agent` | 4 |
| `catchmenu_ai` | 2 |
| `catchmenu_audit` | 1 |
| `catchmenu_common` | 41 |
| `catchmenu_dev` | 2 |
| `catchmenu_gateway` | 2 |
| `catchmenu_hq` | 21 |
| `catchmenu_integrations` | 19 |
| `catchmenu_kds` | 2 |
| `catchmenu_knowledge` | 14 |
| `catchmenu_ledger` | 6 |
| `catchmenu_meta` | 1 |
| `catchmenu_payment` | 11 |
| `catchmenu_pos` | 16 |
| `catchmenu_store` | 50 |
| 합계 | 192 |

## §17 R2 두 상태 축

### §17.1 컬럼·CHECK

| 컬럼 | 타입 | nullable | DEFAULT | CHECK 허용값 |
|---|---|---|---|---|
| `catchmenu_hq.tenants.tenant_status` | `text` | NO | `'TRIAL'::text` | `ACTIVE`, `TRIAL`, `SUSPENDED`, `CANCELLED`, `TERMINATED` |
| `catchmenu_hq.tenants.isolation_state` | `text` | NO | `'NONE'::text` | `NONE`, `ISOLATED` |

| constraint | 정의 전문 |
|---|---|
| `chk_tenants_status` | `CHECK ((tenant_status = ANY (ARRAY['ACTIVE'::text, 'TRIAL'::text, 'SUSPENDED'::text, 'CANCELLED'::text, 'TERMINATED'::text])))` |
| `chk_tenants_isolation_state` | `CHECK ((isolation_state = ANY (ARRAY['NONE'::text, 'ISOLATED'::text])))` |

### §17.2 참조 객체 전수

| 객체 종류 | 수 | 목록 |
|---|---:|---|
| FUNCTION — `tenant_status` | 7 | `catchmenu_common.get_hq_dashboard(text)`; `get_saas_revenue_report(date,date,text)`; `get_system_health_all(text)`; `get_tenant_list(text,text,text,integer,integer,text)`; `isolate_tenant(uuid,text,boolean,uuid,text)`; `manage_subscription(uuid,text,text,text,uuid,text)`; `provision_tenant(text,text,text,text,text,text,text,text,text,text,text)` |
| FUNCTION — `isolation_state` | 0 | 0건 |
| VIEW | 0 | 0건 |
| MATVIEW | 0 | 0건 |
| TRIGGER | 0 | 0건 |
| 다른 테이블의 관련 제약 | 0 | 0건 |

`provision_tenant`는 호출하지 않았다. D 기록은 **미검증 — 호출 금지**다.

## §18 R3 `isolate_tenant`

| 항목 | 실측값 |
|---|---|
| oid::regprocedure | `catchmenu_common.isolate_tenant(uuid,text,boolean,uuid,text)` |
| 인자 | `p_tenant_id uuid, p_isolation_reason text, p_isolate boolean, p_actor_id uuid, p_locale text` |
| 반환형 | `jsonb` |
| prosrc md5 / 길이 | `f53ea7f556e89cec883b9ca6b482ca3e` / 2,763 |
| SECURITY DEFINER | true |
| search_path | `catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` |
| proacl | `postgres=X/postgres`, `authenticated=X/postgres` |
| 참조 테이블 | `catchmenu_hq.tenants` UPDATE; `catchmenu_common.security_audit_log` INSERT; `catchmenu_ledger.events` INSERT |
| 상태 컬럼 | `tenant_status` READ/WRITE; `isolation_state` 문자열 참조 0건 |
| phantom | 참조 테이블·컬럼 phantom 0건; `tenant_status`에 `ISOLATED`를 쓰는 본문 경로가 있고 해당 CHECK 허용값에는 `ISOLATED`가 없음 |
| 정적 DB 호출자 | `catchmenu_common.detect_threat(...)`, `catchmenu_common.manage_subscription(...)` — 2건 |
| 비문서·비migration 앱 코드 literal | 0건 |
| D | **미검증 — 호출 금지(`601505` §4)** |

## §19 R4 `manage_subscription` · `detect_threat`

### §19.1 함수 카탈로그

| 함수 | oid::regprocedure / 반환형 | md5 / 길이 | SECURITY DEFINER / search_path | proacl |
|---|---|---|---|---|
| `manage_subscription` | `catchmenu_common.manage_subscription(uuid,text,text,text,uuid,text)` / `jsonb` | `3ceb5089e1c2305628db36e485be9bcd` / 4,520 | true / `catchmenu_common, catchmenu_hq, catchmenu_ledger` | `postgres`, `service_role` EXECUTE |
| `detect_threat` | `catchmenu_common.detect_threat(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` / `uuid` | `992c78c881be2f23bcac8050b60ad2b7` / 3,671 | true / `catchmenu_common` | PUBLIC, `postgres`, `authenticated` EXECUTE |

### §19.2 참조·phantom·호출자

| 함수 | 참조 테이블·컬럼 | phantom/정적 불일치 | 정적 DB 호출자 | D |
|---|---|---|---|---|
| `manage_subscription` | `catchmenu_hq.tenants`, `catchmenu_common.subscription_plans`, `tenant_plan_configs`, `subscription_invoices`, `catchmenu_ledger.events`; `tenant_status` READ/WRITE, `isolation_state` 0참조 | `catchmenu_hq.tenants.company_name`은 실제 컬럼 0건; `isolate_tenant` 호출의 named argument `p_reason :=` 2곳, 대상 함수 인자는 `p_isolation_reason` | 0건 | **미검증 — 호출 금지(`601505` §4)** |
| `detect_threat` | `catchmenu_common.security_threats`; operation alert 및 `isolate_tenant` 호출 | FATAL 경로의 `isolate_tenant` named argument `p_reason :=` 1곳 | `gateway_audit_entry`, `verify_security_token`, `record_van_transaction`, `check_staff_permission` — 4건 | **미검증 — 호출 금지(`601505` §4)** |

## §20 R5 격리 관련 기존 자산

### §20.1 컬럼·행 수·tenant scope

| 테이블 | 컬럼 수 | 컬럼 전수 | 행 수 | tenant_id |
|---|---:|---|---:|---|
| `catchmenu_common.offline_queue` | 16 | `id`, `tenant_id`, `store_id`, `device_id`, `action_type`, `action_payload`, `action_priority`, `queue_status`, `retry_count`, `max_retries`, `local_temp_id`, `server_result_id`, `queued_at`, `flushed_at`, `error_detail`, `expires_at` | 0 | NOT NULL; FK→`catchmenu_hq.tenants(id)` |
| `catchmenu_common.security_threats` | 24 | `id`, `tenant_id`, `store_id`, `device_id`, `threat_stage`, `threat_type`, `threat_severity`, `detected_at`, `detection_source`, `threat_vector`, `threat_payload`, `affected_resource`, `affected_resource_id`, `auto_blocked`, `block_applied_at`, `block_duration_minutes`, `block_scope`, `threat_status`, `resolved_at`, `resolved_by`, `resolution_note`, `is_escalated`, `escalated_at`, `escalation_level` | 0 | nullable; FK 0건 |
| `catchmenu_common.security_audit_log` | 16 | `id`, `tenant_id`, `store_id`, `audit_event`, `event_severity`, `event_source`, `actor_type`, `actor_id`, `actor_ip`, `resource_type`, `resource_id`, `event_detail`, `is_violation`, `was_blocked`, `action_taken`, `created_at` | 0 | NOT NULL; FK→`catchmenu_hq.tenants(id)` |
| `catchmenu_common.idempotency_keys` | 21 | `id`, `tenant_id`, `store_id`, `idempotency_key`, `key_domain`, `key_scope`, `operation_type`, `request_hash`, `processing_status`, `result_payload`, `error_payload`, `first_received_at`, `last_received_at`, `completed_at`, `replay_count`, `max_replay_allowed`, `source_device_id`, `provider_event_id`, `correlation_id`, `expires_at`, `created_at` | 0 | NOT NULL; FK→`catchmenu_hq.tenants(id)` |

### §20.2 제약·RLS·policy·GRANT

| 테이블 | 제약 | RLS/FORCE; policy | table GRANT 관측 |
|---|---|---|---|
| `offline_queue` | PK; FK tenant/store; CHECK `action_type` 12값, `queue_status` 6값 | true/true; authenticated ALL, tenant+store filter 1건 | `postgres`: SELECT/INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER, grantable YES |
| `security_threats` | PK; CHECK stage 1~4, severity 5값, status 5값, type 16값 | true/true; authenticated SELECT, tenant/null filter 1건 | `postgres`: 전 table privilege, grantable YES |
| `security_audit_log` | PK; FK tenant; CHECK severity 4값 | true/true; authenticated ALL, tenant filter 1건 | `postgres`: 전 table privilege, grantable YES |
| `idempotency_keys` | PK; FK tenant/store/device; UNIQUE `(tenant_id,key_domain,idempotency_key)`; CHECK domain/scope/status/replay/json 7건 | true/true; authenticated ALL, tenant filter 1건 | `postgres`: 전 table privilege, grantable YES |

### §20.3 `idempotency_keys` tenant scope 실측

| 항목 | 실측값 |
|---|---|
| tenant 컬럼 | `tenant_id uuid NOT NULL` |
| tenant FK | `idempotency_keys_tenant_id_fkey` → `catchmenu_hq.tenants(id)` |
| 고유 제약 | `UNIQUE (tenant_id, key_domain, idempotency_key)` |
| store 컬럼 | `store_id uuid`, nullable, FK→`catchmenu_hq.stores(id)` |
| store와 UNIQUE 관계 | `store_id`는 위 UNIQUE 구성열에 없음 |
| key_scope | NOT NULL, DEFAULT `STORE`; CHECK `GLOBAL`, `TENANT`, `STORE`, `SESSION` |
| RLS qual | `(tenant_id = catchmenu_common.current_tenant_id())` |

### §20.4 참조 함수

| 자산 | prosrc 정적 참조 함수 수 | 목록 |
|---|---:|---|
| `offline_queue` | 6 | `enqueue_offline_action`, `flush_offline_queue`, `get_fallback_config`, `get_network_dashboard`, `report_network_status`, `run_final_validation` |
| `security_threats` | 3 | `detect_threat`, `get_security_dashboard`, `run_security_scan` |
| `security_audit_log` | 12 | `check_tenant_quota`, `enforce_rate_limit`, `get_tenant_health`, `isolate_tenant`, `register_device`, `run_integration_test`, `run_saas_launch_checklist`, `run_security_audit`, `verify_device_trust`, `confirm_toss_payment_legacy_604260`, `process_toss_webhook`, `confirm_payment_webhook` |
| `idempotency_keys` | 1 | `catchmenu_integrations.intake_delivery_order(...)` |

## §21 R6 호출 금지 7함수

| 함수 | 존재·schema | md5 / 인자 | proacl | phantom·정적 관측 | 정적 DB 호출자 | D |
|---|---|---|---|---|---|---|
| `isolate_tenant` | 존재 / `catchmenu_common` | `f53ea7f556e89cec883b9ca6b482ca3e`; `(uuid,text,boolean,uuid,text)` | `postgres`, `authenticated` | phantom 0; CHECK 밖 write 경로 1 | `detect_threat`, `manage_subscription` | **미검증 — 호출 금지(`601505` §4)** |
| `manage_subscription` | 존재 / `catchmenu_common` | `3ceb5089e1c2305628db36e485be9bcd`; `(uuid,text,text,text,uuid,text)` | `postgres`, `service_role` | phantom `tenants.company_name`; 잘못된 named argument 2곳 | 0건 | **미검증 — 호출 금지(`601505` §4)** |
| `detect_threat` | 존재 / `catchmenu_common` | `992c78c881be2f23bcac8050b60ad2b7`; `(text,integer,text,text,jsonb,uuid,uuid,uuid,text,text)` | PUBLIC, `postgres`, `authenticated` | 참조 테이블 존재; 잘못된 named argument 1곳 | 4건 | **미검증 — 호출 금지(`601505` §4)** |
| `verify_security_token` | 존재 / `catchmenu_common` | `b5c978db183d70e025ff97cc2bd1785f`; `(text,text,text,boolean)` | PUBLIC, `postgres`, `authenticated` | `security_tokens` 존재; 정적 table/column phantom 0건 | 0건 | **미검증 — 호출 금지(`601505` §4)** |
| `gateway_audit_entry` | 존재 / `catchmenu_common` | `bbfac99ac170a83d988c610435a00732`; 15인자 | PUBLIC, `postgres`, `authenticated` | `gateway_audit_log` 존재; 정적 table/column phantom 0건 | 0건 | **미검증 — 호출 금지(`601505` §4)** |
| `record_van_transaction` | 존재 / `catchmenu_payment` | `16aed7926150f2729d578194a3c4412b`; 18인자 | PUBLIC, `postgres`, `authenticated` | `catchmenu_payment.van_transactions`, `catchmenu_gateway.provider_raw_events`, `catchmenu_ledger.events` 존재; 정적 phantom 0건 | 0건 | **미검증 — 호출 금지(`601505` §4)** |
| `check_staff_permission` | 존재 / `catchmenu_store` | `297947c8bca176dab515b1f22353cb5b`; `(uuid,uuid,uuid,text,integer,text)` | PUBLIC, `postgres`, `authenticated` | `staff`, `staff_permission_matrix`, `staff_permission_logs` 존재; 정적 phantom 0건 | 0건 | **미검증 — 호출 금지(`601505` §4)** |

7함수 모두 `SECURITY DEFINER=true`다. 정적 DB 호출 edge는 6건이다. 비문서·비migration·비tools 파일의 함수명 literal 검색 결과는 0건이다.

추가 금지 함수 `provision_tenant`, `create_franchise_store`, `onboard_tenant`도 호출하지 않았다. D는 각각 **미검증 — 호출 금지**다.

### §21.1 상위 정책 8건과 측정 대상의 대응 관측

| A1 | 측정 대상에서 관측된 사실 |
|---|---|
| `010004` audit·containment | `security_audit_log`에 tenant/store/actor/resource/action/detail 필드가 있다. 원문 열거 필드 중 actor role, surface/device, previous/new scope, authority/policy/evidence reference, cross-scope attempt 이름의 컬럼은 없다. `isolation_state` 소비 함수는 0건이다. |
| `010640` scope 상태 | §6의 `SCOPE_*` 상태 문자열을 포함하는 함수 prosrc는 0건이다. 두 상태축 CHECK는 tenant 5값, isolation 2값이다. |
| `000150` | 이번 6군은 company/business-unit/legal-entity 전체 물리 모델을 측정하지 않았다. 관련 실측 공란 대신 범위 밖으로 기록한다. |
| `000170` | latest migration은 `0171_merchant_account_foundation.sql`; 이번 6군에서는 asset의 tenant/store FK와 scope만 측정했다. |
| `000190` | 비문서·비migration 앱 코드에서 금지 7함수 이름의 literal 호출자는 0건이다. cross-business 전체 객체는 이번 6군 범위 밖이다. |
| `010630` capability gate | 금지 7함수의 prosrc에서 `authority`, `capability`, `policy_version`, `evidence`, `idempotency` 문자열은 각각 0건이다. 7함수 모두 SECURITY DEFINER이며 EXECUTE ACL은 §21에 기록했다. |
| `010650` containment | 관련 자산 4테이블은 존재하고 RLS·FORCE RLS가 true다. `security_threats.tenant_id`는 nullable이며 FK가 없다. containment 동작은 호출하지 않았다. |
| `010660` idempotency scope | `idempotency_keys.tenant_id`는 NOT NULL·FK·UNIQUE 구성열이다. `store_id`는 nullable FK이나 UNIQUE 구성열이 아니며, `legal_entity_id` 컬럼은 없다. |

## §22 `601802` 대조 — 재측정

`601802`의 표 값을 현재값으로 사용하지 않았다. 동일 catalog·행 수·정적 검색을 현재 컨테이너에서 다시 실행한 뒤 old/new를 대조했다.

| # | 항목 | old — `601802` 2026-08-27 | new — 2026-09-02 | 대조 |
|---:|---|---|---|---|
| 1 | `default_transaction_read_only` | on | on | REMEASURED_MATCH |
| 2 | PostgreSQL | 17.6 | 17.6 | REMEASURED_MATCH |
| 3 | latest migration filename | `0171_merchant_account_foundation.sql` | 동일 | REMEASURED_MATCH |
| 4 | latest migration applied_at | `2026-08-24 02:25:14.371355+00` | `2026-08-30 11:46:47.552241+00` | REMEASURED_DELTA |
| 5 | `tenant_status` 타입/default/CHECK | text/`TRIAL`/5값 | 동일 | REMEASURED_MATCH |
| 6 | `isolation_state` 타입/default/CHECK | text/`NONE`/2값 | 동일 | REMEASURED_MATCH |
| 7 | 상태 함수 소비자 | `tenant_status` 7, `isolation_state` 0 | 동일 목록·수 | REMEASURED_MATCH |
| 8 | 상태 VIEW/MATVIEW/TRIGGER | 각 0 | 각 0 | REMEASURED_MATCH |
| 9 | `isolate_tenant` md5 | `f53ea7f556e89cec883b9ca6b482ca3e` | 동일 | REMEASURED_MATCH |
| 10 | `manage_subscription` md5 | `3ceb5089e1c2305628db36e485be9bcd` | 동일 | REMEASURED_MATCH |
| 11 | `detect_threat` md5 | `992c78c881be2f23bcac8050b60ad2b7` | 동일 | REMEASURED_MATCH |
| 12 | `verify_security_token` md5 | `b5c978db183d70e025ff97cc2bd1785f` | 동일 | REMEASURED_MATCH |
| 13 | `gateway_audit_entry` md5 | `bbfac99ac170a83d988c610435a00732` | 동일 | REMEASURED_MATCH |
| 14 | `record_van_transaction` md5 | `ef4d5ab3048ff13485e1cbf33579301f` | `16aed7926150f2729d578194a3c4412b` | REMEASURED_DELTA |
| 15 | `check_staff_permission` md5 | `297947c8bca176dab515b1f22353cb5b` | 동일 | REMEASURED_MATCH |
| 16 | 금지 7함수 DB 호출 edge | 6 | 6, 동일 관계 | REMEASURED_MATCH |
| 17 | 금지 7함수 EXECUTE ACL | §9.2 기록값 | 동일 | REMEASURED_MATCH |
| 18 | 자산 4테이블 컬럼·제약 | §8.1~§8.2 기록값 | 동일 | REMEASURED_MATCH |
| 19 | 자산 4테이블 행 수 | 각 0 | 각 0 | REMEASURED_MATCH |
| 20 | 자산 RLS/FORCE·policy 수 | 각 true/true·1건 | 동일 | REMEASURED_MATCH |
| 21 | `idempotency_keys` UNIQUE | `(tenant_id,key_domain,idempotency_key)` | 동일 | REMEASURED_MATCH |
| 22 | `offline_queue` 참조 함수 목록 | §8.3에 6개 이름 열거 | 동일 6개 | REMEASURED_MATCH |
| 23 | 컨테이너 ID | `fb5b03ea...1499857` | `b67400e8...bd935ec` | REMEASURED_DELTA |
| 24 | 이미지 | `17.6.1.140` | `17.6.1.156` | REMEASURED_DELTA |
| 25 | `security_audit_log` prosrc 참조 함수 수 | 13 | 12 | REMEASURED_DELTA |

집계: REMEASURED_MATCH 20건, REMEASURED_DELTA 5건.

DELTA에서 관측된 변경 원인 자료는 다음과 같다.

| DELTA | 관측된 자료 |
|---|---|
| migration applied_at | 컨테이너 ID와 이미지 태그가 다르고, 같은 `0171` 행의 applied_at이 다름 |
| `record_van_transaction` md5 | 현재 prosrc md5가 다름. `0170`은 person vocabulary 변경, `0171`은 merchant account foundation이며 두 migration 파일에서 이 함수 정의문은 검색 0건 |
| 컨테이너 ID·이미지 | 두 측정 기록 자체가 서로 다른 ID와 이미지 태그를 반환함 |
| `security_audit_log` 참조 함수 수 | 현재 prosrc 전수 검색은 12개 함수를 반환함; `601802`는 13건으로 기록함 |

그 밖의 변경 원인은 이 Pass에서 확인되지 않았다.

## §23 실행 쿼리 전문

모든 DB 쿼리는 `PGOPTIONS="-c default_transaction_read_only=on"`과 `psql -v ON_ERROR_STOP=1`로 실행했다. 금지 함수 호출문은 실행하지 않았다.

```sql
SHOW default_transaction_read_only;
SELECT current_timestamp;
SELECT version();

SELECT count(*) FILTER (WHERE success) AS success_count,
       (SELECT row_to_json(m) FROM catchmenu_meta.migration_history m
        ORDER BY applied_at DESC LIMIT 1) AS latest,
       json_agg(row_to_json(h) ORDER BY applied_at)
         FILTER (WHERE NOT success) AS failed
FROM catchmenu_meta.migration_history h;

SELECT schemaname, count(*) AS table_count
FROM pg_tables
WHERE schemaname LIKE 'catchmenu%'
GROUP BY schemaname
ORDER BY schemaname;

SELECT ordinal_position, column_name, data_type, udt_schema, udt_name,
       is_nullable, column_default
FROM information_schema.columns
WHERE table_schema='catchmenu_hq' AND table_name='tenants'
  AND column_name IN ('tenant_status','isolation_state')
ORDER BY ordinal_position;

SELECT conname, contype, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid='catchmenu_hq.tenants'::regclass
  AND (pg_get_constraintdef(oid) ILIKE '%tenant_status%'
       OR pg_get_constraintdef(oid) ILIKE '%isolation_state%');

SELECT n.nspname, p.proname, p.oid::regprocedure,
       pg_get_function_identity_arguments(p.oid),
       pg_get_function_result(p.oid), md5(p.prosrc), length(p.prosrc),
       p.prosecdef, p.proconfig, p.proacl
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname IN (
  'isolate_tenant','manage_subscription','detect_threat',
  'verify_security_token','gateway_audit_entry',
  'record_van_transaction','check_staff_permission'
)
ORDER BY p.proname;

SELECT n.nspname||'.'||p.proname,
       p.prosrc ILIKE '%authority%' AS authority_ref,
       p.prosrc ILIKE '%capability%' AS capability_ref,
       p.prosrc ILIKE '%policy_version%' AS policy_version_ref,
       p.prosrc ILIKE '%evidence%' AS evidence_ref,
       p.prosrc ILIKE '%idempotency%' AS idempotency_ref
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname IN (
  'isolate_tenant','manage_subscription','detect_threat',
  'verify_security_token','gateway_audit_entry',
  'record_van_transaction','check_staff_permission'
)
ORDER BY 1;

SELECT count(*)
FROM pg_proc
WHERE prosrc ~ 'SCOPE_(NOT_EVALUATED|VALIDATING|VALID|PARTIAL_VALID|MISSING|MISMATCH|CROSS_TENANT_DENIED|STORE_MISMATCH|LEGAL_ENTITY_MISMATCH|PROVIDER_MISMATCH|DEVICE_MISMATCH|VISIBILITY_DENIED|AUTHORITY_DENIED|REVIEW_REQUIRED|QUARANTINED|DLQ_REQUIRED)';

SELECT n.nspname, p.proname, p.oid::regprocedure,
       p.prosrc ILIKE '%tenant_status%' AS tenant_status,
       p.prosrc ILIKE '%isolation_state%' AS isolation_state
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ILIKE '%tenant_status%'
   OR p.prosrc ILIKE '%isolation_state%';

SELECT schemaname, viewname
FROM pg_views
WHERE definition ILIKE '%tenant_status%'
   OR definition ILIKE '%isolation_state%';

SELECT schemaname, matviewname
FROM pg_matviews
WHERE definition ILIKE '%tenant_status%'
   OR definition ILIKE '%isolation_state%';

SELECT n.nspname, c.relname, t.tgname, pg_get_triggerdef(t.oid)
FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND pg_get_triggerdef(t.oid) ~* '(tenant_status|isolation_state)';

WITH target AS (
  SELECT p.oid,p.prosrc,n.nspname,p.proname
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE p.proname IN (
    'isolate_tenant','manage_subscription','detect_threat',
    'verify_security_token','gateway_audit_entry',
    'record_van_transaction','check_staff_permission'
  )
)
SELECT t.proname AS target, n.nspname AS caller_schema,
       p.proname AS caller, p.oid::regprocedure AS caller_signature
FROM target t
JOIN pg_proc p ON p.oid<>t.oid
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.prosrc ILIKE '%'||t.proname||'%'
ORDER BY target,caller_schema,caller;

SELECT c.table_schema,c.table_name,c.ordinal_position,c.column_name,
       c.data_type,c.udt_name,c.is_nullable,c.column_default
FROM information_schema.columns c
WHERE (c.table_schema,c.table_name) IN (
 ('catchmenu_common','offline_queue'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys')
)
ORDER BY c.table_schema,c.table_name,c.ordinal_position;

SELECT n.nspname,c.relname,k.conname,k.contype,pg_get_constraintdef(k.oid)
FROM pg_constraint k
JOIN pg_class c ON c.oid=k.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE (n.nspname,c.relname) IN (
 ('catchmenu_common','offline_queue'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys')
)
ORDER BY n.nspname,c.relname,k.conname;

SELECT n.nspname,c.relname,c.relrowsecurity,c.relforcerowsecurity,
       (SELECT count(*) FROM pg_policy p WHERE p.polrelid=c.oid) AS policy_count
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE (n.nspname,c.relname) IN (
 ('catchmenu_common','offline_queue'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys')
);

SELECT schemaname,tablename,policyname,roles,cmd,qual,with_check
FROM pg_policies
WHERE (schemaname,tablename) IN (
 ('catchmenu_common','offline_queue'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys')
)
ORDER BY schemaname,tablename,policyname;

SELECT table_schema,table_name,grantee,privilege_type,is_grantable
FROM information_schema.role_table_grants
WHERE (table_schema,table_name) IN (
 ('catchmenu_common','offline_queue'),
 ('catchmenu_common','security_threats'),
 ('catchmenu_common','security_audit_log'),
 ('catchmenu_common','idempotency_keys')
)
ORDER BY table_schema,table_name,grantee,privilege_type;

SELECT
 (SELECT count(*) FROM catchmenu_common.offline_queue) AS offline_queue,
 (SELECT count(*) FROM catchmenu_common.security_threats) AS security_threats,
 (SELECT count(*) FROM catchmenu_common.security_audit_log) AS security_audit_log,
 (SELECT count(*) FROM catchmenu_common.idempotency_keys) AS idempotency_keys;

WITH tabs(t) AS (VALUES
 ('offline_queue'),('security_threats'),
 ('security_audit_log'),('idempotency_keys')
)
SELECT tabs.t,n.nspname,p.proname,p.oid::regprocedure
FROM tabs
JOIN pg_proc p ON p.prosrc ILIKE '%'||tabs.t||'%'
JOIN pg_namespace n ON n.oid=p.pronamespace
ORDER BY tabs.t,n.nspname,p.proname;
```

비문서 앱 코드 호출자 검색:

```text
rg -n -g '!docs/**' -g '!sql/migrations/**' -g '!tools/**' -g '!*.md' "isolate_tenant|manage_subscription|detect_threat|verify_security_token|gateway_audit_entry|record_van_transaction|check_staff_permission" .
결과: 0건
```

## §24 근거 문서 목록 갱신 (`000701` §46)

| 근거 | 사용 |
|---|---|
| `601901` §5~§9.3 | A1 8건 원천 정책 기록 |
| `601901` §10~§15 | A2·A3·A4 및 provenance 기록 |
| `601802_Register_Stage0_Evidence_Collection.md` | 2026-08-27 old 값 대조 기준; 현재값으로 복사하지 않음 |
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` §4 | 함수 호출 금지 근거 |
| `sql/migrations/0170_person_vocabulary_normalization.sql` | DELTA 원인 검색 대상 |
| `sql/migrations/0171_merchant_account_foundation.sql` | 최신 migration 및 DELTA 원인 검색 대상 |
| live PostgreSQL catalog·row count | §16~§23 current 실측 |
