# 00170_Policy_Merchant_Account_Company_And_Store_Context

Legacy path: $old.

1\. Purpose

This document defines the Merchant Account, Merchant Company, and Merchant Store context policy for CatchMenu / Wait Order Handoff.

CatchMenu is a SaaS platform that may serve trial merchants, external independent restaurants, multi-store restaurant groups, Yoonsul-affiliated stores, and future production SaaS merchants.

Therefore, merchant identity, company identity, and store identity must be clearly separated.

Core purpose:

Define merchant account context.
Separate merchant company from merchant store.
Support single-store and multi-store merchants.
Support trial and production SaaS merchants.
Prepare Owner Console, Merchant Ops, Entry Media, Stage 0, and Stage 1 runtime.
Prevent external merchants from being mixed with Franchise OS stores by default.

Korean purpose:

고객사 계정 컨텍스트를 정의한다.
고객사 회사와 실제 매장을 분리한다.
단일 매장과 다점포 고객사를 모두 지원한다.
체험 고객사와 정식 SaaS 고객사를 지원한다.
Owner Console, Merchant Ops, Entry Media, Stage 0, Stage 1 런타임의 기반을 마련한다.
외부 고객사가 기본적으로 Franchise OS 매장과 섞이지 않게 한다.

2\. Scope

This document covers:

merchant\_account
merchant\_company
merchant\_store
store context
trial merchant
production merchant
external merchant
Yoonsul-affiliated merchant
multi-store merchant
service status
trial status
store status
owner relationship
primary contact
store-level configuration
cross-business store link

This document does not define:

individual login and password
detailed role permission matrix
full billing engine
merchant contract document system
Franchise OS HR
POS/KDS/payment integration
Entry Media physical lifecycle
Stage 0 request state transition

Related documents:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00520\_Internal\_Team\_Role\_And\_Responsibility\_Policy.md
00400\_identity\_access/
00300\_entry\_media\_inventory/
01100\_stage\_0\_entry\_runtime/
02400\_owner\_console/
02600\_merchant\_ops/
03000\_catchmenu\_hq/

3\. Core Principle

Merchant account, merchant company, and merchant store are different concepts.

Core rule:

Merchant Account is the SaaS customer relationship.
Merchant Company is the business or owner entity.
Merchant Store is the physical or operating location.

Korean rule:

Merchant Account는 SaaS 고객 관계다.
Merchant Company는 사업자/운영 회사다.
Merchant Store는 실제 운영 매장이다.

These must not be collapsed into one record.

4\. Merchant Account Definition

Merchant Account is the top-level customer relationship in CatchMenu.

A merchant account may represent:

single independent restaurant
small restaurant group
franchisee group
Yoonsul-affiliated store group
trial merchant
test merchant
production SaaS merchant
partner merchant

Recommended fields:

merchant\_account\_id
merchant\_account\_name
merchant\_account\_type
service\_status
trial\_status
primary\_owner\_user\_id
primary\_contact\_name
primary\_contact\_phone
primary\_contact\_email
created\_at
created\_by
status\_updated\_at

Merchant Account is the root context for Owner Console and Merchant Ops.

5\. Merchant Account Types

Suggested merchant account types:

INDEPENDENT\_RESTAURANT
RESTAURANT\_GROUP
FRANCHISEE\_GROUP
YOONSUL\_AFFILIATED
TRIAL\_ONLY
TEST\_MERCHANT
PARTNER\_MERCHANT
INTERNAL\_DEMO

Meaning:

INDEPENDENT\_RESTAURANT
\= single or owner-operated external restaurant

RESTAURANT\_GROUP
\= multi-store external restaurant business

FRANCHISEE\_GROUP
\= group operating under another franchise brand

YOONSUL\_AFFILIATED
\= Yoonsul-owned or Yoonsul-related store using CatchMenu

TRIAL\_ONLY
\= merchant using limited trial

TEST\_MERCHANT
\= internal test context

PARTNER\_MERCHANT
\= partner organization or special agreement merchant

INTERNAL\_DEMO
\= internal demonstration account

6\. Merchant Company Definition

Merchant Company represents the business entity or owner-side operating company behind one or more stores.

Merchant Company may be used for:

contract reference
billing reference
tax invoice reference
multi-store ownership
owner access grouping
merchant legal name
merchant business registration reference

Recommended fields:

merchant\_company\_id
merchant\_account\_id
company\_name
business\_registration\_ref
legal\_name
billing\_contact
contract\_contact
company\_status
created\_at

Merchant Company may be optional for very early trial merchants.

However, production paid merchants should have clearer company context.

7\. Merchant Store Definition

Merchant Store represents an actual operating location using CatchMenu.

A merchant account may have one or more merchant stores.

Recommended fields:

merchant\_store\_id
merchant\_account\_id
merchant\_company\_id
store\_name
store\_display\_name
store\_address
store\_phone
store\_status
service\_status
trial\_status
menu\_context\_id
enabled\_stage
timezone
business\_hours\_ref
created\_at

Merchant Store is the operating context for:

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

8\. Single-Store Merchant

For a single-store merchant:

merchant\_account
→ merchant\_company optional
→ one merchant\_store

Example:

merchant\_account \= "Garak Kimbap Trial"
merchant\_company \= optional during trial
merchant\_store \= "Garak Kimbap Main Store"

MVP may allow merchant account and store to be created together.

But the concepts should remain separable.

9\. Multi-Store Merchant

For a multi-store merchant:

merchant\_account
→ merchant\_company
→ multiple merchant\_stores

Example:

merchant\_account \= "ABC Restaurant Group"
merchant\_company \= "ABC Food Co."
merchant\_stores:
  \- ABC Gangnam
  \- ABC Sadang
  \- ABC Hongdae

Owner access must be scoped.

A user may access all stores or only selected stores.

Identity Access governs actual permission.

10\. Trial Merchant

Trial Merchant may start with minimal data.

Minimum trial merchant context:

merchant\_account
merchant\_store
trial\_status
service\_status
primary contact
assigned operator
Entry Media assignment if installed

Trial merchant may not yet have:

full billing profile
formal contract
multi-store structure
complete company record

Core rule:

Trial is lightweight.
Trial still requires traceable merchant and store context.

11\. Production Merchant

Production Merchant requires stronger context.

Minimum production merchant context:

merchant\_account
merchant\_company if applicable
merchant\_store
service\_plan
service\_status
owner user
billing/legal reference if paid
support owner
audit history

Production merchant should not depend on temporary trial-only data.

Core rule:

Production service requires stable merchant identity.

12\. External Merchant Boundary

External Merchant is a merchant that is not part of Yoonsul Franchise OS by default.

External merchant should create:

CatchMenu merchant\_account
CatchMenu merchant\_store
CatchMenu owner access
CatchMenu service status
CatchMenu Entry Media assignment

External merchant must not automatically create:

Franchise OS store
Franchise OS employee record
Franchise OS payroll record
Franchise OS franchise contract
Franchise OS internal settlement context

Core rule:

External SaaS merchant is not a Yoonsul franchisee by default.

13\. Yoonsul-Affiliated Store

A Yoonsul-affiliated store may use CatchMenu.

In that case, the same physical store may exist in both systems:

Franchise OS store
\= food-store operation context

CatchMenu merchant\_store
\= SaaS runtime/service context

The link must be explicit.

Suggested link fields:

franchise\_os\_store\_id
catchmenu\_merchant\_store\_id
relationship\_type
linked\_at
linked\_by

Suggested relationship type:

YOONSUL\_OWNED\_STORE
YOONSUL\_FRANCHISE\_STORE
AFFILIATED\_STORE
PILOT\_STORE

Core rule:

Same physical location may have separate system identities.
The relationship must be explicit.

14\. Store Service Status

Store service status should be tracked independently from merchant account status.

Suggested statuses:

STORE\_SERVICE\_PENDING
STORE\_TRIAL\_ACTIVE
STORE\_TRIAL\_EXPIRED
STORE\_ACTIVE\_PAID
STORE\_SUSPENDED
STORE\_TERMINATION\_PENDING
STORE\_TERMINATED
STORE\_REACTIVATION\_PENDING

Reason:

One merchant account may have several stores.
One store may be active while another is suspended.
One store may be trial while another is paid.

Core rule:

Merchant account status and store service status are related but separate.

15\. Store Operating Status

Store operating status describes whether the physical store is operating.

Suggested statuses:

PRE\_OPEN
OPEN
TEMPORARILY\_CLOSED
CLOSED
MOVED
UNKNOWN

Store operating status is not the same as CatchMenu service status.

Example:

store\_operating\_status \= OPEN
service\_status \= SUSPENDED

means the restaurant is open but CatchMenu service is suspended.

16\. Trial Status

Trial status should be tracked for merchant and store.

Suggested trial statuses:

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

Trial status may affect:

Owner Console access
Entry Media mapping
Merchant Ops follow-up
Field recovery
conversion discussion
service suspension

Trial status must not erase merchant or store records.

17\. Enabled Stage Per Store

Each store should have enabled CatchMenu stage.

Suggested values:

STAGE\_0A
STAGE\_0B
STAGE\_0C
STAGE\_1
STAGE\_2
STAGE\_3
STAGE\_4
STAGE\_5

MVP may only enable:

STAGE\_0A
STAGE\_0B
STAGE\_0C

Core rule:

Enabled stage is store-level configuration.
Guest scan must not decide authority level by itself.

18\. Menu Context Per Store

Each store should have a menu context.

Menu context may include:

menu\_context\_id
menu\_version
language support
category structure
item list
option structure
critical warning candidates
AI menu intake draft reference if applicable

Stage runtime consumes menu context.

Owner Console or AI Menu Intake may create or edit it.

Core rule:

Stage runtime consumes menu context.
Merchant/Owner/Admin workflow manages menu context.

19\. Primary Owner User

Merchant Account should have a primary owner user.

Primary owner may:

manage merchant account
view store list
manage owner console access if allowed
approve menu drafts if policy allows
review service status
communicate with support

Actual permissions are governed by Identity Access.

Core rule:

Primary owner is merchant-side responsibility.
Permission still requires role and scope.

20\. Store Users

Store users may include:

Owner
Store Manager
Store Staff Viewer
Request Board Viewer
Menu Editor
Billing Contact

Store user access should be scoped.

A user may have access to:

one store
multiple stores
entire merchant account
limited request board only
menu management only
billing only

Identity Access governs actual user permissions.

21\. Store Staff Viewer

For Stage 0B/0C, a lightweight store staff viewer may be needed.

Store Staff Viewer may:

view request board
view request detail
see critical warnings
confirm request if permitted
mark done if permitted

Store Staff Viewer must not automatically:

edit menu
change service plan
change billing
deactivate Entry Media
view all merchant stores
access HQ tools

Core rule:

Request board access must be narrow and store-scoped.

22\. Merchant Contact

Merchant contact may be separate from owner user.

Contact types:

primary\_contact
billing\_contact
field\_installation\_contact
support\_contact
emergency\_contact
AI\_menu\_review\_contact

Contact information should be used with privacy care.

Do not expose internal contact details unnecessarily.

23\. Store Address And Placement Context

Store address supports:

field installation
Entry Plate recovery
support
merchant ops follow-up
service availability
local time/business hours

Entry Media placement is not the same as store address.

Placement belongs to Entry Media assignment.

Example:

store\_address \= Sadang-dong, Seoul
entry\_media\_placement \= INSIDE\_STORE\_GUIDE

24\. Business Hours

Business hours may be used by Stage 0/1 and Merchant Ops.

MVP may store basic hours.

Future use:

request availability
business date close
confirmed auto-completion
close auto-completion
support expectation
trial usage interpretation

Business hours should be store-level.

25\. Service Plan Relationship

Merchant Account or Store may have service plan.

Possible plan levels:

account-level plan
store-level plan
trial plan
pilot plan
custom plan

MVP may keep simple:

service\_plan \= TRIAL
service\_plan \= BASIC
service\_plan \= PAID

Billing details can be deferred.

Core rule:

Plan affects feature availability.
Plan does not replace service status.

26\. Entry Media Relationship

Entry Media assignment should reference merchant store context.

Example:

entry\_media\_id
→ merchant\_store\_id
→ menu\_context\_id
→ enabled\_stage

Entry Media Inventory owns QR/NFC asset lifecycle.

Merchant Store owns operating context.

Core separation:

Merchant Store says where service operates.
Entry Media Inventory says which QR/NFC points there.

27\. Stage Runtime Relationship

Stage 0 and Stage 1 should reference merchant store context.

Stage runtime needs:

merchant\_store\_id
merchant\_account\_id
service\_status
enabled\_stage
menu\_context\_id
owner\_console\_availability
support\_route

Stage runtime should not own merchant organization.

Core rule:

Runtime uses merchant store context.
Organization Core owns merchant store context.

28\. Owner Console Relationship

Owner Console is merchant-facing.

Owner Console should use:

merchant\_account
merchant\_store
store users
service status
trial status
menu context
request board context
usage summary
support access

Owner Console should not expose internal operator/team structure unless necessary.

29\. Merchant Ops Relationship

Merchant Ops uses merchant context for:

trial onboarding
store setup
owner account setup
Entry Plate installation coordination
usage follow-up
conversion support
service suspension
termination
recovery
support escalation

Merchant Ops may assign internal responsibility to merchant accounts or stores.

30\. CatchMenu HQ Relationship

CatchMenu HQ may manage:

merchant account creation
merchant company reference
merchant store creation
service status
trial status
cross-business links
high-risk changes
operator assignment
audit review

HQ must respect Identity Access.

31\. Cross-Business Link To Franchise OS

If a merchant store is linked to Franchise OS, the link must be explicit.

Suggested fields:

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

Example:

source\_system \= Franchise OS
source\_entity\_type \= store
source\_entity\_id \= franchise\_store\_001
target\_system \= CatchMenu
target\_entity\_type \= merchant\_store
target\_entity\_id \= cm\_store\_001
relationship\_type \= YOONSUL\_AFFILIATED\_STORE

Core rule:

Cross-business link is reference.
Cross-business link is not permission.

32\. Merchant Record Deletion Policy

Merchant account and store records should not be hard-deleted by default.

Use statuses:

SUSPENDED
TERMINATED
CLOSED
ARCHIVED

Preserve:

service history
Entry Media assignment history
request history
support history
audit history
cross-business link history

Core rule:

Close or archive merchant context.
Do not erase operational memory.

33\. Merchant Context Audit

Important merchant context changes must create audit events.

Events may include:

MERCHANT\_ACCOUNT\_CREATED
MERCHANT\_ACCOUNT\_UPDATED
MERCHANT\_COMPANY\_CREATED
MERCHANT\_STORE\_CREATED
MERCHANT\_STORE\_UPDATED
MERCHANT\_SERVICE\_STATUS\_CHANGED
MERCHANT\_TRIAL\_STATUS\_CHANGED
MERCHANT\_STORE\_STAGE\_ENABLED
MERCHANT\_STORE\_MENU\_CONTEXT\_LINKED
MERCHANT\_CROSS\_BUSINESS\_LINK\_CREATED
MERCHANT\_ACCOUNT\_ARCHIVED

Audit fields:

event\_id
merchant\_account\_id
merchant\_company\_id
merchant\_store\_id
actor\_type
actor\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

34\. Failure Events

Invalid merchant context actions should create failure events.

Examples:

create store without merchant account
enable Stage 0 without menu context
activate service without store context
link Franchise OS store without explicit relationship type
grant store access without scope
terminate merchant without service status event

Example failure codes:

WOH.ORG.MERCHANT.STORE.CREATE.ACCOUNT\_REQUIRED
WOH.ORG.MERCHANT.STORE.STAGE\_ENABLE.MENU\_CONTEXT\_REQUIRED
WOH.ORG.MERCHANT.SERVICE.ACTIVATE.STORE\_CONTEXT\_REQUIRED
WOH.ORG.MERCHANT.CROSS\_LINK.RELATIONSHIP\_TYPE\_REQUIRED
WOH.ORG.MERCHANT.ACCESS.STORE\_SCOPE\_REQUIRED
WOH.ORG.MERCHANT.TERMINATE.STATUS\_EVENT\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

35\. Support Signals

Support signals may include:

MERCHANT\_STORE\_CONTEXT\_MISSING
MERCHANT\_MENU\_CONTEXT\_MISSING
MERCHANT\_SERVICE\_STATUS\_CONFLICT
MERCHANT\_TRIAL\_EXPIRED\_BUT\_ACTIVE
MERCHANT\_OWNER\_ACCESS\_MISSING
MERCHANT\_STORE\_STAGE\_CONFIG\_MISSING
CROSS\_BUSINESS\_LINK\_CONFLICT
MERCHANT\_STORE\_IDENTITY\_CONFLICT

Support Signal alerts.

It does not mutate merchant context by itself.

36\. MVP Requirements

MVP should support at least:

merchant\_account
merchant\_store
trial\_status
service\_status
enabled\_stage
menu\_context reference
primary owner reference
primary contact
store users reference
Entry Media assignment reference
basic audit event
basic support signal

MVP may defer:

complex merchant company hierarchy
multi-legal-entity billing
advanced contract lifecycle
deep CRM
complex franchise group mapping
multi-country merchant structure

37\. Suggested Conceptual Entities

Suggested entities:

merchant\_accounts
merchant\_companies
merchant\_stores
merchant\_store\_status\_events
merchant\_contacts
merchant\_store\_users
merchant\_service\_plans
cross\_business\_links

This document defines policy.

Actual schema may be designed later.

38\. Risk If Skipped

If merchant account, company, and store context are not separated, risks include:

single-store MVP cannot scale to multi-store merchants
external restaurants may mix with Franchise OS stores
Owner Console access becomes too broad
Entry Media mapping points to unclear store context
Stage 1 cannot know which merchant/store owns handoff
support cannot route issues correctly
billing and trial status become unclear
cross-business links become unsafe

Therefore, merchant context must be modeled before deeper runtime stages.

39\. Final Rule

CatchMenu merchant context must support both lightweight trial and future SaaS scale.

Final rule:

Create Merchant Account as customer relationship.
Create Merchant Store as runtime location.
Use Merchant Company when business/legal grouping is needed.
Track trial and service status.
Scope owner access to account/store.
Link Entry Media to store context.
Link Franchise OS only explicitly.
Preserve merchant history.
Do not collapse merchant, company, and store into one concept.
