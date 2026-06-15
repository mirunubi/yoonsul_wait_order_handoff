# 00160_Policy_Internal_Team_Role_And_Responsibility

Legacy path: $old.

1\. Purpose

This document defines the internal team, role, and responsibility policy for CatchMenu / Wait Order Handoff.

CatchMenu may operate as a separate SaaS company, business unit, or operating division.

Because CatchMenu serves merchants, trial stores, Entry Media inventory, owner consoles, AI menu intake, support signals, and future handoff runtimes, internal responsibility must be clear.

Core purpose:

Define CatchMenu internal teams.
Separate team responsibility from system permission.
Assign operational ownership for merchant onboarding, support, field operations, inventory, AI review, billing, and platform administration.
Prepare Identity Access and CatchMenu HQ governance.

Korean purpose:

CatchMenu 내부 팀을 정의한다.
팀 책임과 시스템 권한을 분리한다.
고객사 온보딩, 지원, 현장 운영, 재고, AI 검수, 과금, 플랫폼 관리의 운영 책임을 배정한다.
Identity Access와 CatchMenu HQ 거버넌스를 준비한다.

2\. Scope

This document covers:

internal teams
business unit responsibility
operator responsibility
team role definitions
responsibility assignment
primary owner
backup owner
handoff between teams
escalation ownership
support ownership
field ownership
inventory ownership
AI menu review ownership
billing ownership
platform admin ownership

This document does not define:

login authentication
permission matrix
payroll
attendance
shift scheduling
labor contract
Franchise OS HR
merchant-facing owner console details
Stage 0 request runtime
Entry Media physical SOP

Related documents:

00500\_Organization\_Core\_Readme.md
00510\_CatchMenu\_Company\_Business\_Unit\_And\_Legal\_Entity\_Policy.md
00400\_identity\_access/
02400\_owner\_console/
02600\_merchant\_ops/
03000\_catchmenu\_hq/
00300\_entry\_media\_inventory/

3\. Core Principle

Responsibility is not the same as permission.

Core rule:

Team responsibility defines who is accountable.
Identity Access defines what a user may do in the system.

Korean rule:

팀 책임은 누가 책임지는지를 정의한다.
Identity Access는 사용자가 시스템에서 무엇을 할 수 있는지를 정의한다.

A person may be responsible for a merchant but still need permission to perform a sensitive action.

4\. Internal Team Model

CatchMenu should have explicit internal teams.

Suggested teams:

HQ Admin
Merchant Operations
Support Operations
Field Operations
Inventory Operations
AI Menu Review
Sales Operations
Finance/Billing Operations
Product Operations
Engineering Operations
Audit/Compliance Review

MVP may start with fewer teams.

MVP teams may be:

HQ Admin
Merchant Ops
Support
Field/Inventory Ops
AI Menu Review

5\. Team Versus Role

Team and role must be separated.

Example:

team \= Merchant Operations
role \= Trial Onboarding Manager

Example:

team \= Inventory Operations
role \= Entry Media Inventory Operator

A team describes organizational placement.

A role describes operating function.

A permission describes system authority.

Core rule:

Team membership is context.
Role is responsibility.
Permission is authority.

6\. HQ Admin Team

HQ Admin Team is responsible for platform-level administration.

Responsibilities:

company settings
business unit settings
merchant account approval
service status control
platform-level operator management
sensitive action oversight
cross-business boundary review
high-risk support escalation
audit review coordination

HQ Admin Team may supervise other teams, but must not bypass audit and permission rules.

Core rule:

HQ Admin has high responsibility.
HQ Admin still requires scoped authority and audit.

7\. Merchant Operations Team

Merchant Operations Team is responsible for merchant lifecycle operation.

Responsibilities:

trial merchant onboarding
merchant account preparation
store profile readiness
trial start coordination
usage follow-up
conversion support
trial extension coordination
service suspension coordination
merchant termination coordination
handoff to field or support teams

Merchant Ops owns operational merchant follow-up.

Merchant Ops does not automatically own Entry Media inventory authority or HQ-level access.

8\. Support Operations Team

Support Operations Team is responsible for merchant and runtime issue handling.

Responsibilities:

merchant inquiry handling
request issue review
support signal review
evidence packet review
translation issue escalation
critical request issue escalation
owner console issue support
Entry Media scan issue triage
runtime failure triage

Support may view limited evidence based on masking policy.

Support must not silently mutate runtime state unless explicitly authorized.

Core rule:

Support explains and escalates.
Support does not silently operate.

9\. Field Operations Team

Field Operations Team is responsible for physical merchant field work.

Responsibilities:

Entry Plate delivery
Entry Plate installation
merchant on-site guidance
placement check
NFC/QR scan test
physical recovery
replacement visit
field evidence collection
merchant visit note

Field Ops performs physical actions.

System state changes must still be recorded through authorized workflow.

Core rule:

Field Ops moves physical assets.
System policy records operational truth.

10\. Inventory Operations Team

Inventory Operations Team is responsible for Entry Media and Entry Plate stock control.

Responsibilities:

Entry Plate registration
batch receipt coordination
stock count
field stock checkout
recovered stock inspection
damaged/lost/retired status review
reallocation readiness
inventory reconciliation
batch defect detection

Inventory Ops owns stock integrity.

Inventory Ops may not automatically control merchant service status.

Core rule:

Inventory Ops owns asset condition and stock readiness.
Merchant service eligibility belongs to merchant/HQ workflow.

11\. AI Menu Review Team

AI Menu Review Team is responsible for reviewing AI-generated menu drafts.

Responsibilities:

menu photo intake review
OCR/AI extraction review
menu name validation
price extraction review
category correction
option structure review
allergy candidate review
translation draft review
merchant confirmation preparation

AI Menu Review does not create final merchant responsibility by itself.

Merchant or authorized operator must confirm before live use, depending on policy.

Core rule:

AI drafts.
Reviewers validate.
Merchant or authorized workflow approves live menu context.

12\. Sales Operations Team

Sales Operations Team is responsible for merchant acquisition and trial proposal.

Responsibilities:

prospect tracking
merchant contact
trial offer explanation
trial condition explanation
basic product demonstration
conversion discussion
handoff to Merchant Ops after trial agreement

Sales Ops may create prospect context.

Sales Ops should not directly activate live service without required approval.

Core rule:

Sales creates opportunity.
Merchant Ops or HQ activates controlled service.

13\. Finance/Billing Operations Team

Finance/Billing Operations Team is responsible for billing and plan support.

Responsibilities:

plan status support
paid conversion support
invoice reference
payment status reference
billing issue support
service suspension request due to billing if policy allows

Finance/Billing Ops should not directly delete merchant data.

Billing-related service suspension must be event-backed.

Core rule:

Billing status may affect service.
Billing action must not erase operational history.

14\. Product Operations Team

Product Operations Team is responsible for product configuration and release coordination.

Responsibilities:

feature flag coordination
Stage 0/Stage 1 rollout readiness
owner console feature readiness
entry media feature configuration
merchant feedback classification
MVP cutline management

Product Ops should not perform merchant-specific sensitive changes without authorization.

15\. Engineering Operations Team

Engineering Operations Team is responsible for technical platform operation.

Responsibilities:

runtime reliability
incident response
system configuration
deployment support
diagnostic review
failure code review
integration readiness
technical escalation

Engineering Ops may have elevated technical access.

Elevated access must be logged and scoped.

Core rule:

Engineering may repair systems.
Engineering must not bypass business authority.

16\. Audit/Compliance Review Team

Audit/Compliance Review Team is responsible for sensitive action review and evidence integrity.

Responsibilities:

audit event review
high-risk admin action review
support access review
mapping correction review
service termination evidence review
cross-business access review
data masking policy review

This team may be small or combined with HQ Admin in MVP.

Core rule:

Audit review protects trust.
Audit review does not replace operational ownership.

17\. Responsibility Assignment

Each merchant or operational case may have assigned responsible operators.

Suggested responsibility types:

merchant\_onboarding\_owner
trial\_followup\_owner
field\_installation\_owner
entry\_media\_inventory\_owner
support\_case\_owner
AI\_menu\_review\_owner
billing\_owner
HQ\_escalation\_owner
backup\_owner

Responsibility assignment should include:

responsibility\_id
target\_type
target\_id
responsibility\_type
primary\_operator\_id
backup\_operator\_id
assigned\_at
assigned\_by
status

18\. Primary Owner

Primary owner is the person or team responsible for normal handling.

Examples:

Merchant Ops owns trial follow-up.
Support owns support case handling.
Field Ops owns installation visit.
Inventory Ops owns recovered plate inspection.
AI Review owns menu draft validation.

Primary owner must be visible to HQ/Admin.

19\. Backup Owner

Backup owner acts when primary owner is unavailable.

Backup responsibility must be explicit.

Backup access should be:

time-scoped
reason-scoped
role-scoped
audit-logged
limited to necessary action

Core rule:

Backup is continuity.
Backup is not permanent authority expansion.

20\. Responsibility Status

Suggested responsibility statuses:

ASSIGNED
ACTIVE
WAITING\_ON\_MERCHANT
WAITING\_ON\_INTERNAL\_TEAM
ESCALATED
TRANSFER\_REQUESTED
TRANSFERRED
COMPLETED
CANCELLED

Responsibility status must be separate from service status.

Example:

merchant service\_status \= TRIAL\_ACTIVE
trial\_followup responsibility\_status \= WAITING\_ON\_MERCHANT

21\. Handoff Between Teams

Team handoff should be explicit.

Examples:

Sales Ops → Merchant Ops
Merchant Ops → Field Ops
Field Ops → Inventory Ops
Support → Engineering Ops
Support → HQ Admin
AI Menu Review → Merchant Ops
Finance/Billing Ops → HQ Admin

Handoff should include:

handoff\_reason
from\_team
to\_team
target\_id
current\_status
required\_action
created\_at
trace\_id

Core rule:

Handoff transfers responsibility.
It does not erase previous responsibility.

22\. Escalation

Escalation is required when normal team action is insufficient.

Escalation examples:

merchant disputes service termination
Entry Media maps to wrong store
lost plate still scans
support evidence conflict exists
AI menu critical warning uncertainty
billing-related suspension dispute
cross-business authority question

Escalation should identify:

escalation\_owner
reason
risk\_level
required decision
deadline if any
evidence reference

23\. Risk Levels

Suggested risk levels:

LOW
MEDIUM
HIGH
CRITICAL

Examples:

LOW
\= routine merchant question

MEDIUM
\= trial usage confusion or owner console issue

HIGH
\= wrong store mapping, critical menu warning, admin access mismatch

CRITICAL
\= security concern, sensitive data exposure, repeated wrong routing

Risk level may affect who can act.

24\. Sensitive Responsibility

Some responsibilities are sensitive.

Examples:

service termination
admin access suspension
Entry Media forced deactivation
mapping correction
lost active plate handling
support evidence access
AI menu critical warning override
cross-business link approval

Sensitive responsibility requires:

authorized role
reason
audit event
possibly reauthentication
possibly HQ review

25\. Responsibility And Permission Separation

Being responsible does not automatically allow every system action.

Example:

Field Operator responsible for recovery

does not automatically mean:

Field Operator can deactivate mapping

Example:

Support Operator responsible for a case

does not automatically mean:

Support Operator can edit merchant menu

Core rule:

Responsibility routes work.
Permission authorizes action.

26\. Operator Availability

Operator availability may affect backup responsibility.

Availability states may include:

AVAILABLE
UNAVAILABLE
ON\_LEAVE
AFTER\_HOURS
ESCALATION\_ONLY
DISABLED

If primary operator is unavailable, backup may be activated.

Backup activation must be logged.

27\. Team Capacity

Merchant Ops, Support, Field Ops, and Inventory Ops may need capacity tracking later.

MVP may only record assignment.

Deferred:

workload balancing
route optimization
shift scheduling
SLA automation
team calendar integration

Do not import full HR scheduling into MVP.

28\. Relationship To Identity Access

This document defines:

teams
roles
responsibility
ownership
handoff
escalation

Identity Access defines:

login
role permission
scope
reauthentication
support masking
admin action authority

Core separation:

Organization Core says who is responsible.
Identity Access says who is allowed.

29\. Relationship To CatchMenu HQ

CatchMenu HQ should provide admin screens for:

team list
operator list
responsibility assignment
backup assignment
escalation owner
merchant ownership
internal handoff status

HQ actions must respect Identity Access.

30\. Relationship To Merchant Ops

Merchant Ops uses responsibility assignment for:

trial onboarding
follow-up
conversion
termination
field request
support escalation

Merchant Ops may coordinate teams but should not bypass team-specific authority.

31\. Relationship To Entry Media Inventory

Entry Media Inventory may need responsibility links:

inventory\_owner
field\_operator
recovery\_owner
inspection\_owner
reallocation\_owner

Inventory status changes must still follow Entry Media policy.

32\. Relationship To AI Menu Intake

AI Menu Intake may need:

AI\_menu\_review\_owner
merchant\_confirmation\_owner
critical\_warning\_review\_owner
translation\_review\_owner

AI Menu Review responsibility must be tracked before menu goes live if risk is high.

33\. Relationship To Stage Runtime

Stage runtime may create signals that require team responsibility.

Examples:

unconfirmed request warning
request send failure
owner console unavailable
critical request detected
Entry Media resolution failed

These signals may route to Support, Merchant Ops, or Engineering Ops.

Runtime should not directly assign broad business authority.

34\. MVP Requirements

MVP should support at least:

team definitions
operator definitions
operator-to-team assignment
responsibility assignment
primary owner
backup owner
basic handoff
basic escalation
responsibility status
audit event for sensitive assignment changes

MVP may defer:

advanced workload balancing
calendar integration
full HR scheduling
attendance
payroll
team SLA automation
capacity planning

35\. Suggested Conceptual Entities

Suggested entities:

internal\_teams
operators
operator\_team\_assignments
responsibility\_assignments
responsibility\_events
team\_handoffs
escalations
backup\_assignments

This document defines policy.

Actual schema may be designed later.

36\. Failure Events

Invalid responsibility actions should create failure events.

Examples:

assign disabled operator
assign responsibility to team without valid operator
activate backup without reason
transfer responsibility without target owner
sensitive responsibility assigned without authority

Example failure codes:

WOH.ORG.RESPONSIBILITY.ASSIGN.DISABLED\_OPERATOR\_DENIED
WOH.ORG.RESPONSIBILITY.ASSIGN.TEAM\_OWNER\_REQUIRED
WOH.ORG.RESPONSIBILITY.BACKUP.REASON\_REQUIRED
WOH.ORG.RESPONSIBILITY.TRANSFER.TARGET\_REQUIRED
WOH.ORG.RESPONSIBILITY.SENSITIVE.AUTHORITY\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

37\. Audit Events

Recommended audit events:

INTERNAL\_TEAM\_CREATED
INTERNAL\_TEAM\_UPDATED
OPERATOR\_ASSIGNED\_TO\_TEAM
OPERATOR\_REMOVED\_FROM\_TEAM
RESPONSIBILITY\_ASSIGNED
RESPONSIBILITY\_TRANSFERRED
RESPONSIBILITY\_COMPLETED
BACKUP\_RESPONSIBILITY\_ASSIGNED
BACKUP\_RESPONSIBILITY\_ACTIVATED
ESCALATION\_CREATED
ESCALATION\_RESOLVED

Audit event fields:

event\_id
team\_id
operator\_id
target\_type
target\_id
previous\_owner
new\_owner
reason
actor\_type
actor\_id
created\_at
trace\_id

38\. Risk If Skipped

If internal responsibility is not defined, risks include:

trial merchant has no owner
Entry Plate recovery is forgotten
support cases are not resolved
AI menu draft goes live without review
wrong mapping incident has no escalation owner
service termination is processed without accountability
Franchise OS and CatchMenu responsibilities blur

Therefore, internal responsibility is foundational.

39\. Final Rule

CatchMenu internal teams must have clear responsibility without confusing responsibility with permission.

Final rule:

Define teams.
Define roles.
Assign responsibility.
Assign backup.
Record handoff.
Escalate high-risk cases.
Audit sensitive changes.
Use Identity Access for authority.
Do not import full Franchise OS HR weight.
