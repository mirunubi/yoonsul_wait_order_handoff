# 00140_Readme_Organization_Core

Legacy path: $old.

1\. Purpose

This folder defines the Organization Core for CatchMenu / Wait Order Handoff.

CatchMenu is not merely a feature inside Franchise OS.

CatchMenu may operate as a separate SaaS company, business unit, or operating division within the broader Yoonsul group.

Therefore, CatchMenu needs its own organization model, company boundary, internal team structure, merchant account context, operator responsibility, and cross-business boundary policy.

Core purpose:

Define CatchMenu as a separate operating business.
Separate CatchMenu organization from Franchise OS organization.
Support SaaS merchant operation.
Define company, business unit, team, operator, merchant, and store context.
Prepare Identity Access and CatchMenu HQ governance.

Korean purpose:

CatchMenu를 별도 운영 사업으로 정의한다.
CatchMenu 조직과 Franchise OS 조직을 분리한다.
SaaS 고객사 운영을 지원한다.
회사, 사업부, 팀, 운영자, 고객사, 매장 컨텍스트를 정의한다.
Identity Access와 CatchMenu HQ 거버넌스의 기반을 마련한다.

2\. Scope

This folder covers:

CatchMenu company boundary
CatchMenu business unit boundary
legal entity reference
internal team structure
operator responsibility
merchant account context
merchant company/store relationship
cross-business boundary with Franchise OS
HQ responsibility
support responsibility
field operations responsibility
inventory operations responsibility
AI menu review responsibility

This folder does not define:

full HR attendance
payroll
employee contracts
shift scheduling
labor management
Franchise OS store HR
POS/KDS/payment integration
guest request runtime
Entry Media physical inventory lifecycle

Those belong to other systems or folders.

3\. Core Principle

CatchMenu must have its own organization core.

Core rule:

CatchMenu may share group philosophy with Franchise OS.
CatchMenu must not inherit Franchise OS authority by default.

Korean rule:

CatchMenu는 Franchise OS와 그룹 철학을 공유할 수 있다.
하지만 Franchise OS 권한을 기본으로 상속하지 않는다.

Shared ownership does not mean shared operational authority.

4\. CatchMenu As Separate Business

CatchMenu / Wait Order Handoff may be operated as:

separate SaaS company
separate business unit
separate operating division
subsidiary-like internal business
future external SaaS product line

It may serve:

Yoonsul-owned stores
Yoonsul franchise stores
external independent restaurants
trial merchants
production SaaS merchants
partner merchants

Because it can serve external merchants, it must not be treated as only an internal franchise tool.

5\. Relationship To Franchise OS

Franchise OS and CatchMenu may belong to the same broader Yoonsul group.

However, they are different operating businesses.

Franchise OS
\= food-store and franchise operation platform

CatchMenu
\= SaaS merchant-facing QR/NFC menu, request, and handoff platform

Core separation:

Franchise OS manages Yoonsul food-store operations.
CatchMenu manages SaaS merchant runtime and platform operations.

6\. Shared Philosophy, Separated Authority

CatchMenu may reuse Franchise OS philosophy such as:

role-based access
least privilege
audit log
support access masking
backup authority
sensitive action reauthentication
event-backed state changes
evidence-first operation

CatchMenu should not copy all Franchise OS HR functions.

Do not import by default:

attendance
payroll
shift scheduling
employee contracts
employee document management
labor settlement
store staff HR lifecycle

Core rule:

Reuse governance patterns.
Do not import unrelated HR weight.

7\. Organization Axes

CatchMenu Organization Core should distinguish these axes:

group
company
business\_unit
legal\_entity
internal\_team
operator
merchant\_account
merchant\_company
merchant\_store
service\_plan
service\_status

These axes must not be collapsed into one concept.

Reason:

One group may own multiple businesses.
One business may serve many merchants.
One merchant may have multiple stores.
One internal operator may support many merchants.
One legal entity may bill or contract differently from operating team.

8\. Group Context

Group context represents the broader Yoonsul umbrella if needed.

Example:

Yoonsul Group
  ├─ Franchise OS Business
  └─ CatchMenu SaaS Business

Group context may provide:

shared ownership reference
shared brand governance
shared strategic reporting
future federation

Group context must not automatically merge operational authority.

9\. Company Context

Company context represents the operating company or business entity responsible for CatchMenu.

It may include:

company\_id
company\_name
company\_type
operating\_status
parent\_group\_id
legal\_entity\_id
created\_at

Company context answers:

Who operates CatchMenu?
Which business owns this SaaS platform?
Which legal or operating unit is responsible?

10\. Business Unit Context

Business Unit context represents a functional or strategic unit inside CatchMenu.

Examples:

Platform Operations
Merchant Operations
Support
Field Operations
Entry Media Inventory
AI Menu Review
Sales
Finance/Billing
Product/Engineering

Business unit helps assign operational responsibility.

Core rule:

Business unit is an operating responsibility axis.
It is not the same as legal entity.

11\. Legal Entity Context

Legal Entity context represents the legal or contract subject if needed.

Legal entity may be used for:

merchant contract
billing
tax invoice
liability boundary
service agreement
data processing agreement

Legal entity should be distinct from business unit.

Core rule:

Legal entity handles legal/contract identity.
Business unit handles operating responsibility.

12\. Internal Team Context

Internal teams operate the CatchMenu business.

Suggested teams:

HQ Admin
Merchant Ops
Support
Field Ops
Inventory Ops
AI Menu Review
Sales Ops
Product Ops
Engineering Ops
Finance/Billing Ops

Teams should have role and responsibility definitions.

Teams do not automatically grant system access.

Access must be governed by Identity Access.

13\. Operator Context

Operator means an internal CatchMenu worker, admin, support member, field operator, or reviewer.

Examples:

CatchMenu HQ Admin
Support Operator
Field Operator
Inventory Operator
AI Menu Reviewer
Sales/Ops Manager
Finance/Billing Operator
System Admin

Operator is not the same as Franchise OS employee by default.

An individual may exist in both systems later, but authority must be scoped separately.

14\. Merchant Account Context

Merchant Account represents a SaaS customer account.

A merchant account may contain:

merchant\_account\_id
merchant\_name
merchant\_company\_id
service\_status
trial\_status
plan\_status
primary\_owner\_user\_id
created\_at

Merchant Account is the customer-side root for CatchMenu SaaS.

It may represent:

single independent restaurant
small restaurant group
franchisee company
Yoonsul-affiliated store group
test merchant
trial merchant

15\. Merchant Company Context

Merchant Company represents the business/company behind one or more stores.

A merchant company may own or operate multiple stores.

Examples:

merchant company
restaurant operating company
franchisee company
individual owner business
test company

Merchant Company may be used for:

contract
billing
owner access
multi-store ownership
support responsibility

16\. Merchant Store Context

Merchant Store represents the actual location using CatchMenu.

A store may have:

store\_id
merchant\_account\_id
merchant\_company\_id
store\_name
store\_address
store\_status
service\_status
menu\_context\_id
entry\_media\_assignment
enabled\_stage

Stage 0, Stage 1, Owner Console, Entry Media, and Merchant Ops all depend on store context.

Core rule:

Store is the operating context.
Merchant Account is the customer relationship context.

17\. Service Status Context

CatchMenu service status should be tracked separately from organization identity.

Suggested statuses:

PROSPECT
TRIAL\_PENDING
TRIAL\_ACTIVE
TRIAL\_EXPIRED
CONVERTED
ACTIVE\_PAID
SUSPENDED
TERMINATION\_PENDING
TERMINATED
REACTIVATION\_PENDING

Service status affects:

owner console access
Entry Media mapping
request receiving
support visibility
billing
field recovery

But service status should not erase organization records.

18\. Internal Responsibility Assignment

CatchMenu should support assignment of responsibility.

Examples:

merchant onboarding owner
field installation operator
support owner
AI menu review owner
inventory owner
billing owner
HQ escalation owner
backup operator

Responsibility assignment must be traceable.

Core rule:

Responsibility is operational accountability.
Permission is system authority.
They are related but not identical.

19\. Backup Responsibility

Backup responsibility must be explicit.

A backup operator may act when the primary responsible operator is unavailable.

Backup access should be:

time scoped
reason scoped
role scoped
audit logged
re-authenticated for sensitive action

This pattern may borrow from Franchise OS governance, but must be implemented within CatchMenu authority.

20\. Cross-Business Boundary

CatchMenu and Franchise OS must not silently share authority.

Examples:

Franchise OS HQ admin
does not automatically become CatchMenu HQ admin

CatchMenu support operator
does not automatically access Franchise OS HR/payroll

Yoonsul store owner
does not automatically access all CatchMenu SaaS merchants

CatchMenu merchant owner
does not access Franchise OS internal operations

Core rule:

Cross-business access requires explicit federation or assignment.

21\. Federation Future

In the future, CatchMenu and Franchise OS may be federated.

Possible federation areas:

shared login
shared group-level reporting
Yoonsul-owned store integration
shared audit dashboard
shared billing reference
shared menu/product catalog for Yoonsul stores

Federation must be explicit.

Until then:

separate organization context
separate roles
separate permissions
separate audit
separate support boundary

22\. Relationship To Identity Access

Organization Core defines:

who exists
which company/business/team/store they belong to
what responsibility context exists

Identity Access defines:

how users log in
what roles they have
which scopes they can access
which sensitive actions require reauthentication
how support access is masked and audited

Core separation:

Organization Core defines structure.
Identity Access defines authority.

23\. Relationship To CatchMenu HQ

CatchMenu HQ uses Organization Core to manage:

platform company context
merchant accounts
merchant stores
service status
internal teams
operator assignments
escalation ownership

CatchMenu HQ is the administrative surface.

Organization Core is the structural model behind it.

24\. Relationship To Owner Console

Owner Console is merchant-facing.

It should use Organization Core to understand:

which merchant account the user belongs to
which store the user can manage
which service status applies
which plan or trial status applies

Owner Console must not expose internal company/team structure unless relevant.

25\. Relationship To Merchant Ops

Merchant Ops uses Organization Core for:

trial merchant onboarding
field installation assignment
conversion follow-up
Entry Plate recovery
service suspension workflow
support escalation
operator assignment

Merchant Ops is operational workflow.

Organization Core is the structural truth.

26\. Relationship To Entry Media Inventory

Entry Media Inventory depends on organization/store context.

Entry Media assignments should reference:

merchant\_account\_id
merchant\_company\_id if needed
store\_id
service\_status
operator assignment if relevant

But Entry Media Inventory does not own merchant organization.

Core separation:

Organization Core owns merchant/store structure.
Entry Media Inventory owns QR/NFC asset lifecycle.

27\. Relationship To Stage Runtime

Stage 0 and Stage 1 consume organization context.

They need:

store\_id
merchant\_account\_id
service\_status
enabled\_stage
owner console availability
support escalation context

Stage runtime should not own company or organization structure.

Core rule:

Runtime uses store context.
Organization Core owns store context.

28\. Minimum MVP Requirement

MVP Organization Core should support at least:

CatchMenu operating company record
business unit or team references
merchant account
merchant company optional
merchant store
service status
trial status
internal operator
operator responsibility assignment
basic backup responsibility
cross-business boundary note

MVP may defer:

complex legal entity hierarchy
multi-country company structure
advanced group federation
full employee HR
payroll
attendance
contract document management
deep org chart

29\. Suggested Documents

This folder may include:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00520\_Internal\_Team\_Role\_And\_Responsibility\_Policy.md
00530\_Merchant\_Account\_Company\_And\_Store\_Context\_Policy.md
00540\_Operator\_Assignment\_And\_Backup\_Responsibility\_Policy.md
00550\_Cross\_Business\_Franchise\_OS\_And\_CatchMenu\_Boundary\_Policy.md
00590\_Organization\_Core\_MVP\_Cutline.md
00599\_Organization\_Core\_Index\_And\_Readiness\_Check.md

30\. Final Rule

CatchMenu is a separate operating business context.

Final rule:

Define CatchMenu as its own organization.
Separate it from Franchise OS by default.
Share governance philosophy where useful.
Do not import unrelated HR weight.
Track company, business unit, team, operator, merchant, and store context.
Use Identity Access for authority.
Use CatchMenu HQ for administration.
Federate with Franchise OS only when explicitly designed.
