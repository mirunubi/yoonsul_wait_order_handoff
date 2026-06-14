# **00590 Organization Core MVP Cutline**

Legacy path: $old.

## **1\. Purpose**

This document defines the MVP implementation cutline for CatchMenu Organization Core.

CatchMenu / Wait Order Handoff may operate as a separate SaaS company, business unit, or operating division within the broader Yoonsul group.

The MVP must be strong enough to support merchant onboarding, store context, operator responsibility, Entry Media assignment, Owner Console, Merchant Ops, CatchMenu HQ, and Stage 0/Stage 1 runtime.

At the same time, the MVP must not import the full Franchise OS HR, payroll, attendance, or labor management burden.

Core purpose:

Define the minimum Organization Core required for CatchMenu MVP.
Separate required company/merchant/store/operator context from deferred HR complexity.
Prepare Identity Access, CatchMenu HQ, Owner Console, Merchant Ops, Entry Media, and Stage Runtime.
Prevent Franchise OS and CatchMenu authority from being mixed accidentally.

Korean purpose:

CatchMenu MVP에 필요한 최소 Organization Core를 정의한다.
필수 회사/고객사/매장/운영자 컨텍스트와 후순위 HR 복잡도를 분리한다.
Identity Access, CatchMenu HQ, Owner Console, Merchant Ops, Entry Media, Stage Runtime의 기반을 마련한다.
Franchise OS와 CatchMenu 권한이 우발적으로 섞이지 않게 한다.

## **2\. MVP Boundary**

Organization Core MVP must support:

CatchMenu operating company
business unit or team reference
merchant account
merchant store
trial status
service status
internal operator
operator responsibility assignment
backup responsibility
cross-business boundary with Franchise OS
explicit Yoonsul-affiliated store link if needed

Organization Core MVP must not require:

attendance
payroll
shift scheduling
employee contracts
employee documents
labor settlement
Franchise OS HR
deep legal entity hierarchy
enterprise org chart
full group federation

Core rule:

Model the business structure needed for SaaS operation.
Do not import unrelated HR weight.

## **3\. MVP Must-Have: CatchMenu Company Context**

MVP must define CatchMenu as its own operating company or business unit context.

Minimum fields:

company\_id
company\_name
company\_type
operating\_status
parent\_group\_ref optional
legal\_entity\_ref optional
created\_at

Suggested company type:

SAAS\_COMPANY
BUSINESS\_UNIT
OPERATING\_DIVISION
INTERNAL\_PRODUCT\_UNIT

MVP may start with one company record:

CatchMenu SaaS Business

Core rule:

CatchMenu must have its own company context even if legal separation comes later.

## **4\. MVP Must-Have: Business Unit / Team Context**

MVP must support basic internal responsibility grouping.

Minimum teams:

HQ Admin
Merchant Ops
Support
Field/Inventory Ops
AI Menu Review

Optional early teams:

Sales Ops
Finance/Billing Ops
Engineering Ops

MVP does not need a full corporate org chart.

Core rule:

Teams exist to route responsibility.
They do not automatically grant system authority.

## **5\. MVP Must-Have: Operator Context**

MVP must support internal CatchMenu operators.

Minimum operator types:

HQ Admin
Merchant Ops Operator
Support Operator
Field Operator
Inventory Operator
AI Menu Reviewer
System Admin

Minimum fields:

operator\_id
user\_id
company\_id
team\_id
operator\_status
primary\_role
created\_at

Operator is not the same as Franchise OS employee by default.

Core rule:

Same human may exist in multiple systems.
Authority must be scoped per business.

## **6\. MVP Must-Have: Merchant Account**

MVP must support Merchant Account as the SaaS customer relationship root.

Minimum fields:

merchant\_account\_id
merchant\_account\_name
merchant\_account\_type
service\_status
trial\_status
primary\_owner\_user\_id
primary\_contact\_ref
created\_at
created\_by

Suggested merchant account types:

INDEPENDENT\_RESTAURANT
RESTAURANT\_GROUP
YOONSUL\_AFFILIATED
TRIAL\_ONLY
TEST\_MERCHANT
INTERNAL\_DEMO

Core rule:

Merchant Account is the customer relationship.
It is not the same as physical store.

## **7\. MVP Must-Have: Merchant Store**

MVP must support Merchant Store as the runtime operating location.

Minimum fields:

merchant\_store\_id
merchant\_account\_id
store\_name
store\_display\_name
store\_address optional
store\_phone optional
store\_status
service\_status
trial\_status
menu\_context\_id
enabled\_stage
created\_at

Merchant Store is required for:

Entry Media mapping
Stage 0 guest flow
Stage 1 waiting handoff
Owner Console request board
Merchant Ops follow-up
Support Signal routing
Evidence Packet context

Core rule:

Store is the runtime context.
Merchant Account is the customer relationship context.

## **8\. MVP Optional: Merchant Company**

MVP may treat Merchant Company as optional for early trial merchants.

Merchant Company becomes more important for:

paid production merchant
multi-store merchant
billing
contract
tax invoice
legal contact

Minimum deferred fields:

merchant\_company\_id
merchant\_account\_id
company\_name
legal\_name
billing\_contact
contract\_contact
company\_status

MVP rule:

Trial merchants may start without full Merchant Company.
Production merchants should move toward stable Merchant Company context.

## **9\. MVP Must-Have: Service Status**

MVP must track service status.

Merchant account service status:

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

Store service status may use the same or a simplified set.

Core rule:

Service status affects access, Entry Media mapping, and runtime availability.
Service status must not erase merchant history.

## **10\. MVP Must-Have: Trial Status**

MVP must track trial status.

Suggested statuses:

TRIAL\_NOT\_STARTED
TRIAL\_PENDING
TRIAL\_ACTIVE
TRIAL\_EXTENDED
TRIAL\_EXPIRED
CONVERTED
DECLINED
NOT\_USING
UNREACHABLE
RECOVERY\_REQUIRED

Trial status affects:

Owner Console access
Merchant Ops follow-up
Entry Media recovery
admin suspension
service termination
conversion discussion

Core rule:

Trial is lightweight.
Trial still requires traceable organization context.

## **11\. MVP Must-Have: Enabled Stage**

Each merchant store must have enabled CatchMenu stage.

MVP values:

STAGE\_0A
STAGE\_0B
STAGE\_0C

Later values:

STAGE\_1
STAGE\_2
STAGE\_3
STAGE\_4
STAGE\_5

Core rule:

Enabled stage is store-level configuration.
Guest scan must not decide authority level by itself.

## **12\. MVP Must-Have: Menu Context Link**

Each active store should have a menu context reference.

Minimum:

menu\_context\_id
menu\_status
menu\_version optional

Stage runtime consumes this.

Owner Console and AI Menu Intake may create or modify it.

Core rule:

Organization Core links store to menu context.
Organization Core does not own menu editing logic.

## **13\. MVP Must-Have: Responsibility Assignment**

MVP must support assigning responsible internal operators.

Minimum responsibility targets:

merchant\_account
merchant\_store
trial\_case
field\_task
entry\_media\_recovery
support\_case
AI\_menu\_review
runtime\_incident

Minimum responsibility fields:

responsibility\_id
target\_type
target\_id
responsibility\_type
primary\_operator\_id
backup\_operator\_id
status
assigned\_at
assigned\_by
reason
trace\_id

Core rule:

Every active operational object that needs follow-up should have an owner.

## **14\. MVP Must-Have: Backup Responsibility**

MVP must support backup owner for operational continuity.

Minimum fields:

backup\_operator\_id
backup\_reason
backup\_scope
backup\_started\_at
backup\_expires\_at optional
activated\_by

Backup is especially important for:

support case
Entry Media recovery
wrong mapping incident
service termination
critical AI menu review
trial conversion deadline

Core rule:

Backup is continuity.
Backup is not permanent hidden authority.

## **15\. MVP Must-Have: Cross-Business Boundary**

MVP must explicitly define that Franchise OS and CatchMenu are separate business contexts.

Minimum rule:

Franchise OS users do not receive CatchMenu authority by default.
CatchMenu users do not receive Franchise OS authority by default.
External CatchMenu merchants are not Franchise OS stores by default.

Core rule:

Same group ownership does not create shared authority.

## **16\. MVP Must-Have: Yoonsul-Affiliated Store Link**

MVP should support explicit link for Yoonsul-affiliated stores if needed.

Minimum fields:

cross\_business\_link\_id
source\_system
source\_entity\_type
source\_entity\_id
target\_system
target\_entity\_type
target\_entity\_id
relationship\_type
status
created\_at
created\_by

Example relationship types:

YOONSUL\_OWNED\_STORE
YOONSUL\_FRANCHISE\_STORE
AFFILIATED\_STORE
PILOT\_STORE

Core rule:

Cross-business link is reference.
Cross-business link is not permission.

## **17\. MVP Must-Have: Basic Audit Events**

Organization Core MVP must create audit events for sensitive organization changes.

Required audit events:

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

Organization changes create operational authority context.
They must be auditable.

## **18\. MVP Must-Have: Basic Failure Events**

Invalid organization actions must create failure events.

Examples:

create store without merchant account
enable stage without store context
enable stage without menu context
assign disabled operator
create cross-business link without relationship type
grant authority through link alone

Example failure codes:

WOH.ORG.MERCHANT.STORE.CREATE.ACCOUNT\_REQUIRED
WOH.ORG.MERCHANT.STORE.STAGE\_ENABLE.MENU\_CONTEXT\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.DISABLED\_OPERATOR\_DENIED
WOH.ORG.CROSS\_BUSINESS.LINK.RELATIONSHIP\_TYPE\_REQUIRED
WOH.ORG.CROSS\_BUSINESS.AUTHORITY.LINK\_ONLY\_DENIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

## **19\. MVP Must-Have: Basic Support Signals**

Organization Core may emit support signals for missing or conflicting structure.

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

It alerts authorized operators.

## **20\. MVP Conceptual Entities**

MVP conceptual entities:

companies
business\_units
internal\_teams
operators
merchant\_accounts
merchant\_companies optional
merchant\_stores
merchant\_contacts
merchant\_store\_users reference
responsibility\_assignments
responsibility\_events
cross\_business\_links
organization\_audit\_events
organization\_support\_signals

This document defines policy.

Actual database schema may be designed later.

## **21\. MVP Data Relationship**

Minimum relationship:

company
→ business\_units / internal\_teams
→ operators

merchant\_account
→ merchant\_store
→ menu\_context
→ enabled\_stage
→ Entry Media assignment
→ Stage runtime

merchant\_account / merchant\_store
→ responsibility assignment
→ operator / backup operator

Cross-business optional relationship:

Franchise OS store
→ cross\_business\_link
→ CatchMenu merchant\_store

## **22\. What To Defer**

Defer the following until later:

full legal entity hierarchy
multi-country organization
intercompany billing
advanced contract lifecycle
full HR attendance
payroll
shift scheduling
employee contract management
deep org chart
operator capacity planning
calendar integration
full SLA automation
shared SSO federation
group-wide role inheritance
automatic Franchise OS synchronization

Deferred does not mean impossible.

Deferred means not needed for Organization Core MVP.

## **23\. What Must Not Be Imported From Franchise OS**

Do not import by default:

attendance\_records
payroll\_runs
employee\_contracts
employee\_documents
shift schedules
store labor cost rules
staff training lifecycle
Franchise OS employee HR hierarchy
Franchise settlement authority

CatchMenu may later integrate or reference Franchise OS for Yoonsul-affiliated stores.

But MVP should not copy HR weight.

Core rule:

Borrow governance philosophy.
Do not copy heavy HR runtime.

## **24\. Relationship To Identity Access**

Organization Core MVP must be ready for Identity Access.

Organization Core provides:

company
team
operator
merchant account
merchant store
responsibility
cross-business link

Identity Access will define:

login
role
permission
scope
reauthentication
support masking
admin action authority

Core separation:

Organization Core defines structure.
Identity Access defines authority.

## **25\. Relationship To CatchMenu HQ**

CatchMenu HQ depends on Organization Core for:

company management
merchant account management
merchant store management
service status control
operator assignment
responsibility assignment
cross-business link review
audit visibility

HQ is the admin surface.

Organization Core is the structural source.

## **26\. Relationship To Owner Console**

Owner Console depends on Organization Core for:

merchant account
store context
store users
service status
trial status
enabled stage
menu context link

Owner Console should not expose internal organization details unless needed.

## **27\. Relationship To Merchant Ops**

Merchant Ops depends on Organization Core for:

trial onboarding owner
field installation owner
usage follow-up owner
conversion owner
recovery owner
termination owner
support escalation owner

Merchant Ops is workflow.

Organization Core is accountability structure.

## **28\. Relationship To Entry Media Inventory**

Entry Media Inventory depends on Organization Core for:

merchant\_store\_id
service\_status
trial\_status
operator responsibility
cross-business link if Yoonsul-affiliated

Entry Media Inventory owns QR/NFC asset lifecycle.

Organization Core owns store/customer structure.

## **29\. Relationship To Stage Runtime**

Stage 0/1 runtime depends on Organization Core for:

store\_id
merchant\_account\_id
service\_status
enabled\_stage
menu\_context\_id
owner console availability
support routing

Runtime does not own organization structure.

Core rule:

Runtime uses organization context.
Organization Core owns organization context.

## **30\. MVP Readiness Checklist**

Organization Core MVP is ready when:

CatchMenu company context exists
basic teams exist
operators can be represented
merchant account can be created
merchant store can be created
trial status can be tracked
service status can be tracked
enabled stage can be set per store
menu context can be linked
responsible operator can be assigned
backup owner can be assigned
cross-business boundary is explicit
Yoonsul-affiliated store can be linked explicitly if needed
audit events exist for sensitive changes
failure events exist for invalid actions
support signals exist for missing context

## **31\. Risk If MVP Cutline Is Ignored**

If this cutline is ignored and the system is too small:

merchants become indistinct from stores
external merchants mix with Franchise OS stores
operator responsibility is unclear
Owner Console access becomes unsafe
Entry Media mapping lacks store ownership context
Stage 1 handoff cannot know business owner
support cannot route issues

If the system is too large:

CatchMenu becomes overloaded with payroll/attendance/HR
MVP slows down
external merchant SaaS becomes confused with Franchise OS
owner console becomes too complex
trial onboarding becomes heavy

The MVP must stay balanced.

## **32\. Final MVP Rule**

Organization Core MVP must be small but structurally correct.

Final rule:

Create CatchMenu company context.
Create merchant account and store context.
Track trial and service status.
Assign internal responsibility.
Assign backup where needed.
Separate CatchMenu from Franchise OS.
Link Yoonsul-affiliated stores explicitly.
Do not import full HR.
Prepare Identity Access and HQ on top.
