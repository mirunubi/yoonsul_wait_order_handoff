# 000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


Legacy path: $old.

### ⚠️ 2026-08-11 개정 — 이 문서의 개념이 실제로 어떻게 실현됐는가

본 문서가 다루는 **company / business_unit / legal_entity** 개념은,
0-A 워크패킷(`601500`, 마이그레이션 `0168`/`0169`, 2026-08-11 완료)에서 다음과 같이 실현됐다.

| 본 문서의 개념 | 실제 구현 | 비고 |
|---|---|---|
| **legal entity**(계약·세무·정산 주체) | **`catchmenu_hq.legal_entities`** (신규) | 사업자등록번호를 보유하는 **유일한** 테이블 |
| **company**(브랜드·운영 그룹핑) | 기존 `catchmenu_hq.franchise_brands` | **신규 테이블을 만들지 않았다** |
| business unit / operating group | 기존 `catchmenu_hq.store_groups` (`group_type='REGION'`만 사용) | |
| (신규) 자연인 | `catchmenu_hq.owners` | 본 문서에 대응 개념 없음 |
| (신규) 대표권 | `catchmenu_hq.legal_entity_representatives` | 동상 |
| (신규) 조직 역할 | `catchmenu_hq.legal_entity_person_roles` | 동상 |

> **⚠️ 어휘 함정**: `legal_entities.entity_type = 'CORPORATION'`은 **법인격의 종류(legal form)** 를 뜻하며,
> 본 문서·`003020`이 말하는 **"company 축(브랜드 그룹핑)"과 전혀 다른 개념**이다.
> "법인 = Company"로 읽으면 두 축이 뒤섞인다.

#### 사업자 축 vs 브랜드 축 (`601501` §0.4에서 이전)

| **사업자 축 — `legal_entities`** | **브랜드 축 — `franchise_brands`** |
|---|---|
| 법인격 종류 (`entity_type`) | 상표·브랜드명 (`brand_name`/`brand_code`) |
| 사업자등록번호 (`business_registration_number`) | 로열티 정책 (`royalty_rate_pct`) |
| 법인등기번호 (`corporate_registration_number`) | 브랜드 가이드 (`brand_guidelines_url` 등) |
| 대표권 (`legal_entity_representatives`) | 멤버십·메뉴 공유 (`shared_membership` 등) |
| **누가 법적 책임을 지는가** | **어떤 간판을 달고 무엇을 공유하는가** |

#### 사업자등록번호의 경계 (`601501` §2.1.1)

**사업자등록번호는 등록의 식별자이지 법적 정체성의 근본 존재론이 아니다.**
한 법인이 복수 사업장·등록단위를 가질 수 있고, 개인사업자는 사업체와 자연인이 완전히 분리되지 않는다.
현재 구현은 **1:1 MVP 단순화**이며, **동일성 판단 기준은 `business_registration_number`가 아니라
`legal_entities.id`** 다.

#### 아직 모델링되지 않은 것 — 소유권(지분)

**소유권 · 대표권 · 조직역할 · 사업자등록 식별자는 서로 독립된 4개 개념**이다(`601501` §0.6).
대표이사가 지분 0%일 수 있고, 60% 주주가 대표가 아닐 수도 있다.

이 중 **소유권(지분)만 아직 모델링되지 않았다.** 필요해지면 별도 테이블이 필요하다(Open Item).

> **`legal_entity_person_roles.ownership_percent` 컬럼을 소유권 모델로 사용하지 말 것** —
> 역할 테이블에 소유권 컬럼이 얹힌 개념 혼재이며, 현재 **사용 금지** 상태다(`601501` §2.3.1).

근거: `601501_ERD_Tenant_Company_HQ_Store.md` §0.4/§0.6/§2.1.1/§2.3.1, `sql/migrations/0168`.

---

1\. Purpose

This document defines how CatchMenu / Wait Order Handoff models company, business unit, and legal entity boundaries.

CatchMenu may operate as a separate SaaS company, business unit, or operating division within a broader Yoonsul group.

Because CatchMenu can serve external restaurants, trial merchants, production SaaS merchants, and Yoonsul-affiliated stores, its company and business boundary must be explicit.

Core purpose:

Define CatchMenu operating company context.
Separate business unit responsibility from legal entity identity.
Support external SaaS merchant operation.
Prevent Franchise OS authority from leaking into CatchMenu.
Prepare billing, contract, service status, HQ, and merchant governance.

Korean purpose:

CatchMenu 운영 회사 컨텍스트를 정의한다.
사업부 책임과 법인 정체성을 분리한다.
외부 음식점 SaaS 고객 운영을 지원한다.
Franchise OS 권한이 CatchMenu로 자동 유입되지 않게 한다.
요금제, 계약, 서비스 상태, HQ, 고객사 거버넌스를 준비한다.

2\. Scope

This document covers:

CatchMenu operating company
business unit
operating division
legal entity
parent group reference
company status
service business boundary
contract responsibility
billing responsibility
cross-business separation
SaaS merchant responsibility

This document does not define:

individual user login
role permission matrix
support masking
merchant owner console screen
field installation SOP
Entry Media asset lifecycle
Stage 0 request runtime
Franchise OS HR/payroll

Related folders:

docs/00400\_identity\_access/
docs/00500\_organization\_core/
docs/02400\_owner\_console/
docs/02600\_merchant\_ops/
docs/03000\_catchmenu\_hq/
docs/00300\_entry\_media\_inventory/

3\. Core Principle

CatchMenu must be modeled as its own operating business.

Core rule:

CatchMenu belongs to a business boundary.
Franchise OS belongs to another business boundary.
Shared group ownership does not merge operating authority.

Korean rule:

CatchMenu는 별도 사업 경계에 속한다.
Franchise OS는 다른 사업 경계에 속한다.
같은 그룹 소유라고 해서 운영 권한이 합쳐지지 않는다.

4\. Company Boundary

Company boundary defines who operates CatchMenu as a platform.

A company record may represent:

CatchMenu SaaS company
CatchMenu operating division
CatchMenu business unit
Yoonsul group-owned SaaS subsidiary
internal product company before legal separation

Recommended conceptual fields:

company\_id
company\_name
company\_type
parent\_group\_id
operating\_status
primary\_business\_type
legal\_entity\_id
created\_at
updated\_at

Suggested company types:

SAAS\_COMPANY
BUSINESS\_UNIT
OPERATING\_DIVISION
SUBSIDIARY
INTERNAL\_PRODUCT\_UNIT

5\. Parent Group Context

Parent group context may represent the broader Yoonsul group.

Example:

Yoonsul Group
  ├─ Franchise OS Business
  └─ CatchMenu SaaS Business

Parent group may provide:

ownership reference
strategic reporting
brand governance
future federation boundary
shared governance philosophy

Parent group must not provide automatic system authority.

Core rule:

Parent group is an ownership or strategy context.
It is not automatic access authority.

6\. Business Unit Boundary

Business unit defines operating responsibility inside CatchMenu.

Examples:

Platform Operations
Merchant Operations
Support Operations
Field Operations
Inventory Operations
AI Menu Review
Sales Operations
Finance/Billing Operations
Product/Engineering Operations

Business unit may be used for:

operator assignment
internal responsibility
escalation path
service workflow routing
support ownership
trial merchant follow-up
Entry Media recovery coordination

Core rule:

Business unit defines operational responsibility.
It does not automatically grant permissions.

7\. Legal Entity Boundary

Legal entity defines legal, contract, billing, tax, and liability identity.

Legal entity may be used for:

merchant service agreement
tax invoice
billing
data processing agreement
liability boundary
refund or compensation policy
contract notice

Legal entity should be distinct from company and business unit.

Example:

company \= CatchMenu SaaS Business
business\_unit \= Merchant Operations
legal\_entity \= Yoonsul Platform Co., Ltd.

Core rule:

Legal entity is contract identity.
Business unit is operational responsibility.
Company is operating business context.

8\. Why These Must Be Separate

Do not collapse company, business unit, and legal entity.

Reason:

One legal entity may operate multiple business units.
One company may contain several operating teams.
One business unit may support merchants contracted under one legal entity.
A future spin-off may create a separate legal entity without changing merchant runtime design.
A Yoonsul-affiliated store may use CatchMenu without becoming a Franchise OS merchant.

Core rule:

Separate axes now to avoid painful retrofit later.

9\. CatchMenu Operating Status

CatchMenu company/business status should be explicit.

Suggested statuses:

PLANNED
INTERNAL\_BUILD
PRIVATE\_PILOT
TRIAL\_OPERATION
COMMERCIAL\_OPERATION
SUSPENDED
RESTRUCTURING
CLOSED

Meaning:

PLANNED
\= business exists as design or plan

INTERNAL\_BUILD
\= platform is being built internally

PRIVATE\_PILOT
\= limited internal or friendly merchant pilot

TRIAL\_OPERATION
\= merchant trial operation active

COMMERCIAL\_OPERATION
\= paid SaaS operation active

SUSPENDED
\= operation temporarily paused

RESTRUCTURING
\= company/business boundary is being changed

CLOSED
\= business operation closed

10\. CatchMenu Service Business Boundary

CatchMenu business boundary includes:

QR/NFC Entry Media SaaS
multilingual menu viewing
show-to-staff flow
send-to-store request
POS-less request confirmation board
waiting/order handoff runtime
merchant owner console
trial merchant operations
Entry Plate inventory
support signal and evidence packet
AI menu intake support
future POS/KDS adapter
future SaaS franchise benefits

CatchMenu business boundary does not include by default:

Franchise OS payroll
Franchise OS attendance
Franchise OS employee contracts
Franchise OS store HR
Yoonsul internal franchise settlement
food production SOP ownership
Franchise OS staff training lifecycle

11\. Franchise OS Boundary

Franchise OS business boundary includes:

Yoonsul food-store operations
franchise operation
store HR
attendance
payroll
shift scheduling
store SOP
training
franchise HQ governance
store-level finance
inventory and SCM for Yoonsul food business

Franchise OS may become a CatchMenu customer or integrated partner, but it is not automatically the same business authority.

Core rule:

Franchise OS may use CatchMenu.
Franchise OS does not own CatchMenu by default.

12\. Shared Yoonsul-Affiliated Store Case

A Yoonsul-owned store may use CatchMenu.

In that case, the store may exist in both systems:

Franchise OS store
\= operational food-store context

CatchMenu merchant store
\= SaaS service context

The relationship must be explicit.

Possible link:

franchise\_store\_id
catchmenu\_store\_id
relationship\_type \= AFFILIATED\_STORE

Core rule:

Same physical store may have different system identities in different business contexts.

13\. External Merchant Case

An external restaurant using CatchMenu must not become a Franchise OS entity.

External merchant belongs to CatchMenu merchant account context only.

Example:

external restaurant
→ CatchMenu merchant\_account
→ merchant\_store
→ service plan
→ Entry Media assignment

It must not automatically create:

Franchise OS store
Franchise OS employee
Franchise OS payroll profile
Franchise OS franchise contract

Core rule:

External SaaS merchant is not a Yoonsul franchisee by default.

14\. Trial Merchant Case

A trial merchant may have limited organization records.

Minimum:

merchant\_account
merchant\_store
trial\_status
service\_status
primary contact
assigned operator
Entry Media assignment

Trial merchant may not yet have full contract or billing records.

However, trial status must be traceable.

Core rule:

Trial is lighter than paid operation.
Trial is still an organization context.

15\. Production Merchant Case

Production merchant requires stronger organization records.

Minimum:

merchant\_account
merchant\_company if applicable
merchant\_store
service\_plan
service\_status
owner user
billing/legal reference if applicable
support owner
audit history

Production merchant should have clear legal/billing identity if paid service is active.

16\. Company Authority Boundary

CatchMenu company authority includes:

creating merchant accounts
approving trial merchants
activating service status
suspending service
deactivating Entry Media mapping
granting CatchMenu owner console access
assigning CatchMenu operators
viewing CatchMenu support evidence
reviewing AI menu intake

CatchMenu company authority does not include:

Franchise OS payroll approval
Franchise OS employee discipline
Franchise OS HR document approval
Franchise OS store settlement approval

unless explicit federation is designed.

17\. Legal Authority Boundary

Legal authority should be explicit for:

service contract
trial terms
paid subscription
tax invoice
refund or compensation policy
data retention notice
personal data processing
merchant termination notice

Legal entity should be referenced where those actions occur.

Core rule:

Legal authority must not be guessed from operational team membership.

18\. Business Unit Responsibility

Business unit responsibility should be explicit.

Examples:

Merchant Ops
\= trial onboarding, usage follow-up, conversion support

Field Ops
\= installation, recovery, physical merchant visit

Inventory Ops
\= Entry Plate stock, recovery status, reallocation readiness

Support
\= merchant issue response, support signal review

AI Menu Review
\= menu photo analysis review, draft approval support

Finance/Billing Ops
\= plan, invoice, payment status support

Business unit responsibility does not automatically grant data access.

Access must be governed through Identity Access.

19\. Internal Team Assignment

Internal team assignment may include:

team\_id
business\_unit\_id
team\_name
team\_type
manager\_operator\_id
status

Team types may include:

HQ\_ADMIN
SUPPORT
FIELD\_OPS
MERCHANT\_OPS
INVENTORY\_OPS
AI\_REVIEW
SALES
FINANCE
ENGINEERING

Team membership should not be the only authorization check.

20\. Operator Belongs To Company Context

CatchMenu operators should belong to CatchMenu company context or explicitly federated context.

Operator record may include:

operator\_id
user\_id
company\_id
business\_unit\_id
team\_id
operator\_status
primary\_role

If the same person also works in Franchise OS, the identity link may exist, but permissions remain separated.

Core rule:

Same human may have multiple system roles.
Authority must be scoped per business.

21\. Company-Level Audit

Company-level actions must be audit logged.

Examples:

CatchMenu company status changed
business unit created
legal entity linked
merchant account approved
service status changed
operator assigned to team
cross-business link created

Audit fields:

event\_id
company\_id
business\_unit\_id
legal\_entity\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

22\. Cross-Business Link

If CatchMenu and Franchise OS share a store, user, or reporting context, the link must be explicit.

Suggested link types:

AFFILIATED\_STORE
GROUP\_REPORTING
SHARED\_IDENTITY
SHARED\_BRAND
INTEGRATED\_RUNTIME
BILLING\_REFERENCE
SUPPORT\_REFERENCE

Cross-business link must not imply full authority.

Core rule:

A link is not authority.
Authority requires role and scope.

23\. Cross-Business Access Denial By Default

Default:

Franchise OS admin
→ no CatchMenu admin authority by default

CatchMenu admin
→ no Franchise OS admin authority by default

Franchise OS store owner
→ no external CatchMenu merchant visibility

CatchMenu merchant owner
→ no Franchise OS store operation visibility

Access must be granted explicitly.

24\. Future Federation

Future federation may allow:

shared login
shared group-level reporting
cross-system store reference
Yoonsul-owned store menu sync
shared audit summary
shared support escalation

Federation requires separate policy.

Until federation is defined:

separate company context
separate roles
separate scopes
separate audit
separate support access

25\. MVP Requirements

MVP must support at least:

CatchMenu company record
CatchMenu business unit list
legal entity reference optional
merchant account context
merchant store context
operator company context
business unit responsibility
service status
trial status
cross-business boundary note

MVP may defer:

complex legal entity tree
multi-country legal setup
full group federation
advanced company hierarchy
intercompany billing
enterprise org chart

26\. Suggested Conceptual Entities

MVP conceptual entities:

companies
business\_units
legal\_entities
internal\_teams
operators
merchant\_accounts
merchant\_companies
merchant\_stores
service\_status\_events
cross\_business\_links

This document defines policy.

Actual schema may be designed later.

27\. Relationship To Identity Access

Organization Core defines structure.

Identity Access defines authority.

Example:

operator belongs to CatchMenu Support team

does not automatically mean:

operator can deactivate Entry Media

Permission must be granted through Identity Access.

Core rule:

Organization membership is context.
Permission is authority.

28\. Relationship To CatchMenu HQ

CatchMenu HQ is the administrative interface for this company model.

CatchMenu HQ may manage:

company settings
business unit list
legal entity reference
merchant accounts
merchant stores
operator assignments
service status
cross-business links

HQ must respect Identity Access.

29\. Relationship To Merchant Ops

Merchant Ops uses company and business unit context to operate:

trial onboarding
merchant follow-up
Entry Plate recovery
conversion support
service termination
support escalation

Merchant Ops does not own company/legal definitions.

30\. Relationship To Owner Console

Owner Console exposes only the merchant-side portion of the organization model.

Owner Console may show:

merchant account
store name
service status
trial status
owner user
store users

Owner Console should not expose internal business unit or legal structure unless necessary.

31\. Relationship To Entry Media Inventory

Entry Media Inventory requires store and service context.

It may reference:

merchant\_account\_id
merchant\_store\_id
service\_status
company\_id

but it does not own merchant organization.

Core rule:

Organization Core owns company and store context.
Entry Media Inventory owns QR/NFC asset lifecycle.

32\. Risk If Skipped

If company/business/legal boundaries are skipped, risks include:

Franchise OS admin accidentally controls CatchMenu SaaS merchants
external merchants become mixed with Yoonsul franchise stores
billing and contract responsibility becomes unclear
support access becomes too broad
Entry Media recovery responsibility is unclear
AI menu review responsibility is unclear
future spin-off becomes hard
cross-business audit becomes unreliable

Therefore, this document is foundational.

33\. Final Rule

CatchMenu must have its own explicit company, business unit, and legal entity boundary.

Final rule:

Define the operating company.
Separate business unit from legal entity.
Separate CatchMenu from Franchise OS.
Allow explicit links.
Deny implicit authority.
Support external SaaS merchants.
Preserve audit.
Prepare HQ and Identity Access on top of this structure.
