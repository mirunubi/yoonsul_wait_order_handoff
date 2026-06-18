# 000210_Index_Organization_Core_And_Readiness_Check

Legacy path: $old.

1\. Purpose

This document closes the Organization Core document set for CatchMenu / Wait Order Handoff.

CatchMenu may later become:

separate legal company
independent business unit
operating division
subsidiary-like SaaS business
internal product line under a broader group

The final corporate form may be decided later.

However, the system must be designed now so that CatchMenu has its own organization structure, merchant context, operator responsibility, and cross-business boundary.

Core purpose:

Summarize Organization Core documents.
Confirm CatchMenu business boundary.
Define readiness before Identity Access, CatchMenu HQ, Owner Console, Merchant Ops, and Stage 1\.
Keep future legal/company structure flexible.
Prevent Franchise OS authority from leaking into CatchMenu.

Korean purpose:

Organization Core 문서 묶음을 정리한다.
CatchMenu 사업 경계를 확인한다.
Identity Access, CatchMenu HQ, Owner Console, Merchant Ops, Stage 1로 넘어가기 전 준비상태를 점검한다.
향후 법인/사업부/하위조직 구조가 유연하게 바뀔 수 있게 한다.
Franchise OS 권한이 CatchMenu로 새어 들어오지 않게 한다.

2\. Folder Role

This folder defines the structural organization model behind CatchMenu.

It answers:

What is CatchMenu as an operating business?
How is CatchMenu separated from Franchise OS?
What is a merchant account?
What is a merchant store?
Who is responsible for a merchant or task?
Who can act as backup?
How are Yoonsul-affiliated stores linked safely?
What must exist before permissions and HQ screens are designed?

This folder does not define:

login implementation
permission matrix
full HR system
payroll
attendance
staff scheduling
merchant owner console UI details
Stage 0/1 runtime details
Entry Media physical SOP
billing engine
legal entity final decision

3\. Document Index

This folder contains:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00520\_Internal\_Team\_Role\_And\_Responsibility\_Policy.md
00530\_Merchant\_Account\_Company\_And\_Store\_Context\_Policy.md
00540\_Operator\_Assignment\_And\_Backup\_Responsibility\_Policy.md
00550\_Cross\_Business\_Franchise\_OS\_And\_CatchMenu\_Boundary\_Policy.md
00590\_Organization\_Core\_MVP\_Cutline.md
00599\_Organization\_Core\_Index\_And\_Readiness\_Check.md

4\. Core Constitution

Organization Core follows these constitution-level rules:

CatchMenu is its own operating business context.
CatchMenu may later become a legal company, business unit, division, or subsidiary.
The final corporate form may change.
The organization model must remain flexible.
Franchise OS and CatchMenu are separated by default.
Same group ownership does not create shared authority.
Merchant Account is the SaaS customer relationship.
Merchant Store is the runtime operating location.
Responsibility is not permission.
Cross-business link is reference, not authority.

Korean summary:

CatchMenu는 자체 운영 사업 컨텍스트를 가진다.
CatchMenu는 향후 법인, 사업부, 하위조직, 자회사형 SaaS 사업이 될 수 있다.
최종 회사 형태는 나중에 바뀔 수 있다.
조직 모델은 유연해야 한다.
Franchise OS와 CatchMenu는 기본적으로 분리된다.
같은 그룹 소유가 공유 권한을 만들지 않는다.
Merchant Account는 SaaS 고객 관계다.
Merchant Store는 런타임 운영 매장이다.
책임은 권한이 아니다.
Cross-business link는 참조일 뿐 권한이 아니다.

5\. Current Strategic Position

At this stage, CatchMenu should be modeled as:

separate operating business context

not yet necessarily as:

separate legal entity

This allows future options:

remain internal product line
become independent business unit
become separate company
become subsidiary
operate under existing legal entity
split into external SaaS company later

Core rule:

Do not hard-code the future corporate form too early.
Do model the operating boundary now.

6\. Company Boundary Readiness

Company boundary is ready when the system can represent:

CatchMenu operating company or business unit
parent group reference if needed
company type
operating status
legal entity reference optional
business unit list

The model should allow:

legal entity unknown
legal entity shared with another group company
legal entity changed later
business unit upgraded to company later
company split or restructured later

Readiness rule:

CatchMenu must have company context even before final legal form is decided.

7\. Legal Entity Readiness

Legal entity readiness does not require final incorporation decision.

MVP may support:

legal\_entity\_ref \= optional

Later it may support:

merchant contract legal entity
billing legal entity
tax invoice legal entity
data processing legal entity
liability boundary

Core rule:

Legal entity is an axis.
It is not the same as operating business.

8\. Business Unit Readiness

Business unit readiness is achieved when CatchMenu can represent internal responsibility areas such as:

HQ Admin
Merchant Ops
Support
Field Ops
Inventory Ops
AI Menu Review
Sales Ops
Finance/Billing Ops
Product/Engineering Ops

MVP may combine teams.

Example:

Field Ops \+ Inventory Ops combined in MVP
Support \+ Merchant Ops partially combined in MVP
HQ Admin \+ Audit Review combined in MVP

Core rule:

Teams may be small.
Responsibilities must still be explicit.

9\. Merchant Account Readiness

Merchant Account readiness is achieved when the system can represent:

trial merchant
external restaurant merchant
production SaaS merchant
Yoonsul-affiliated merchant
test merchant
internal demo merchant

Minimum fields:

merchant\_account\_id
merchant\_account\_name
merchant\_account\_type
service\_status
trial\_status
primary\_owner\_user\_id
primary\_contact\_ref
created\_at

Readiness rule:

Merchant Account must exist before Owner Console and Merchant Ops can be safely designed.

10\. Merchant Store Readiness

Merchant Store readiness is achieved when the system can represent:

actual operating location
store-level service status
store-level trial status
enabled stage
menu context
Entry Media relationship
Owner Console request board context
Stage runtime context

Minimum fields:

merchant\_store\_id
merchant\_account\_id
store\_name
store\_status
service\_status
trial\_status
enabled\_stage
menu\_context\_id
created\_at

Readiness rule:

Merchant Store is the runtime anchor for Entry Media, Stage 0, Stage 1, Owner Console, and Support.

11\. Merchant Company Readiness

Merchant Company may be optional for early trial.

MVP can defer full merchant company setup when:

merchant is trial-only
merchant has one store
billing is not active
contract is not finalized

Merchant Company becomes necessary when:

paid production service starts
multi-store merchant exists
billing or tax invoice is needed
contract party must be clear

Core rule:

Do not block trial onboarding with heavy company setup.
Do not enter paid production without stable business context.

12\. Internal Team Readiness

Internal team readiness is achieved when the system can represent at least:

HQ Admin
Merchant Ops
Support
Field/Inventory Ops
AI Menu Review

Each team should have a clear responsibility.

Examples:

HQ Admin
\= platform-level control and high-risk actions

Merchant Ops
\= trial onboarding, follow-up, conversion, termination coordination

Support
\= merchant issues, support signals, evidence review

Field/Inventory Ops
\= Entry Plate delivery, recovery, inspection, reallocation readiness

AI Menu Review
\= menu draft extraction review, critical warning review, translation review

Core rule:

Team exists to route work.
Permission still belongs to Identity Access.

13\. Operator Readiness

Operator readiness is achieved when the system can represent:

internal operator
operator team
operator status
primary role
business context

Minimum operator types:

HQ Admin
Merchant Ops Operator
Support Operator
Field Operator
Inventory Operator
AI Menu Reviewer
System Admin

Operator must not be treated as Franchise OS employee by default.

Core rule:

Same person may work across businesses.
Authority remains scoped per business.

14\. Responsibility Assignment Readiness

Responsibility assignment is ready when the system can assign:

primary owner
backup owner
target object
responsibility type
status
reason
trace

Minimum target types:

merchant\_account
merchant\_store
trial\_case
field\_task
entry\_media\_recovery
support\_case
AI\_menu\_review
runtime\_incident

Readiness rule:

Every active operational object that needs human follow-up should have an owner.

15\. Backup Responsibility Readiness

Backup responsibility is ready when the system can represent:

backup operator
backup reason
backup scope
backup start
backup expiry
backup activation event

Backup applies to:

support case
Entry Media recovery
wrong mapping incident
critical AI menu review
service termination
trial conversion deadline

Core rule:

Backup preserves continuity.
Backup does not create hidden permanent authority.

16\. Cross-Business Boundary Readiness

Cross-business boundary is ready when the system enforces:

Franchise OS users do not receive CatchMenu authority by default.
CatchMenu users do not receive Franchise OS authority by default.
External CatchMenu merchants are not Franchise OS stores by default.
Yoonsul-affiliated store links are explicit.
Cross-business link is reference, not permission.

Readiness rule:

Same group ownership is not enough to grant access.

17\. Yoonsul-Affiliated Store Readiness

Yoonsul-affiliated store readiness is achieved when the system can explicitly link:

Franchise OS store
→ CatchMenu merchant\_store

with relationship type:

YOONSUL\_OWNED\_STORE
YOONSUL\_FRANCHISE\_STORE
AFFILIATED\_STORE
PILOT\_STORE
INTEGRATED\_STORE

The link must preserve:

source system
source entity
target system
target entity
relationship type
status
created by
created at
trace

Core rule:

Same physical store may have separate system identities.
The relationship must be explicit.

18\. External Merchant Readiness

External merchant readiness is achieved when an external restaurant can exist only inside CatchMenu context.

External merchant should create:

CatchMenu merchant\_account
CatchMenu merchant\_store
CatchMenu owner access
CatchMenu service status
CatchMenu Entry Media assignment

It must not automatically create:

Franchise OS store
Franchise OS employee
Franchise OS payroll profile
Franchise OS franchise contract

Core rule:

External SaaS merchant is not a Yoonsul franchisee by default.

19\. Organization Audit Readiness

Organization audit is ready when sensitive organization changes create events.

Required audit examples:

CATCHMENU\_COMPANY\_CREATED
MERCHANT\_ACCOUNT\_CREATED
MERCHANT\_STORE\_CREATED
MERCHANT\_SERVICE\_STATUS\_CHANGED
MERCHANT\_TRIAL\_STATUS\_CHANGED
MERCHANT\_STORE\_STAGE\_ENABLED
OPERATOR\_ASSIGNED
RESPONSIBILITY\_ASSIGNED
BACKUP\_RESPONSIBILITY\_ASSIGNED
CROSS\_BUSINESS\_LINK\_CREATED
CROSS\_BUSINESS\_LINK\_UPDATED

Minimum audit fields:

event\_id
entity\_type
entity\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

Core rule:

Organization structure creates authority context.
It must be auditable.

20\. Organization Failure Readiness

Organization failure events are ready when invalid structure actions are denied and recorded.

Examples:

create store without merchant account
enable stage without store context
enable stage without menu context
assign disabled operator
create cross-business link without relationship type
grant authority through link alone

Failure code examples:

WOH.ORG.MERCHANT.STORE.CREATE.ACCOUNT\_REQUIRED
WOH.ORG.MERCHANT.STORE.STAGE\_ENABLE.MENU\_CONTEXT\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.DISABLED\_OPERATOR\_DENIED
WOH.ORG.CROSS\_BUSINESS.LINK.RELATIONSHIP\_TYPE\_REQUIRED
WOH.ORG.CROSS\_BUSINESS.AUTHORITY.LINK\_ONLY\_DENIED

Core rule:

Invalid organization action must fail with trace.

21\. Organization Support Signal Readiness

Organization support signals are ready when missing or conflicting structure can be surfaced.

Examples:

MERCHANT\_STORE\_CONTEXT\_MISSING
MERCHANT\_MENU\_CONTEXT\_MISSING
MERCHANT\_SERVICE\_STATUS\_CONFLICT
MERCHANT\_TRIAL\_EXPIRED\_BUT\_ACTIVE
RESPONSIBILITY\_ORPHANED
RESPONSIBILITY\_OVERDUE
CROSS\_BUSINESS\_LINK\_CONFLICT
EXTERNAL\_MERCHANT\_MISCLASSIFIED\_AS\_FRANCHISE

Support Signal does not mutate organization context.

Core rule:

Signal the conflict.
Authorized workflow fixes it.

22\. Identity Access Dependency

Organization Core must be completed before Identity Access is finalized.

Organization Core provides:

company
business unit
team
operator
merchant account
merchant store
responsibility
backup
cross-business link

Identity Access will define:

login
role
permission
scope
support masking
sensitive action reauthentication
admin action authority

Core separation:

Organization Core defines structure.
Identity Access defines authority.

23\. CatchMenu HQ Dependency

CatchMenu HQ depends on Organization Core for:

company management
merchant account management
merchant store management
service status control
operator assignment
responsibility assignment
cross-business link review
audit visibility

Readiness rule:

CatchMenu HQ should not be designed before Organization Core boundaries are clear.

24\. Owner Console Dependency

Owner Console depends on Organization Core for:

merchant account
merchant store
store users
service status
trial status
enabled stage
menu context

Owner Console should expose merchant-side context only.

It should not expose internal team and cross-business structure by default.

25\. Merchant Ops Dependency

Merchant Ops depends on Organization Core for:

trial onboarding owner
field installation owner
usage follow-up owner
conversion owner
recovery owner
termination owner
support escalation owner

Merchant Ops workflow should not run without responsibility assignment.

26\. Entry Media Inventory Dependency

Entry Media Inventory depends on Organization Core for:

merchant\_store\_id
merchant\_account\_id
service\_status
trial\_status
operator responsibility
cross-business link if Yoonsul-affiliated

Core separation:

Organization Core owns merchant/store structure.
Entry Media Inventory owns QR/NFC asset lifecycle.

27\. Stage Runtime Dependency

Stage 0 and Stage 1 depend on Organization Core for:

store\_id
merchant\_account\_id
service\_status
enabled\_stage
menu\_context\_id
owner console availability
support route

Core separation:

Runtime uses organization context.
Organization Core owns organization context.

28\. Deferred Scope Confirmation

The following are deferred from Organization Core MVP:

final legal incorporation decision
deep legal entity hierarchy
multi-country company structure
intercompany billing
full group federation
shared SSO
Franchise OS HR integration
attendance
payroll
shift scheduling
employee contracts
labor settlement
advanced org chart
capacity planning
calendar integration
operator SLA automation

Deferred means:

not required for MVP
not forbidden for future
should not block current design

29\. What Must Not Be Deferred

The following must not be deferred:

CatchMenu operating boundary
merchant account
merchant store
trial status
service status
operator responsibility
backup responsibility
cross-business boundary
explicit Yoonsul-affiliated store link pattern
no implicit Franchise OS authority
basic audit/failure/support signal

These are structural foundations.

30\. Readiness Checklist

Organization Core is ready when:

CatchMenu can be represented as its own operating business.
Legal entity can remain optional.
Business unit/team structure exists.
Merchant Account exists.
Merchant Store exists.
Trial and service status exist.
Enabled stage can be set per store.
Menu context can be linked to store.
Internal operators can be represented.
Primary responsibility can be assigned.
Backup responsibility can be assigned.
Cross-business links are explicit.
External merchants remain outside Franchise OS by default.
Yoonsul-affiliated stores can be linked safely.
Sensitive organization changes are auditable.
Invalid organization actions create failure events.
Missing/conflicting structure can create support signals.

31\. Risk If Not Ready

If Organization Core is not ready, risks include:

Owner Console access scope becomes unclear
CatchMenu HQ has no authority boundary
Merchant Ops cannot assign work
Entry Media maps to unclear store context
Stage 1 handoff cannot identify merchant/store owner
External merchants mix with Franchise OS stores
Franchise OS admin authority leaks into CatchMenu
Legal/company restructuring later becomes painful

Therefore, this folder must be closed before deeper admin/HQ modules.

32\. Final Readiness Statement

Organization Core is ready when CatchMenu can operate as a structurally independent SaaS business context even if its final legal or corporate form remains undecided.

Final statement:

CatchMenu does not need final legal separation now.
CatchMenu does need its own operating boundary now.

Korean statement:

CatchMenu의 최종 법인 분리는 지금 확정하지 않아도 된다.
하지만 CatchMenu의 자체 운영 경계는 지금 필요하다.

33\. Final Rule

Organization Core must stay flexible in corporate form but strict in operating boundary.

Final rule:

Keep legal form flexible.
Keep operating boundary explicit.
Define merchant account and store context.
Assign operator responsibility.
Assign backup responsibility.
Separate CatchMenu from Franchise OS by default.
Link cross-business entities explicitly.
Do not import full HR.
Prepare Identity Access, HQ, Owner Console, Merchant Ops, Entry Media, and runtime on top.
