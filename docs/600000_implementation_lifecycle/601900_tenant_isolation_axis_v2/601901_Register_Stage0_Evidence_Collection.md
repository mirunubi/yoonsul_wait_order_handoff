# 601901_Register_Stage0_Evidence_Collection.md

Status: Draft
Lifecycle: Register
Last Updated: 2026-09-02

## §0 용도 · baseline

| 항목 | 기록 |
|---|---|
| 용도 | `000701` §48 증거수집 |
| baseline commit | `e6573af57432ad7d496ae0a9ad5739047ecf0eec` |
| Pass | Pass 1 — Source Provenance Evidence |
| 다음 Pass | Pass 2 — Runtime Remeasurement |
| DB 접속 | 수행하지 않음 |
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

| # | 정확한 경로 | 현재 지위 | 전체 절 구조 | 관련 절 | suspended block |
|---:|---|---|---|---|---|
| 1 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | 혼재 | Purpose; §2~§29 | §2~§7, §19~§21, §24~§25, §27, §29 | §4.1 내부 1개 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | ACTIVE | Purpose; §2~§42 | §2~§9, §15, §29~§38, §40~§42 | 없음 |
| 3 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | 혼재 | Purpose; 후대 개정 블록; 원 정책 §1~§33 | 원 정책 §3~§8, §12~§17, §20~§27, §31~§33 | L10의 후대 블록 내부 1개 |
| 4 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | 혼재 | Purpose; 원 정책 §1~§13; 후대 개정 블록; 원 정책 §14~§39 | 원 정책 §3~§16, §25~§33, §39 | L385의 후대 블록 내부 1개 |
| 5 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | ACTIVE | Purpose; 원 정책 §1~§37 | §3~§17, §20~§31, §37 | 없음 |

### §3.2 A2 Upstream Human Declaration

| # | 정확한 경로 | 현재 지위 | 전체 절 구조 | 관련 절 | suspended block |
|---:|---|---|---|---|---|
| 1 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | ACTIVE | §0; §1.1~§1.45; §2.1~§2.4; §3~§5 | §1 전건, 특히 §1.22·§1.26·§1.27·§1.28·§1.40·§1.43 | 문서 자체 block 없음; §3이 `601500` suspended 상태를 기록 |

### §3.3 A3 Discovery Inventory

`010640` §41이 직접 선행·후속·참조 관계로 열거한 문서만 기록한다.

| # | 정확한 경로 | 현재 지위 | 발견 위치 | authority 처리 |
|---:|---|---|---|---|
| 1 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010610_Policy_Cross_Room_Event_Bus_And_Evidence_Packet_Routing.md` | ACTIVE | `010640` §41 references | A1 승격 안 함 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010620_Policy_Command_Query_Projection_Separation.md` | ACTIVE | `010640` §41 references | A1 승격 안 함 |
| 3 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010630_Policy_Authority_Capability_Gate.md` | ACTIVE | `010640` §41 follows/references | A1 승격 안 함 |
| 4 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010650_Policy_Failure_Containment_Circuit_Breaker.md` | ACTIVE | `010640` §41 prepares | A1 승격 안 함 |
| 5 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | ACTIVE | `010640` §41 prepares | A1 승격 안 함 |
| 6 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010670_Policy_Safe_Projection_I18n_Routing.md` | ACTIVE | `010640` §41 prepares | A1 승격 안 함 |
| 7 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010680_Audit_Correlation_Nightly_Batch.md` | ACTIVE | `010640` §41 prepares | A1 승격 안 함 |
| 8 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010690_Policy_Cross_Room_Plumbing_Closure.md` | ACTIVE | `010640` §41 prepares | A1 승격 안 함 |

### §3.4 A4 Suspended Evidence

| 대역 | 문서 수 | 현재 지위 | 확인 근거 | 사용 범위 |
|---|---:|---|---|---|
| `601500` | 13 | SUSPENDED | `600020` §1.1; 대역 Readme·Baseline Summary의 suspended 표시 | 사실·raw evidence만 |
| `601600` | 2 | 혼재 | 파일 자체는 Active이나 `601500` 결과를 상위 문서에 역전파한 대역; 삽입 결과는 source 문서 안에서 suspended wrapper로 구분됨 | 후대 삽입 위치 식별만 |
| `601800` | 17 | SUSPENDED | `601800` Readme 상단; `600021` §1·§2 | finding 목록만; 설계 판정 승계 안 함 |

## §4 대상별 A~E 요약표

| 대상 | A 문서 | B SQL 객체 | C 문서↔SQL | D 로컬 실행 | E 호출자·권한 | 현재 기록 |
|---|---|---|---|---|---|---|
| Tenant isolation doctrine | `010004` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Tenant scope envelope | `010640` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Company/business unit/legal entity | `000150` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Merchant account/company/store | `000170` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Cross-business boundary | `000190` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Upstream Human declarations | `601702` 45건 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | A만 기록 |
| Suspended prior evidence | `601500`·`601600`·`601800` 존재 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | Pass 2 대기 | authority와 evidence 분리 |

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
| `010610` | Purpose; §2~§42 | §6 Mandatory Event Envelope; §15 DLQ; §16 Quarantine; §22 Tenant Scope; §29 Audit; §31 Security | 없음 | `601900` 지정 A1 아님 |
| `010620` | Purpose; §2~§43 | §4 Command; §5 Fields; §14 Audit; §16 DLQ; §32~§34 gates; §37 Evidence-First | 없음 | `601900` 지정 A1 아님 |
| `010630` | Purpose; §2~§44 | §5 Authority Context; §6 Decision State; §9 Scope Gate; §13 Evidence; §21 Idempotency; §22 Audit; §24 Circuit Breaker; §28 Deny | 없음 | `601900` 지정 A1 아님 |
| `010650` | Purpose; §2~§42 | §3 Containment; §5~§7 Circuit Breaker; §16 Security Quarantine; §17 Tenant; §18 Store; §29 Recovery; §30 Reclose; §32 Evidence | 없음 | `601900` 지정 A1 아님 |
| `010660` | Purpose; §2~§44 | §3~§17 idempotency/retry/replay/reconciliation; §29 Evidence; §36 Storm; §37 Tenant Scope | 없음 | `601900` 지정 A1 아님 |
| `010670` | Purpose; §2~§46 | §3 Projection; §12 Masking; §16 Franchise HQ; §17 Support; §31 Freshness; §40 Tenant Scope | 없음 | `601900` 지정 A1 아님 |
| `010680` | Purpose; §2~§45 | §5 Correlation Key; §6 Audit Fields; §17 Security; §27 Gap; §28 Cross-Tenant Audit; §29 Evidence | 없음 | `601900` 지정 A1 아님 |
| `010690` | Purpose; §2~§28 | §10 Authority Gate; §11 Tenant Scope; §14 Containment; §15 Idempotency; §17 Audit; §18 Gate Order | 없음 | `601900` 지정 A1 아님 |

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
