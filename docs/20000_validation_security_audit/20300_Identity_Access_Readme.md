00400 Identity Access Readme

Legacy path: $old.

1\. Purpose

This folder defines the Identity Access foundation for CatchMenu / Wait Order Handoff.

CatchMenu may operate as a separate SaaS company, business unit, operating division, or future legal entity.

Therefore, CatchMenu needs its own lightweight but strict identity, role, permission, scope, support access, and admin action governance.

This is not the full Franchise OS HR module.

Core purpose:

Define CatchMenu user identity.
Define login and account boundary.
Define merchant user access.
Define store-scoped access.
Define CatchMenu HQ admin access.
Define support access and masking.
Define sensitive action reauthentication.
Define admin action audit.
Prevent Franchise OS authority from leaking into CatchMenu.

Korean purpose:

CatchMenu 사용자 identity를 정의한다.
로그인과 계정 경계를 정의한다.
고객사 사용자 접근을 정의한다.
매장 단위 접근 범위를 정의한다.
CatchMenu HQ 관리자 접근을 정의한다.
지원 접근과 마스킹을 정의한다.
민감 작업 재인증을 정의한다.
관리자 행동 감사를 정의한다.
Franchise OS 권한이 CatchMenu로 새어 들어오지 않게 한다.

2\. Scope

This folder covers:

user account
login identity
merchant owner access
store manager access
store staff viewer access
CatchMenu HQ admin access
support operator access
field operator access
inventory operator access
AI menu reviewer access
role permission
scope boundary
sensitive action reauthentication
support masking
admin action audit
access suspension
access revocation
backup authority
cross-business access denial

This folder does not define:

attendance
payroll
shift scheduling
employee contract
employee document management
full HR lifecycle
Franchise OS employee management
merchant billing engine
Stage 0 request state machine
Entry Media physical lifecycle

Those belong to other modules.

3\. Core Principle

Identity Access defines authority.

Organization Core defines structure.

Core rule:

Organization Core says who exists and where they belong.
Identity Access says what they are allowed to do.

Korean rule:

Organization Core는 누가 존재하고 어디에 속하는지를 정의한다.
Identity Access는 그 사용자가 무엇을 할 수 있는지를 정의한다.

A user may belong to a merchant account or internal team, but that does not automatically grant every permission.

4\. Relationship To Organization Core

Organization Core provides:

CatchMenu company
business unit
internal team
operator
merchant account
merchant store
responsibility assignment
backup responsibility
cross-business link

Identity Access consumes those structures and defines:

login
role
permission
scope
support access
admin access
sensitive action
audit requirement

Core separation:

Structure is not authority.
Responsibility is not permission.
Link is not access.

5\. Relationship To Franchise OS

CatchMenu and Franchise OS may belong to the same broader Yoonsul group.

However, access must be separated by default.

Default rule:

Franchise OS user does not receive CatchMenu access by default.
CatchMenu user does not receive Franchise OS access by default.
Franchise OS role does not become CatchMenu role by name similarity.
CatchMenu role does not become Franchise OS role by name similarity.

Cross-business access requires explicit federation or assignment.

6\. User Categories

CatchMenu should recognize these user categories:

MERCHANT\_OWNER
STORE\_MANAGER
STORE\_STAFF\_VIEWER
REQUEST\_BOARD\_VIEWER
MENU\_EDITOR
BILLING\_CONTACT

HQ\_ADMIN
HQ\_MANAGER
SUPPORT\_OPERATOR
FIELD\_OPERATOR
INVENTORY\_OPERATOR
AI\_MENU\_REVIEWER
SALES\_OPERATOR
FINANCE\_OPERATOR
ENGINEERING\_OPERATOR
AUDIT\_REVIEWER

SYSTEM\_JOB
PUBLIC\_GUEST

MVP may start with fewer categories.

Minimum MVP categories:

MERCHANT\_OWNER
STORE\_MANAGER
STORE\_STAFF\_VIEWER
HQ\_ADMIN
SUPPORT\_OPERATOR
FIELD\_OPERATOR
INVENTORY\_OPERATOR
AI\_MENU\_REVIEWER
SYSTEM\_JOB
PUBLIC\_GUEST

7\. Public Guest Identity

Public Guest is a lightweight, unauthenticated or session-based actor.

Public Guest may:

scan QR/NFC
open guest menu
choose language
view menu
select items
show selection to staff
send request if Stage 0B/0C is enabled
view request status if session allows

Public Guest must not:

access Owner Console
access CatchMenu HQ
edit menu
confirm request as store
mark done
view support evidence
view merchant internal data
change service status
access Entry Media inventory

Core rule:

Guest scan opens guest flow.
Guest scan does not grant admin authority.

8\. Merchant User Identity

Merchant users are users belonging to a merchant account or merchant store.

Merchant user types may include:

Merchant Owner
Store Manager
Store Staff Viewer
Request Board Viewer
Menu Editor
Billing Contact

Merchant users must be scoped to:

merchant\_account
merchant\_store
feature area
role
status

Core rule:

Merchant user access must be merchant-scoped and store-scoped.

9\. Merchant Owner

Merchant Owner is the highest merchant-side user.

Merchant Owner may be allowed to:

view merchant account
view store list
manage store users if enabled
view service status
view trial status
view usage summary
edit menu or approve menu draft if policy allows
view request board
contact support

Merchant Owner must not automatically:

access CatchMenu HQ
access other merchants
deactivate Entry Media globally
view internal support notes without permission
override audit
change platform settings
access Franchise OS data

10\. Store Manager

Store Manager is scoped to one or more merchant stores.

Store Manager may be allowed to:

view store dashboard
view request board
confirm request if enabled
mark done if enabled
view menu
edit store menu if granted
view store trial status
view store usage summary
contact support

Store Manager must not automatically:

manage all merchant account stores
change billing
change service plan
invite HQ users
change Entry Media inventory status
access other merchants
access CatchMenu HQ

11\. Store Staff Viewer

Store Staff Viewer is a narrow role for daily store use.

Store Staff Viewer may be allowed to:

open request board
view request detail
view selected items
view critical warnings
confirm request if granted
mark done if granted

Store Staff Viewer should not automatically:

edit menu
change store settings
change owner access
change service status
view billing
view support evidence beyond request detail
access HQ tools

Core rule:

Store Staff Viewer should be narrow, store-scoped, and operational.

12\. Request Board Viewer

Request Board Viewer is an even narrower role if needed.

Allowed:

view request board
view request detail
view request state

Optional if granted:

confirm request
mark done

Not allowed:

edit menu
change service status
change users
view billing
view HQ data

This role is useful for POS-less Stage 0C operation.

13\. Menu Editor

Menu Editor may manage menu context if granted.

Allowed:

edit menu item
edit category
edit price
edit option
review AI menu draft
submit menu for approval

High-risk changes may require review:

allergy warning
critical dietary label
translation-sensitive item
price bulk change
menu publish

Core rule:

Menu edit authority should be separated from request board authority when possible.

14\. CatchMenu HQ Admin

CatchMenu HQ Admin is an internal platform admin role.

HQ Admin may be allowed to:

create merchant account
create merchant store
approve trial
change service status
assign operators
review high-risk support signal
manage Entry Media policy-level action
review cross-business link
manage platform configuration
view audit events

HQ Admin must still follow:

scope
reason requirement
sensitive action reauthentication
audit logging
least privilege

Core rule:

HQ Admin is powerful but not unbounded.

15\. HQ Manager

HQ Manager may supervise operations but may have narrower authority than HQ Admin.

Allowed examples:

view merchant portfolio
view trial status
view operator assignment
review escalations
approve non-sensitive workflow
coordinate teams

Not automatically allowed:

system configuration
security settings
cross-business authority approval
hard suspension
unmasked evidence access

16\. Support Operator

Support Operator handles merchant support and issue triage.

Support Operator may be allowed to:

view assigned support cases
view masked evidence packet
view request timeline
view Entry Media resolution status
view merchant contact if needed
create support note
escalate to HQ or Engineering

Support Operator must not automatically:

edit merchant menu
change service status
deactivate Entry Media
unmask sensitive data
access unrelated merchants
override runtime state
delete events

Core rule:

Support access is case-scoped, reason-scoped, masked, and audited.

17\. Field Operator

Field Operator handles physical site work.

Allowed examples:

view assigned field task
view store address needed for visit
record installation result
record QR/NFC scan test
record recovery result
record physical condition
upload field note

Not automatically allowed:

change service status
change mapping authority
delete Entry Media history
view all merchants
access support evidence unrelated to field task

Core rule:

Field Operator handles physical work.
System authority remains scoped.

18\. Inventory Operator

Inventory Operator handles Entry Media and Entry Plate stock control.

Allowed examples:

register Entry Plate
view inventory stock
mark inspection result
mark damaged
mark lost candidate
mark recovered
mark reallocation readiness if authorized

Not automatically allowed:

activate merchant service
approve paid conversion
view merchant billing
access all support cases
change menu

Core rule:

Inventory authority is asset-scoped.
It is not merchant business authority.

19\. AI Menu Reviewer

AI Menu Reviewer handles AI-generated menu drafts.

Allowed examples:

view menu intake draft
review OCR extraction
review item names
review prices
review categories
review option structure
review critical warning candidates
review translation draft
submit reviewed draft

Not automatically allowed:

publish menu live without approval if policy requires approval
change service status
access unrelated merchant operations
view billing
override merchant confirmation

Core rule:

AI reviewer validates drafts.
Live publication requires policy-defined authority.

20\. System Job

System Job represents automated internal process.

System Job may:

generate support signal
run trial expiration check
run unconfirmed request warning check
run cleanup candidate check
run usage aggregation
run scan usage aggregation
run audit consistency check

System Job must not:

silently grant human access
silently override sensitive state
delete audit history
cross business boundary without policy

Core rule:

Automation may signal and process.
Sensitive authority remains governed.

21\. Access Scopes

Access must be scoped.

Suggested scopes:

platform
company
business\_unit
team
operator
merchant\_account
merchant\_store
entry\_media
entry\_media\_mapping
menu\_context
request
support\_case
evidence\_packet
trial
service\_status
cross\_business\_link
audit
billing

Core rule:

Role without scope is unsafe.

22\. Scope Examples

Merchant Owner:

merchant\_account \= own account
merchant\_store \= own stores

Store Manager:

merchant\_account \= assigned account
merchant\_store \= assigned stores only

Support Operator:

support\_case \= assigned cases
merchant\_store \= case-related store only
evidence\_packet \= masked view only

Field Operator:

field\_task \= assigned tasks
entry\_media \= task-related asset only
merchant\_store \= task-related store only

HQ Admin:

platform \= allowed admin scope
merchant\_account \= as permitted
audit \= as permitted

23\. Permission Categories

Permissions may be grouped by action type:

read
create
update
approve
suspend
reactivate
assign
deactivate
recover
review
export
unmask
override
audit\_view

High-risk categories:

suspend
reactivate
deactivate
unmask
override
export
cross\_business\_link
service\_terminate
admin\_grant

High-risk permissions require stricter control.

24\. Sensitive Actions

Sensitive actions include:

grant HQ admin access
grant support access
unmask support evidence
change merchant service status
terminate merchant service
suspend owner access
reactivate owner access
deactivate Entry Media mapping
correct wrong store mapping
mark lost active Entry Plate
approve cross-business link
publish high-risk menu change
override critical warning
export audit or evidence data

Sensitive action may require:

reauthentication
reason
scope check
two-person review if needed
audit event
support signal if abnormal

25\. Reauthentication

Reauthentication should be required for high-risk actions when practical.

Examples:

admin grants another admin role
support operator unmasks evidence
HQ admin terminates service
inventory operator deactivates active mapping
AI reviewer overrides critical warning
operator approves cross-business link

Core rule:

Sensitive action should prove the actor again.

26\. Support Masking

Support access must be masked by default.

Support Operator should see:

case summary
request timeline
masked merchant contact if not needed
masked guest/session identity if not needed
technical state
failure code
support signal
evidence summary

Support Operator should not see by default:

unrelated merchant data
full personal data
billing details unless relevant
Franchise OS HR data
other store records
raw sensitive evidence

Core rule:

Support sees enough to help.
Support does not see everything.

27\. Admin Action Audit

Admin actions must create audit events.

Audit examples:

USER\_CREATED
USER\_INVITED
ROLE\_GRANTED
ROLE\_REVOKED
SCOPE\_CHANGED
SUPPORT\_ACCESS\_GRANTED
SUPPORT\_ACCESS\_EXPIRED
SENSITIVE\_ACTION\_REAUTHENTICATED
MERCHANT\_SERVICE\_STATUS\_CHANGED
OWNER\_ACCESS\_SUSPENDED
ENTRY\_MEDIA\_MAPPING\_DEACTIVATED
CROSS\_BUSINESS\_LINK\_APPROVED
EVIDENCE\_UNMASKED

Minimum audit fields:

event\_id
actor\_user\_id
actor\_role
target\_type
target\_id
action
scope
previous\_value
new\_value
reason
reauthenticated\_at
created\_at
trace\_id

Core rule:

No admin mutation without audit.

28\. Access Suspension

Access suspension disables future access.

It must not erase history.

Suspension may apply to:

merchant owner
store manager
store staff viewer
support operator
field operator
inventory operator
HQ admin

Suspension reasons:

trial expired
merchant terminated
operator left team
security concern
role no longer needed
temporary access expired
support session ended

Core rule:

Suspend access.
Do not delete access history.

29\. Access Revocation

Revocation is stronger than suspension.

Use revocation when:

user should no longer hold role
operator no longer belongs to company/team
merchant owner no longer valid
support access was temporary
security concern exists

Revocation must be audited.

Revocation should not delete past audit events.

30\. Temporary Access

Temporary access may be used for:

support session
backup responsibility
field task
AI review assignment
HQ escalation
cross-business review

Temporary access must have:

reason
scope
start time
expiry
actor who granted
audit event

Core rule:

Temporary access must expire.

31\. Backup Authority

Backup authority may be granted when a primary responsible operator is unavailable.

Backup authority must be:

explicit
time-scoped
reason-scoped
target-scoped
audited
limited to necessary action

Backup authority does not replace permanent role assignment.

Core rule:

Backup is continuity, not hidden permanent access.

32\. Cross-Business Access

Cross-business access is denied by default.

Examples:

Franchise OS HQ Admin cannot access CatchMenu HQ by default.
CatchMenu HQ Admin cannot access Franchise OS HR by default.
Franchise OS Store Manager cannot manage CatchMenu external merchant by default.
CatchMenu Support cannot view Franchise OS employee records by default.

Cross-business access requires:

explicit link
explicit role
explicit scope
reason
audit
possibly reauthentication

Core rule:

Cross-business link is not permission.

33\. Relationship To Owner Console

Owner Console uses Identity Access for:

merchant owner login
store manager login
store staff viewer access
menu edit authority
request board access
service status visibility
support request visibility

Owner Console must show only what the user is scoped to see.

34\. Relationship To Merchant Ops

Merchant Ops uses Identity Access for:

trial onboarding access
merchant follow-up access
field task assignment
Entry Plate recovery workflow
service suspension workflow
support escalation
operator assignment

Merchant Ops must not rely only on team membership.

Permission and scope are required.

35\. Relationship To CatchMenu HQ

CatchMenu HQ uses Identity Access for:

admin login
merchant management
operator management
service status control
Entry Media high-risk actions
cross-business link review
audit visibility
support evidence review

HQ must enforce sensitive action checks.

36\. Relationship To Entry Media Inventory

Entry Media Inventory uses Identity Access for:

register Entry Plate
assign Entry Media
deactivate mapping
mark recovered
mark lost
mark damaged
mark retired
approve reallocation
view scan usage

Inventory actions must be scoped and audited.

37\. Relationship To Stage Runtime

Stage runtime uses Identity Access differently by actor.

Public Guest:

session-based guest access
no admin authority

Store Staff:

request board scoped access
confirm/done authority if granted

Support:

case-scoped masked view

HQ:

admin oversight with audit

Core rule:

Runtime action must respect actor authority.

38\. Relationship To AI Menu Intake

AI Menu Intake uses Identity Access for:

upload menu image
view AI draft
review AI draft
edit extracted menu
approve draft
publish menu context
override critical warning

High-risk actions such as critical warning override require stronger control.

39\. MVP Requirements

Identity Access MVP should support at least:

user account
login identity
merchant owner role
store manager role
store staff viewer role
HQ admin role
support operator role
field operator role
inventory operator role
AI menu reviewer role
role-scope mapping
merchant\_account scope
merchant\_store scope
support case scope
basic audit event
access suspension
temporary support access
sensitive action reauthentication placeholder
cross-business access denial by default

MVP may defer:

full SSO
group-wide federation
multi-factor policy matrix
enterprise directory integration
advanced ABAC
complex delegated administration
full HR employee lifecycle

40\. Suggested Documents

This folder may include:

00400\_Identity\_Access\_Readme.md
00410\_User\_Account\_And\_Login\_Policy.md
00420\_Role\_Permission\_And\_Scope\_Policy.md
00430\_Merchant\_User\_And\_Store\_Access\_Policy.md
00440\_HQ\_Admin\_Access\_And\_Backup\_Policy.md
00450\_Support\_Access\_Masking\_And\_Evidence\_View\_Policy.md
00460\_Sensitive\_Action\_Reauthentication\_And\_Audit\_Policy.md
00470\_Cross\_Business\_Access\_And\_Federation\_Boundary\_Policy.md
00490\_Identity\_Access\_MVP\_Cutline.md
00499\_Identity\_Access\_Index\_And\_Readiness\_Check.md

41\. Suggested Conceptual Entities

Suggested entities:

users
user\_profiles
login\_identities
roles
permissions
role\_permissions
user\_role\_assignments
access\_scopes
merchant\_user\_access
store\_user\_access
hq\_admin\_access
support\_access\_sessions
temporary\_access\_grants
sensitive\_action\_challenges
admin\_action\_audit\_events
access\_status\_events

This document defines policy.

Actual schema may be designed later.

42\. Risk If Skipped

If Identity Access is skipped or too weak, risks include:

merchant owner sees another merchant
store staff edits menu by mistake
support sees too much data
HQ admin action has no audit
Franchise OS authority leaks into CatchMenu
cross-business link becomes permission
Entry Media is deactivated by wrong actor
service termination is done without trace
AI menu critical warning is overridden silently

Therefore, Identity Access is foundational before Owner Console, Merchant Ops, and CatchMenu HQ are fully designed.

43\. Final Rule

CatchMenu Identity Access must be small, strict, scoped, and auditable.

Final rule:

Define user identity.
Define roles.
Define scopes.
Deny cross-business access by default.
Mask support access.
Require reauthentication for sensitive actions.
Audit every admin mutation.
Separate responsibility from permission.
Do not import full Franchise OS HR.
Prepare Owner Console, Merchant Ops, CatchMenu HQ, Entry Media, and runtime on top.
