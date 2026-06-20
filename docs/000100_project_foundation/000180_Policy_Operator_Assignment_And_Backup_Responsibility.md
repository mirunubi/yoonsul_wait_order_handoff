# 000180_Policy_Operator_Assignment_And_Backup_Responsibility.md

## Purpose

This document defines the project foundation topic indicated by its filename and preserves its governed documentation role within `docs/000100_project_foundation/`.


Legacy path: $old.

1\. Purpose

This document defines the operator assignment and backup responsibility policy for CatchMenu / Wait Order Handoff.

CatchMenu may operate as a separate SaaS company, business unit, or operating division.

Because CatchMenu manages trial merchants, production merchants, Entry Media inventory, Owner Console support, AI menu review, and Stage runtime support, each operational responsibility must have a clear owner and backup path.

Core purpose:

Assign responsible operators to merchant, store, asset, support, and review contexts.
Define primary and backup responsibility.
Prevent orphaned merchants, unresolved support cases, and forgotten recovery tasks.
Separate responsibility from permission.
Ensure backup actions are scoped, logged, and reviewable.

Korean purpose:

고객사, 매장, 자산, 지원, 검수 컨텍스트에 담당 운영자를 배정한다.
주 담당자와 백업 책임을 정의한다.
담당자 없는 고객사, 미해결 지원 건, 잊힌 회수 작업을 방지한다.
책임과 권한을 분리한다.
백업 조치는 범위 제한, 기록, 검토 가능성을 갖도록 한다.

2\. Scope

This document covers:

operator assignment
primary owner
backup owner
merchant responsibility
store responsibility
Entry Media responsibility
support case responsibility
AI menu review responsibility
field recovery responsibility
handoff between operators
backup activation
temporary delegation
escalation ownership
audit event
failure event
support signal

This document does not define:

login authentication
role permission matrix
full HR attendance
payroll
employee contracts
shift scheduling
Franchise OS HR
field visit SOP
Stage 0 request state machine
Entry Media asset lifecycle details

Related documents:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00520\_Internal\_Team\_Role\_And\_Responsibility\_Policy.md
00530\_Merchant\_Account\_Company\_And\_Store\_Context\_Policy.md
00400\_identity\_access/
02600\_merchant\_ops/
03000\_catchmenu\_hq/
00300\_entry\_media\_inventory/

3\. Core Principle

Every active operational object should have an accountable owner when human follow-up is required.

Core rule:

Responsibility assigns accountability.
Permission authorizes system action.
Backup preserves continuity.

Korean rule:

책임 배정은 accountability를 만든다.
권한은 시스템 행동을 허가한다.
백업은 업무 연속성을 보장한다.

A responsible operator may not have permission to perform every action.

A backup operator must not become a permanent hidden owner.

4\. Operator Definition

Operator means an internal CatchMenu worker or authorized internal actor responsible for operating part of the SaaS service.

Examples:

HQ Admin
Merchant Ops Operator
Support Operator
Field Operator
Inventory Operator
AI Menu Reviewer
Sales/Ops Manager
Finance/Billing Operator
Engineering Operator
Audit Reviewer

An operator may be a person, a team queue, or a system-assigned responsibility placeholder.

MVP may use person-level or team-level assignment.

5\. Assignment Target Types

Operator assignment may apply to:

merchant\_account
merchant\_store
trial\_onboarding
field\_installation
Entry Plate recovery
Entry Media inventory inspection
support case
AI menu intake review
billing issue
service suspension
service termination
Stage runtime incident
cross-business link review

Suggested target types:

MERCHANT\_ACCOUNT
MERCHANT\_STORE
TRIAL\_CASE
FIELD\_TASK
ENTRY\_MEDIA\_ASSET
ENTRY\_MEDIA\_RECOVERY
SUPPORT\_CASE
AI\_MENU\_REVIEW
BILLING\_CASE
SERVICE\_STATUS\_CASE
RUNTIME\_INCIDENT
CROSS\_BUSINESS\_REVIEW

6\. Responsibility Types

Suggested responsibility types:

merchant\_onboarding\_owner
trial\_followup\_owner
conversion\_owner
field\_installation\_owner
entry\_media\_recovery\_owner
entry\_media\_inventory\_owner
support\_case\_owner
AI\_menu\_review\_owner
billing\_owner
service\_suspension\_owner
termination\_owner
runtime\_incident\_owner
HQ\_escalation\_owner
backup\_owner

Responsibility type must be explicit.

Core rule:

Do not assign a vague owner when a specific responsibility type is needed.

7\. Primary Owner

Primary owner is responsible for normal handling.

Examples:

Merchant Ops primary owner handles trial follow-up.
Field Ops primary owner handles installation visit.
Support primary owner handles merchant issue.
Inventory primary owner handles recovered plate inspection.
AI Review primary owner handles menu draft review.

Primary owner should be visible to relevant internal consoles.

Primary owner status should be auditable.

8\. Backup Owner

Backup owner acts when primary owner is unavailable, delayed, or escalated.

Backup owner may be:

specific operator
team lead
team queue
HQ escalation owner

Backup responsibility must be explicit.

Core rule:

Backup authority must be scoped.
Backup authority must not silently become permanent authority.

9\. Backup Activation Reasons

Backup may be activated for reasons such as:

primary operator unavailable
primary operator on leave
urgent merchant issue
critical support signal
missed deadline
after-hours coverage
service termination deadline
Entry Media recovery overdue
wrong mapping incident
security review

Backup activation must include reason.

Suggested reasons:

PRIMARY\_UNAVAILABLE
TIME\_SENSITIVE\_ACTION
ESCALATION\_REQUIRED
AFTER\_HOURS\_COVERAGE
RECOVERY\_OVERDUE
CRITICAL\_SUPPORT\_SIGNAL
SECURITY\_REVIEW
HQ\_OVERRIDE\_REQUIRED

10\. Backup Scope

Backup scope should be limited.

Scope may include:

target merchant only
target store only
target support case only
target Entry Media asset only
specific action type
specific time window
specific escalation reason

Core rule:

Backup scope must be narrower than normal permanent role whenever possible.

11\. Backup Time Limit

Backup activation should have a time limit.

Suggested fields:

backup\_started\_at
backup\_expires\_at
activated\_by
activation\_reason
scope

Default backup should not remain open indefinitely.

If longer responsibility is needed, transfer ownership instead.

12\. Responsibility Transfer

Responsibility transfer is different from backup activation.

Backup means temporary continuity.

Transfer means primary ownership changes.

Transfer should record:

previous\_owner
new\_owner
transfer\_reason
transferred\_by
transferred\_at
target\_type
target\_id
trace\_id

Core rule:

Temporary backup should not be used when permanent transfer is required.

13\. Assignment Record

Recommended responsibility assignment fields:

responsibility\_id
target\_type
target\_id
responsibility\_type
primary\_operator\_id
primary\_team\_id
backup\_operator\_id
backup\_team\_id
assignment\_status
assigned\_by
assigned\_at
effective\_from
effective\_until
reason
trace\_id

Assignment may reference a team if no specific operator is known yet.

However, high-risk cases should have a named owner.

14\. Assignment Status

Suggested statuses:

ASSIGNED
ACTIVE
WAITING\_ON\_MERCHANT
WAITING\_ON\_INTERNAL\_TEAM
BACKUP\_ACTIVE
ESCALATED
TRANSFER\_REQUESTED
TRANSFERRED
COMPLETED
CANCELLED
EXPIRED

Status meaning:

ASSIGNED
\= responsibility assigned but not yet active

ACTIVE
\= primary owner is handling

WAITING\_ON\_MERCHANT
\= merchant response required

WAITING\_ON\_INTERNAL\_TEAM
\= another internal team action required

BACKUP\_ACTIVE
\= backup owner currently handling

ESCALATED
\= higher-level review required

TRANSFER\_REQUESTED
\= ownership transfer requested

TRANSFERRED
\= ownership moved to another operator/team

COMPLETED
\= responsibility completed

CANCELLED
\= responsibility no longer required

EXPIRED
\= time-scoped assignment expired

15\. Merchant Onboarding Assignment

Trial merchant onboarding should have a primary owner.

Recommended assignment:

target\_type \= MERCHANT\_ACCOUNT or MERCHANT\_STORE
responsibility\_type \= merchant\_onboarding\_owner
primary\_team \= Merchant Ops
backup\_team \= Merchant Ops Lead or HQ Admin

Onboarding owner handles:

merchant setup
trial readiness
owner account coordination
menu readiness coordination
Entry Plate installation request

16\. Trial Follow-Up Assignment

Trial follow-up should have clear owner.

Responsibilities:

usage check
merchant feedback
trial extension discussion
conversion discussion
non-use follow-up
recovery recommendation

Trial follow-up owner should not automatically deactivate Entry Media or suspend admin access.

Those actions require proper authority.

17\. Field Installation Assignment

Field installation assignment should identify who physically installs Entry Plate.

Responsibilities:

visit merchant
install plate
test NFC
test QR
confirm placement
collect field evidence
report installation complete

Field operator may update field task status.

Mapping activation should follow authorized Entry Media process.

Core rule:

Field installation does not equal mapping authority unless explicitly granted.

18\. Entry Media Recovery Assignment

Entry Media recovery assignment should identify who is responsible for collecting the plate.

Responsibilities:

contact merchant
schedule recovery
physically recover plate
record condition
return plate to inventory
flag damaged/lost if needed

Recovery owner should not delete mapping history.

If service is terminated, mapping deactivation must follow Entry Media policy.

19\. Inventory Inspection Assignment

Recovered Entry Plate may need inspection.

Inventory inspection owner handles:

NFC scan test
QR scan test
physical condition check
old store text check
damage classification
reallocation readiness recommendation
retirement recommendation

Inventory owner may mark inspection result only if authorized.

20\. Support Case Assignment

Support case should have an owner.

Support owner handles:

merchant issue review
support signal triage
evidence packet review
merchant communication
handoff to Engineering or HQ if needed

Support owner must respect masking and support access policy.

Support owner does not automatically have mutation authority.

Core rule:

Support ownership is case accountability.
It is not unrestricted system authority.

21\. AI Menu Review Assignment

AI menu review owner handles AI-generated menu draft review.

Responsibilities:

photo/OCR result review
menu name correction
price extraction check
category correction
option structure check
critical warning candidate review
translation draft review
merchant confirmation routing

AI reviewer should not silently publish high-risk menu changes without approval policy.

22\. Billing Assignment

Billing owner handles plan or billing-related merchant issues.

Responsibilities:

trial-to-paid status check
invoice reference
billing contact coordination
payment status support
billing-related suspension request if policy allows

Billing owner must not delete operational history.

Billing-related suspension must be event-backed.

23\. Runtime Incident Assignment

Runtime incident owner handles technical or operational incidents.

Examples:

Entry Media resolution failed
wrong store mapping
owner console unavailable
request send failure
unconfirmed request spike
Stage 0 state transition denied

Runtime incident may require Support, Engineering, HQ, or Inventory involvement.

Responsibility assignment should clarify primary owner.

24\. Cross-Business Review Assignment

If a CatchMenu merchant/store links to Franchise OS, cross-business review may be required.

Owner should verify:

relationship type
store identity
authority boundary
data sharing boundary
support visibility
audit requirement

Cross-business review must not grant authority by link alone.

Core rule:

Cross-business link is reference.
Access still requires explicit role and scope.

25\. Escalation Owner

Escalation owner is responsible for high-risk or blocked cases.

Escalation may be required for:

wrong store mapping
lost active plate
service termination dispute
critical allergy warning issue
support evidence conflict
admin access mismatch
cross-business authority dispute
security concern

Escalation owner should have decision path and deadline if possible.

26\. Responsibility Handoff

Responsibility handoff occurs when work moves between teams.

Examples:

Sales Ops → Merchant Ops
Merchant Ops → Field Ops
Field Ops → Inventory Ops
Support → Engineering Ops
Support → HQ Admin
AI Menu Review → Merchant Ops
Billing Ops → HQ Admin

Handoff record should include:

from\_operator\_id
to\_operator\_id
from\_team\_id
to\_team\_id
handoff\_reason
target\_type
target\_id
current\_status
required\_action
created\_at
trace\_id

Core rule:

Handoff transfers work.
Handoff must not erase previous accountability.

27\. Orphaned Responsibility Detection

The system should detect orphaned work.

Examples:

trial merchant has no onboarding owner
trial active but no follow-up owner
recovery requested but no recovery owner
support case open but no support owner
AI menu draft pending but no reviewer
billing issue open but no billing owner
escalation required but no escalation owner

Support signal examples:

ORG.RESPONSIBILITY.ORPHANED\_TRIAL
ORG.RESPONSIBILITY.ORPHANED\_RECOVERY
ORG.RESPONSIBILITY.ORPHANED\_SUPPORT\_CASE
ORG.RESPONSIBILITY.ORPHANED\_AI\_REVIEW

28\. Overdue Responsibility Detection

The system may detect overdue responsibility.

Examples:

trial follow-up overdue
field installation overdue
plate recovery overdue
support response overdue
AI menu review overdue
billing issue overdue

Overdue signal should alert responsible team.

It should not automatically mutate merchant or asset state unless explicit policy allows.

29\. Sensitive Responsibility

Sensitive responsibilities include:

admin access suspension
service termination
Entry Media forced deactivation
mapping correction
lost active asset handling
retired asset reactivation review
AI critical warning override
cross-business link approval
support evidence unmasking

Sensitive responsibility requires:

authorized role
reason
audit event
possibly reauthentication
possibly HQ review

30\. Reauthentication For Backup Sensitive Actions

If backup owner performs sensitive action, reauthentication should be required when practical.

Examples:

backup deactivates Entry Media mapping
backup suspends admin access
backup approves service termination
backup views unmasked support evidence
backup corrects wrong store mapping

Core rule:

Backup sensitive action requires stronger proof and audit.

31\. Audit Events

Recommended audit events:

RESPONSIBILITY\_ASSIGNED
RESPONSIBILITY\_ACTIVATED
RESPONSIBILITY\_BACKUP\_ASSIGNED
RESPONSIBILITY\_BACKUP\_ACTIVATED
RESPONSIBILITY\_BACKUP\_EXPIRED
RESPONSIBILITY\_TRANSFER\_REQUESTED
RESPONSIBILITY\_TRANSFERRED
RESPONSIBILITY\_ESCALATED
RESPONSIBILITY\_COMPLETED
RESPONSIBILITY\_CANCELLED
RESPONSIBILITY\_OVERDUE\_SIGNAL\_CREATED

Audit event fields:

event\_id
responsibility\_id
target\_type
target\_id
responsibility\_type
previous\_owner
new\_owner
backup\_owner
actor\_type
actor\_id
reason
created\_at
trace\_id

32\. Failure Events

Invalid responsibility actions should create failure events.

Examples:

assign disabled operator
assign backup without reason
activate backup without scope
transfer without target owner
complete responsibility with unresolved required action
assign sensitive responsibility without authority
extend backup indefinitely without review

Example failure codes:

WOH.ORG.OPERATOR\_ASSIGNMENT.DISABLED\_OPERATOR\_DENIED
WOH.ORG.OPERATOR\_ASSIGNMENT.BACKUP\_REASON\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.BACKUP\_SCOPE\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.TRANSFER\_TARGET\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.COMPLETE.UNRESOLVED\_ACTION\_EXISTS
WOH.ORG.OPERATOR\_ASSIGNMENT.SENSITIVE.AUTHORITY\_REQUIRED
WOH.ORG.OPERATOR\_ASSIGNMENT.BACKUP\_EXTENSION.REVIEW\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

33\. Support Signals

Support signals may include:

RESPONSIBILITY\_ORPHANED
RESPONSIBILITY\_OVERDUE
BACKUP\_ACTIVATED
BACKUP\_EXPIRING
SENSITIVE\_RESPONSIBILITY\_ASSIGNED
ESCALATION\_OWNER\_MISSING
RECOVERY\_OWNER\_MISSING
AI\_REVIEW\_OWNER\_MISSING
SUPPORT\_CASE\_OWNER\_MISSING

Support Signal does not change ownership by itself.

It alerts appropriate team or HQ.

34\. Evidence Packet Relationship

Evidence Packet may include responsibility timeline when relevant.

Example evidence fields:

primary\_owner
backup\_owner
assignment\_history
handoff\_history
escalation\_history
backup\_activation\_reason
sensitive\_action\_actor
responsibility\_status
overdue\_signal\_ref

This helps explain who was responsible at each point.

Core rule:

Evidence should show responsibility timeline when accountability matters.

35\. Relationship To Identity Access

Identity Access governs:

who can assign responsibility
who can activate backup
who can perform sensitive action
who can view support evidence
who can reassign cases

Organization Core governs:

who is responsible
who is backup
which team owns the work
which handoff happened

Core separation:

Responsibility does not grant authority by itself.
Authority must come from Identity Access.

36\. Relationship To CatchMenu HQ

CatchMenu HQ should provide administrative visibility for:

operator assignments
backup assignments
orphaned responsibilities
overdue responsibilities
escalations
sensitive responsibility changes

HQ may intervene when responsibility is missing or stalled.

HQ intervention must be audited.

37\. Relationship To Merchant Ops

Merchant Ops uses this policy for:

trial onboarding ownership
usage follow-up
conversion discussion
service suspension coordination
field task request
termination coordination

Merchant Ops may create handoffs to Field Ops, Support, AI Review, or HQ.

38\. Relationship To Entry Media Inventory

Entry Media Inventory may create responsibility needs for:

plate assignment
installation
recovery
inspection
reallocation
lost/damaged review
wrong mapping incident

Entry Media responsibility should link to asset IDs and mapping IDs.

39\. Relationship To AI Menu Intake

AI Menu Intake may create responsibility needs for:

draft extraction review
critical warning review
translation review
merchant confirmation
menu publish approval

AI review responsibility must be assigned before risky menu data becomes live.

40\. MVP Requirements

MVP should support at least:

operator record
team reference
responsibility assignment
primary owner
backup owner
responsibility status
basic handoff
basic escalation
orphaned responsibility signal
overdue responsibility signal
audit event
failure event

MVP may defer:

advanced workload balancing
operator calendar
SLA automation
shift scheduling
attendance
payroll
route planning
complex delegation workflow

41\. Suggested Conceptual Entities

Suggested entities:

operators
operator\_assignments
responsibility\_assignments
responsibility\_events
backup\_activations
responsibility\_handoffs
responsibility\_escalations
responsibility\_support\_signals

This document defines policy.

Actual schema may be designed later.

42\. Risk If Skipped

If operator assignment and backup responsibility are skipped, risks include:

trial merchants are forgotten
Entry Plates are not recovered
support cases remain unresolved
AI menu drafts are published without review
wrong mapping incidents have no owner
backup actions happen without trace
HQ cannot see who is responsible
service termination is mishandled

Therefore, assignment and backup responsibility must exist before scaling merchant operations.

43\. Final Rule

CatchMenu must know who owns each operational responsibility and who can act as backup.

Final rule:

Assign a primary owner.
Assign backup when needed.
Scope backup authority.
Record handoff.
Escalate high-risk cases.
Detect orphaned work.
Detect overdue work.
Audit sensitive responsibility changes.
Never confuse responsibility with permission.
