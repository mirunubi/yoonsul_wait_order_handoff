# 00190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary

Legacy path: $old.

1\. Purpose

This document defines the cross-business boundary policy between Franchise OS and CatchMenu / Wait Order Handoff.

Franchise OS and CatchMenu may belong to the same broader Yoonsul group.

However, they are separate operating businesses with different customers, authority models, data contexts, runtime responsibilities, and administrative surfaces.

Core purpose:

Separate Franchise OS and CatchMenu operating authority.
Allow explicit cross-business links when needed.
Prevent silent permission leakage.
Support Yoonsul-affiliated store integration safely.
Support external CatchMenu SaaS merchants without making them Franchise OS entities.
Prepare future federation without forcing premature integration.

Korean purpose:

Franchise OS와 CatchMenu의 운영 권한을 분리한다.
필요한 경우 명시적 cross-business link를 허용한다.
조용한 권한 누수를 방지한다.
윤슬 계열 매장 연동을 안전하게 지원한다.
외부 CatchMenu SaaS 고객이 Franchise OS 엔티티가 되지 않게 한다.
향후 federation을 준비하되 조기 통합을 강제하지 않는다.

2\. Scope

This document covers:

Franchise OS business boundary
CatchMenu business boundary
Yoonsul group context
cross-business store link
cross-business user link
cross-business reporting link
authority separation
data visibility separation
support access separation
audit separation
future federation
external merchant boundary
Yoonsul-affiliated store boundary

This document does not define:

full Franchise OS HR
Franchise OS payroll
Franchise OS attendance
Franchise OS store SOP
CatchMenu Stage 0 request runtime
CatchMenu Entry Media inventory lifecycle
CatchMenu Owner Console screen details
technical federation implementation
single sign-on implementation

Related documents:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00520\_Internal\_Team\_Role\_And\_Responsibility\_Policy.md
00530\_Merchant\_Account\_Company\_And\_Store\_Context\_Policy.md
00540\_Operator\_Assignment\_And\_Backup\_Responsibility\_Policy.md
00400\_identity\_access/
03000\_catchmenu\_hq/

3\. Core Principle

Same group does not mean same authority.

Core rule:

Shared ownership may create relationship.
Only explicit role and scope create authority.

Korean rule:

같은 그룹 소유는 관계를 만들 수 있다.
하지만 명시적 역할과 범위만 권한을 만든다.

A Franchise OS administrator does not automatically become a CatchMenu administrator.

A CatchMenu administrator does not automatically become a Franchise OS administrator.

4\. Business Boundary Summary

Franchise OS and CatchMenu must be treated as separate operating contexts.

Franchise OS
\= Yoonsul food-store and franchise operating platform

CatchMenu
\= external-facing SaaS platform for QR/NFC menu, request, and handoff runtime

They may be connected later, but the default is separation.

Core rule:

Separate by default.
Federate by explicit design.

5\. Franchise OS Boundary

Franchise OS manages:

Yoonsul-owned store operations
Yoonsul franchise store operations
franchise HQ governance
store HR
attendance
payroll
shift scheduling
store SOP
training
store finance
store inventory and SCM
franchisee operational control
Yoonsul brand execution

Franchise OS may consume or integrate with CatchMenu as a service.

However, Franchise OS does not automatically own CatchMenu SaaS merchants.

6\. CatchMenu Boundary

CatchMenu manages:

CatchMenu SaaS merchant accounts
external restaurant merchants
trial merchants
production SaaS merchants
QR/NFC Entry Media inventory
Entry Plate assignment and recovery
Owner Console
Merchant Ops
CatchMenu HQ
Support Signal
Evidence Packet
Stage 0 menu/request runtime
Stage 1 waiting/manual handoff runtime
future POS/KDS adapters
AI menu intake
service plans and trial status

CatchMenu may serve Yoonsul stores, but it also serves external merchants.

Therefore, it must not be modeled as only a Franchise OS feature.

7\. Yoonsul Group Context

A broader Yoonsul group may own or coordinate both businesses.

Possible structure:

Yoonsul Group
  ├─ Franchise OS Business
  │   └─ Yoonsul food-store and franchise operations
  │
  └─ CatchMenu SaaS Business
      └─ QR/NFC menu, request, and handoff SaaS

Group context may support:

strategy
ownership
brand governance
future reporting
future federation
shared philosophy

Group context must not automatically grant runtime or admin authority.

8\. External Merchant Boundary

External CatchMenu merchants are not Franchise OS entities by default.

An external restaurant using CatchMenu should create:

CatchMenu merchant\_account
CatchMenu merchant\_store
CatchMenu owner users
CatchMenu service status
CatchMenu Entry Media assignment
CatchMenu support context

It must not automatically create:

Franchise OS store
Franchise OS employee
Franchise OS payroll profile
Franchise OS franchise contract
Franchise OS store SOP context
Franchise OS internal settlement context

Core rule:

External SaaS merchant is a CatchMenu customer.
External SaaS merchant is not a Franchise OS store by default.

9\. Yoonsul-Affiliated Store Boundary

A Yoonsul-owned or Yoonsul-franchise store may use CatchMenu.

In that case, the same physical store may have two identities:

Franchise OS store
\= food-store/franchise operating context

CatchMenu merchant\_store
\= CatchMenu SaaS runtime/service context

The relationship must be explicit.

Suggested relationship types:

YOONSUL\_OWNED\_STORE
YOONSUL\_FRANCHISE\_STORE
AFFILIATED\_STORE
PILOT\_STORE
INTEGRATED\_STORE

Core rule:

Same physical store may exist in both systems.
System identity and authority remain separate unless explicitly linked.

10\. Cross-Business Link

A cross-business link is a reference between entities in different business systems.

Suggested link fields:

cross\_business\_link\_id
source\_system
source\_entity\_type
source\_entity\_id
target\_system
target\_entity\_type
target\_entity\_id
relationship\_type
status
created\_by
created\_at
trace\_id

Example:

source\_system \= Franchise OS
source\_entity\_type \= store
source\_entity\_id \= franchise\_store\_001

target\_system \= CatchMenu
target\_entity\_type \= merchant\_store
target\_entity\_id \= catchmenu\_store\_001

relationship\_type \= YOONSUL\_AFFILIATED\_STORE

Core rule:

Cross-business link is reference.
Cross-business link is not permission.

11\. Cross-Business User Link

The same human may exist in both systems.

Example:

same person
→ Franchise OS HQ user
→ CatchMenu HQ user

A cross-business identity link may be useful for login or reporting.

However, role authority must remain scoped.

Core rule:

Same human does not mean same authority.

A person may be:

Franchise OS Store Manager

but not:

CatchMenu HQ Admin

unless explicitly assigned.

12\. Role Separation

Roles must be separate across businesses.

Examples:

Franchise OS HQ Admin
≠ CatchMenu HQ Admin

Franchise OS Store Owner
≠ CatchMenu Merchant Owner

Franchise OS Support Operator
≠ CatchMenu Support Operator

Franchise OS Payroll Operator
≠ CatchMenu Billing Operator

CatchMenu Field Operator
≠ Franchise OS Store Staff

Core rule:

Role name similarity does not imply authority equivalence.

13\. Permission Separation

Permissions must be scoped by business.

A user may have permission in one business and not the other.

Examples:

A Franchise OS HQ admin may approve payroll.
That does not allow them to deactivate CatchMenu Entry Media.

A CatchMenu HQ admin may suspend merchant service.
That does not allow them to edit Franchise OS payroll.

A CatchMenu Support Operator may review CatchMenu support evidence.
That does not allow them to access Franchise OS HR records.

Core rule:

Permission belongs to a business scope.

14\. Data Visibility Separation

Data visibility must be separated.

Franchise OS data may include:

employee records
attendance
payroll
store labor data
franchise contracts
store finance
training records
internal SOP compliance

CatchMenu data may include:

merchant account
merchant store
Entry Media mapping
guest request
menu context
owner console usage
support signal
evidence packet
AI menu intake draft
service status
trial status

Default:

Franchise OS users cannot view CatchMenu merchant data by default.
CatchMenu users cannot view Franchise OS HR/payroll data by default.

15\. Support Access Separation

Support access must be separated.

CatchMenu support may access CatchMenu support evidence only within its scope.

Franchise OS support may access Franchise OS evidence only within its scope.

Cross-support access requires explicit policy.

Core rule:

Support access is scoped by business, role, case, and reason.

Support must not become a hidden bridge between two businesses.

16\. Audit Separation

Each business must keep its own audit trail.

CatchMenu audit should record CatchMenu actions.

Franchise OS audit should record Franchise OS actions.

Cross-business actions must record both the action and the relationship.

Examples:

cross-business store link created
cross-business identity link created
cross-business support view approved
cross-business reporting export generated
cross-business federation enabled

Core rule:

Cross-business actions require explicit audit.

17\. Authority Leakage Prohibition

Authority leakage means a role, link, or shared identity unintentionally grants access or action authority across business boundaries.

Prohibited:

Franchise OS admin automatically sees all CatchMenu merchants
CatchMenu support automatically sees Franchise OS employee data
Yoonsul-affiliated store link grants broad HQ authority
shared phone number grants both business roles
group-level owner bypasses CatchMenu audit
Franchise OS role copied into CatchMenu without scope review

Core rule:

No implicit cross-business authority.

18\. Shared Philosophy Allowed

CatchMenu may reuse Franchise OS governance philosophy.

Allowed shared patterns:

least privilege
role-based access
store-scoped permission
HQ backup responsibility
sensitive action reauthentication
audit event
support masking
evidence packet
append-only correction
state transition guard

Not allowed by default:

copy all Franchise OS HR tables
copy payroll workflow
copy attendance workflow
copy employee contract lifecycle
grant Franchise OS roles inside CatchMenu automatically

Core rule:

Reuse principles.
Do not import unrelated operational weight.

19\. Shared Component Possibility

Some components may later become shared group-level services.

Candidates:

authentication
identity profile
audit event viewer
notification service
support evidence viewer
role framework
document storage
billing reference

Shared components require explicit federation design.

Until then, each business should keep its own scopes.

20\. Federation Definition

Federation means controlled integration between Franchise OS and CatchMenu.

Federation may include:

shared login
cross-system store reference
Yoonsul-affiliated store mapping
shared reporting dashboard
shared audit export
shared support escalation
menu sync for Yoonsul stores
billing reference integration

Federation must define:

source of truth
data ownership
permission mapping
audit ownership
support visibility
failure handling
revocation method

Core rule:

Federation is designed.
Federation is not assumed.

21\. Source Of Truth Rule

For cross-business integration, each data type must have a source of truth.

Examples:

Franchise OS owns Yoonsul store HR.
CatchMenu owns Entry Media mapping.
Franchise OS owns franchise payroll.
CatchMenu owns CatchMenu merchant service status.
Franchise OS owns internal store SOP.
CatchMenu owns CatchMenu request runtime evidence.

Core rule:

Every shared data element needs a source of truth.

22\. Yoonsul Store Using CatchMenu

If a Yoonsul store uses CatchMenu:

Franchise OS remains source of truth for store operations.
CatchMenu becomes source of truth for CatchMenu Entry Media and request runtime.

Possible relationship:

Franchise OS store
→ linked CatchMenu merchant\_store
→ linked Entry Media mapping
→ linked Stage 0/1 runtime

But the user and role scopes must be explicit.

23\. External Store Using CatchMenu

If an external store uses CatchMenu:

CatchMenu is the only system context by default.
Franchise OS has no authority.
Franchise OS has no visibility.
Franchise OS has no HR/payroll relationship.

Core rule:

External CatchMenu merchant remains external unless explicitly onboarded elsewhere.

24\. Cross-Business Reporting

Group-level reporting may later combine metrics.

Examples:

number of Yoonsul stores using CatchMenu
CatchMenu usage in Yoonsul-affiliated stores
external merchant trial conversion
Entry Media inventory usage
support volume by business

Reporting must not expose sensitive data beyond scope.

Aggregate reporting is safer than raw record sharing.

Core rule:

Report aggregates when possible.
Share raw records only with explicit authority.

25\. Cross-Business Support Case

A support case may involve both systems.

Example:

Yoonsul store has Franchise OS store context
and CatchMenu Entry Media problem

Cross-business support case must define:

primary system
secondary system
case owner
data visibility
support scope
audit event
resolution authority

Support staff must not browse unrelated records.

26\. Cross-Business Incident

A cross-business incident may involve:

wrong store link
wrong merchant-store mapping
Franchise OS store linked to wrong CatchMenu store
shared user given wrong scope
support evidence exposed across boundary
menu sync failure

Incident must create audit and escalation.

Possible signal:

CROSS\_BUSINESS\_BOUNDARY\_CONFLICT

27\. Cross-Business Link Status

Suggested link statuses:

LINK\_PENDING
LINK\_ACTIVE
LINK\_SUSPENDED
LINK\_REVIEW\_REQUIRED
LINK\_TERMINATED
LINK\_INVALIDATED

A suspended or invalidated link must not continue to grant data flow or inferred relationship.

Core rule:

Broken link must fail closed.

28\. Link Creation Preconditions

Before creating a cross-business link, verify:

source entity exists
target entity exists
relationship type is defined
actor has authority
business reason is provided
data visibility is understood
audit event will be created

If any precondition fails, link creation must be denied.

29\. Link Deactivation

Cross-business link may be deactivated when:

store no longer affiliated
merchant terminated
wrong link detected
federation paused
data sharing no longer allowed
security concern exists

Deactivation must preserve history.

Core rule:

Deactivate the link.
Do not erase the link history.

30\. Cross-Business Failure Events

Invalid cross-business actions must create failure events.

Examples:

create link without relationship type
grant authority through link alone
access Franchise OS data from CatchMenu role
access CatchMenu merchant data from Franchise OS role
activate federation without source-of-truth policy
delete cross-business link history

Example failure codes:

WOH.ORG.CROSS\_BUSINESS.LINK.RELATIONSHIP\_TYPE\_REQUIRED
WOH.ORG.CROSS\_BUSINESS.AUTHORITY.LINK\_ONLY\_DENIED
WOH.ORG.CROSS\_BUSINESS.ACCESS.FRANCHISE\_DATA\_DENIED
WOH.ORG.CROSS\_BUSINESS.ACCESS.CATCHMENU\_DATA\_DENIED
WOH.ORG.CROSS\_BUSINESS.FEDERATION.SOURCE\_OF\_TRUTH\_REQUIRED
WOH.ORG.CROSS\_BUSINESS.LINK.DELETE\_HISTORY\_DENIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

31\. Cross-Business Audit Events

Recommended audit events:

CROSS\_BUSINESS\_LINK\_CREATED
CROSS\_BUSINESS\_LINK\_UPDATED
CROSS\_BUSINESS\_LINK\_SUSPENDED
CROSS\_BUSINESS\_LINK\_TERMINATED
CROSS\_BUSINESS\_LINK\_INVALIDATED
CROSS\_BUSINESS\_IDENTITY\_LINK\_CREATED
CROSS\_BUSINESS\_ACCESS\_GRANTED
CROSS\_BUSINESS\_ACCESS\_REVOKED
CROSS\_BUSINESS\_SUPPORT\_VIEW\_APPROVED
CROSS\_BUSINESS\_REPORT\_GENERATED
CROSS\_BUSINESS\_FEDERATION\_ENABLED
CROSS\_BUSINESS\_FEDERATION\_DISABLED

Audit event fields:

event\_id
source\_system
source\_entity\_type
source\_entity\_id
target\_system
target\_entity\_type
target\_entity\_id
relationship\_type
actor\_type
actor\_id
reason
created\_at
trace\_id

32\. Support Signals

Support signals may include:

CROSS\_BUSINESS\_LINK\_CONFLICT
CROSS\_BUSINESS\_AUTHORITY\_CONFLICT
CROSS\_BUSINESS\_DATA\_VISIBILITY\_CONFLICT
YOONSUL\_STORE\_LINK\_MISSING
YOONSUL\_STORE\_LINK\_WRONG\_TARGET
EXTERNAL\_MERCHANT\_MISCLASSIFIED\_AS\_FRANCHISE
FRANCHISE\_USER\_CATCHMENU\_SCOPE\_MISSING
CATCHMENU\_USER\_FRANCHISE\_SCOPE\_DENIED

Support Signal does not create or remove authority.

It alerts authorized operators.

33\. Evidence Packet Relationship

Evidence Packet for cross-business issue may include:

source system
target system
relationship type
link status
actor
created\_at
support signal
failure event
audit event
data visibility scope
source of truth note

Evidence must not expose unrelated records across business boundaries.

Core rule:

Evidence should explain the link.
Evidence should not become unauthorized data sharing.

34\. MVP Requirements

MVP should support at least:

separate CatchMenu organization context
separate Franchise OS boundary statement
merchant account not treated as Franchise OS by default
explicit Yoonsul-affiliated store link
cross-business link status
cross-business link audit event
no implicit permission through link
basic failure event
basic support signal

MVP may defer:

full SSO federation
group-wide reporting
shared audit dashboard
advanced data sync
automatic store sync
deep Franchise OS integration
cross-system billing automation

35\. Suggested Conceptual Entities

Suggested entities:

cross\_business\_links
cross\_business\_link\_events
cross\_business\_identity\_links
cross\_business\_access\_grants
cross\_business\_support\_signals

This document defines policy.

Actual schema may be designed later.

36\. Risk If Skipped

If cross-business boundary is not defined, risks include:

Franchise OS authority leaks into CatchMenu
CatchMenu support sees Franchise OS HR data
external SaaS merchants are treated as franchise stores
Yoonsul-affiliated store mapping becomes ambiguous
wrong store receives Entry Media runtime
billing and contract responsibility becomes unclear
audit trail becomes mixed
future spin-off becomes painful

Therefore, this boundary is foundational.

37\. Final Rule

Franchise OS and CatchMenu may belong to the same group, but their operating authority must remain separated unless explicitly federated.

Final rule:

Separate the businesses.
Link explicitly.
Deny implicit authority.
Preserve source of truth.
Audit every cross-business link.
Protect external merchants.
Protect Franchise OS data.
Federate later by design, not by accident.
