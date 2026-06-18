# 020320_Policy_Role_Permission_And_Scope

Legacy path: $old.

1\. Purpose

This document defines the role, permission, and scope policy for CatchMenu / Wait Order Handoff.

CatchMenu follows the common Login Foundation for authentication and session control.

This document defines authorization after login.

Core purpose:

Define CatchMenu roles.
Define permission categories.
Define scope boundaries.
Separate login from authority.
Separate responsibility from permission.
Separate cross-business link from access.
Support merchant, store, HQ, support, field, inventory, AI review, and system job authorization.
Prevent Franchise OS roles from becoming CatchMenu roles by default.

Korean purpose:

CatchMenu 역할을 정의한다.
권한 카테고리를 정의한다.
접근 범위를 정의한다.
로그인과 권한을 분리한다.
책임과 권한을 분리한다.
Cross-business link와 접근 권한을 분리한다.
고객사, 매장, HQ, 지원, 현장, 재고, AI 검수, 시스템 작업 권한을 지원한다.
Franchise OS 역할이 CatchMenu 역할로 자동 전환되지 않게 한다.

2\. Scope

This document covers:

role
permission
scope
role assignment
permission assignment
merchant scope
store scope
support case scope
Entry Media scope
menu context scope
HQ scope
temporary role
backup authority
cross-business access denial
permission audit
permission failure

This document does not define:

global login foundation
session timeout
duplicate login
full HR
attendance
payroll
employee contract
merchant billing engine
Stage 0 request state machine
Entry Media physical lifecycle
support masking detail
sensitive action reauthentication detail

Related documents:

00400\_Identity\_Access\_Readme.md
00410\_User\_Account\_And\_Login\_Policy.md
00430\_Merchant\_User\_And\_Store\_Access\_Policy.md
00440\_HQ\_Admin\_Access\_And\_Backup\_Policy.md
00450\_Support\_Access\_Masking\_And\_Evidence\_View\_Policy.md
00460\_Sensitive\_Action\_Reauthentication\_And\_Audit\_Policy.md
00470\_Cross\_Business\_Access\_And\_Federation\_Boundary\_Policy.md
00500\_organization\_core/

3\. Core Principle

Authorization is role plus permission plus scope.

Core rule:

Login is not enough.
Role is not enough.
Scope is required.
Permission is action authority.

Korean rule:

로그인만으로는 부족하다.
역할만으로도 부족하다.
범위가 필요하다.
권한은 행동 권한이다.

A user may have a role but still be unable to act outside the assigned scope.

4\. Authentication Versus Authorization

Authentication proves actor identity.

Authorization decides action authority.

Example:

authenticated user \= owner@example.com
role \= Merchant Owner
scope \= merchant\_account\_001
permission \= menu.update

This user may edit menus only within allowed merchant/store/menu scope.

Core rule:

Authenticated actor still requires role, permission, and scope check.

5\. Organization Versus Authorization

Organization Core defines structure.

Identity Access defines authority.

Organization Core may say:

operator belongs to Support team

But that does not automatically mean:

operator can view all support evidence

Core rule:

Team membership is context.
Role assignment creates responsibility type.
Permission and scope create action authority.

6\. Responsibility Versus Permission

Responsibility assignment does not automatically grant permission.

Example:

Field Operator is responsible for Entry Plate recovery.

This does not automatically allow:

Field Operator can deactivate Entry Media mapping.

Example:

Support Operator owns a support case.

This does not automatically allow:

Support Operator can edit merchant menu.

Core rule:

Responsibility routes work.
Permission authorizes action.

7\. Cross-Business Link Versus Permission

Cross-business link is not permission.

Example:

Franchise OS store linked to CatchMenu merchant\_store

does not automatically mean:

Franchise OS Store Manager can manage CatchMenu Owner Console.

Core rule:

Cross-business link is reference.
Role and scope create access.

8\. Role Definition

Role defines a named operating authority pattern.

Suggested role categories:

merchant roles
store roles
internal operator roles
HQ roles
support roles
field roles
inventory roles
AI review roles
system roles

Role should not be universal power.

Core rule:

Role must be evaluated with scope.

9\. Permission Definition

Permission defines allowed action.

Permission examples:

merchant.read
merchant.update
store.read
store.update
menu.read
menu.update
menu.publish
request.read
request.confirm
request.done
support\_case.read
support\_case.update
evidence.masked\_read
evidence.unmask
entry\_media.read
entry\_media.assign
entry\_media.deactivate\_mapping
entry\_media.mark\_recovered
service\_status.update
role.grant
role.revoke
audit.read
cross\_business\_link.approve

Permission should be action-specific.

10\. Scope Definition

Scope defines where a permission applies.

Suggested scope types:

platform
company
business\_unit
team
operator
merchant\_account
merchant\_store
menu\_context
request
support\_case
evidence\_packet
entry\_media
entry\_media\_mapping
trial
service\_status
billing
audit
cross\_business\_link

Core rule:

Permission without scope is unsafe.

11\. Scope Levels

Scope levels may include:

GLOBAL\_PLATFORM
COMPANY
BUSINESS\_UNIT
TEAM
MERCHANT\_ACCOUNT
MERCHANT\_STORE
CASE
ASSET
REQUEST
MENU\_CONTEXT
SELF

Examples:

MERCHANT\_ACCOUNT scope
\= user can act across assigned merchant account

MERCHANT\_STORE scope
\= user can act only for assigned store

CASE scope
\= support access limited to specific support case

ASSET scope
\= inventory access limited to specific Entry Media asset

SELF scope
\= user can view or update own profile only

12\. Role Assignment

Role assignment connects a user to a role and scope.

Recommended fields:

role\_assignment\_id
user\_id
role\_id
scope\_type
scope\_id
assignment\_status
assigned\_by
assigned\_at
expires\_at
reason
trace\_id

Role assignment must be auditable.

Core rule:

No role assignment without scope and trace.

13\. Role Assignment Status

Suggested statuses:

PENDING
ACTIVE
SUSPENDED
REVOKED
EXPIRED
TRANSFERRED
REVIEW\_REQUIRED

Meaning:

PENDING
\= role assignment created but not active

ACTIVE
\= role assignment can be used

SUSPENDED
\= role assignment temporarily blocked

REVOKED
\= role assignment removed

EXPIRED
\= temporary role expired

TRANSFERRED
\= responsibility or role moved elsewhere

REVIEW\_REQUIRED
\= assignment requires review before use

14\. Merchant Roles

Suggested merchant roles:

MERCHANT\_OWNER
STORE\_MANAGER
STORE\_STAFF\_VIEWER
REQUEST\_BOARD\_VIEWER
MENU\_EDITOR
BILLING\_CONTACT

Merchant roles must be scoped to:

merchant\_account
merchant\_store
feature area

Core rule:

Merchant role never grants access to other merchants by default.

15\. Merchant Owner Role

Merchant Owner may be allowed to:

merchant.read
merchant.update\_limited
store.read
store\_user.invite\_limited
menu.read
menu.update
menu.review\_ai\_draft
request.read
usage.read
support\_case.create
service\_status.read

Sensitive or restricted actions:

billing.update
service\_plan.change
store\_user.grant\_admin
menu.publish\_high\_risk

Merchant Owner must not automatically:

access CatchMenu HQ
access other merchants
grant HQ roles
deactivate Entry Media globally
unmask internal evidence
view Franchise OS data

16\. Store Manager Role

Store Manager may be allowed to:

store.read
store.update\_limited
menu.read
menu.update\_limited
request.read
request.confirm
request.done
usage.read\_store
support\_case.create

Store Manager must be scoped to assigned stores.

Store Manager must not automatically:

change billing
change merchant account-level plan
manage all stores
grant HQ roles
view unrelated support evidence
access CatchMenu HQ

17\. Store Staff Viewer Role

Store Staff Viewer may be allowed to:

request.read
request.detail\_read
critical\_warning.read

Optional if granted:

request.confirm
request.done

Store Staff Viewer must not automatically:

menu.update
service\_status.update
billing.read
store\_user.manage
entry\_media.deactivate\_mapping
support\_evidence.read

Core rule:

Store Staff Viewer is narrow and operational.

18\. Request Board Viewer Role

Request Board Viewer may be narrower than Store Staff Viewer.

Allowed:

request\_board.read
request.detail\_read

Optional:

request.confirm
request.done

Not allowed:

menu.update
store.update
billing.read
support\_case.read\_unrelated
service\_status.update

This role supports POS-less Stage 0C request board operation.

19\. Menu Editor Role

Menu Editor may be allowed to:

menu.read
menu.item.create
menu.item.update
menu.category.update
menu.price.update
menu.option.update
menu.ai\_draft.review
menu.submit\_for\_publish

High-risk permissions:

menu.publish
menu.critical\_warning.override
menu.translation.publish
menu.bulk\_price\_update

High-risk permissions may require additional review or reauthentication.

Core rule:

Menu editing and menu publishing may be separate permissions.

20\. Billing Contact Role

Billing Contact may be allowed to:

billing.read
plan.read
invoice\_reference.read
payment\_status.read
support\_case.create\_billing

Billing Contact must not automatically:

request.confirm
menu.update
service\_status.terminate
entry\_media.deactivate\_mapping
HQ\_admin.access

Billing actions may be limited in MVP.

21\. Internal Operator Roles

Suggested internal operator roles:

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
SYSTEM\_ADMIN

Internal operator roles must be scoped by company/team/case/merchant/store/asset as appropriate.

22\. HQ Admin Role

HQ Admin may be allowed to:

merchant.create
merchant.update
merchant\_store.create
merchant\_store.update
service\_status.update
trial\_status.update
operator.assign
role.grant\_limited
role.revoke\_limited
entry\_media.admin\_review
support\_signal.review
cross\_business\_link.review
audit.read

High-risk permissions:

role.grant\_hq\_admin
service\_status.terminate
entry\_media.deactivate\_mapping
evidence.unmask
cross\_business\_link.approve
audit.export

HQ Admin must follow sensitive action reauthentication and audit.

Core rule:

HQ Admin is powerful but not unbounded.

23\. HQ Manager Role

HQ Manager may be allowed to:

merchant.read
merchant\_store.read
trial\_status.read
usage.read
operator\_assignment.read
support\_signal.read
escalation.review

Optional:

trial\_status.update\_limited
operator.assign\_limited

HQ Manager should not automatically have high-risk admin authority.

24\. Support Operator Role

Support Operator may be allowed to:

support\_case.read\_assigned
support\_case.update\_assigned
evidence.masked\_read
request.timeline\_read
entry\_media.resolution\_read
merchant\_contact.read\_limited
support\_note.create
support\_case.escalate

Support Operator must not automatically:

evidence.unmask
merchant.update
menu.update
service\_status.update
entry\_media.deactivate\_mapping
role.grant
audit.export

Core rule:

Support access is case-scoped, masked, and audited.

25\. Field Operator Role

Field Operator may be allowed to:

field\_task.read\_assigned
merchant\_store.visit\_info\_read
entry\_media.scan\_test\_record
entry\_media.installation\_result\_record
entry\_media.recovery\_result\_record
field\_note.create

Field Operator must not automatically:

entry\_media.mapping\_activate
entry\_media.mapping\_deactivate
service\_status.update
merchant\_account.update
support\_evidence.read\_unrelated

Core rule:

Field authority is task-scoped and physical-operation focused.

26\. Inventory Operator Role

Inventory Operator may be allowed to:

entry\_media.read
entry\_media.register
entry\_media.stock\_update
entry\_media.inspection\_record
entry\_media.mark\_damaged
entry\_media.mark\_lost\_candidate
entry\_media.mark\_recovered
entry\_media.reallocation\_ready\_mark

High-risk permissions:

entry\_media.deactivate\_mapping
entry\_media.retire
entry\_media.reactivate\_after\_lost
entry\_media.reallocate

Inventory authority is asset-scoped, not merchant business authority.

27\. AI Menu Reviewer Role

AI Menu Reviewer may be allowed to:

menu\_ai\_draft.read
menu\_ai\_draft.review
menu\_ai\_draft.correct\_item
menu\_ai\_draft.correct\_price
menu\_ai\_draft.correct\_category
menu\_ai\_draft.correct\_option
critical\_warning.review
translation.review
menu\_ai\_draft.submit\_reviewed

High-risk permissions:

menu.publish
critical\_warning.override
translation.publish

Core rule:

AI reviewer validates draft.
Publishing live menu may require separate authority.

28\. Sales Operator Role

Sales Operator may be allowed to:

prospect.create
prospect.update
trial\_offer.record
merchant\_contact.create\_limited
demo\_account.request
merchant\_ops\_handoff.create

Sales Operator must not automatically:

service\_status.activate
role.grant
entry\_media.assign
billing.finalize
support\_evidence.read

Core rule:

Sales creates opportunity.
Controlled workflow activates service.

29\. Finance Operator Role

Finance Operator may be allowed to:

billing.read
plan.read
payment\_status.read
invoice\_reference.update
billing\_support\_case.update

Sensitive permissions:

service\_status.suspend\_for\_billing
service\_status.reactivate\_after\_billing
billing.export

Billing-related service change must be event-backed and audited.

30\. Engineering Operator Role

Engineering Operator may be allowed to:

technical\_diagnostic.read
runtime\_failure.review
system\_health.read
integration\_status.read
deployment\_support.record
technical\_support\_note.create

High-risk permissions:

runtime\_config.update
emergency\_fix.apply
data\_repair.request
data\_repair.execute

Engineering must not bypass business authority.

Core rule:

Engineering may repair systems.
Engineering must not silently mutate business state.

31\. Audit Reviewer Role

Audit Reviewer may be allowed to:

audit.read
admin\_action.read
support\_access.read
sensitive\_action.read
cross\_business\_link.audit\_read

High-risk permissions:

audit.export
evidence.unmask\_for\_audit
audit\_exception.approve

Audit review must not become operational mutation authority unless explicitly granted.

32\. System Job Role

System Job may be allowed to:

support\_signal.create
usage\_aggregate.create
trial\_expiration.detect
unconfirmed\_warning.detect
orphaned\_responsibility.detect
consistency\_check.run

System Job must not silently:

grant\_role
terminate\_service
unmask\_evidence
override\_state
delete\_audit
cross\_business\_link.approve

Core rule:

System Job detects and signals.
Human or authorized workflow decides high-risk action.

33\. Permission Categories

Suggested permission categories:

READ
CREATE
UPDATE
DELETE\_RESTRICTED
APPROVE
CONFIRM
DONE
ASSIGN
SUSPEND
REACTIVATE
DEACTIVATE
RECOVER
REVIEW
PUBLISH
EXPORT
UNMASK
OVERRIDE
AUDIT\_VIEW

High-risk categories:

SUSPEND
REACTIVATE
DEACTIVATE
EXPORT
UNMASK
OVERRIDE
ADMIN\_GRANT
SERVICE\_TERMINATE
CROSS\_BUSINESS\_APPROVE
AUDIT\_EXPORT

High-risk permissions require stricter controls.

34\. Permission Naming

Permission names should be clear and resource-based.

Recommended style:

resource.action

Examples:

merchant.read
merchant\_store.update
menu.publish
request.confirm
support\_case.escalate
evidence.unmask
entry\_media.deactivate\_mapping
service\_status.terminate
role.grant
audit.export

Avoid vague permissions:

admin\_all
manage\_everything
super\_power
full\_access

Core rule:

Permission name must explain the resource and action.

35\. Deny By Default

CatchMenu permissions should be deny-by-default.

Default:

no role assignment
\= no authenticated business authority

role without scope
\= denied

scope without permission
\= denied

permission outside scope
\= denied

cross-business link without role
\= denied

Core rule:

Deny unless explicitly allowed.

36\. Least Privilege

Users should receive only the permissions needed for their work.

Examples:

Store Staff Viewer does not need menu edit permission.
Support Operator does not need billing export permission.
Field Operator does not need service termination permission.
AI Reviewer does not need Entry Media stock permission.
Merchant Owner does not need HQ audit export permission.

Core rule:

Give the minimum permission needed for the task.

37\. Temporary Permission

Temporary permission may be granted for:

support session
backup responsibility
field task
AI review assignment
HQ escalation
cross-business review
incident handling

Temporary permission must include:

reason
scope
start time
expiry time
granted by
audit event

Core rule:

Temporary permission must expire.

38\. Backup Authority

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

Backup is continuity.
Backup is not hidden permanent access.

39\. Support Case Scope

Support access must be case-scoped.

Support Operator may access:

assigned support case
related merchant/store context
masked evidence packet
request timeline relevant to case
technical status relevant to case

Support Operator must not access:

unrelated merchant data
all merchant stores
unmasked evidence by default
Franchise OS HR data
unrelated billing details

Core rule:

Support scope follows the case.

40\. Merchant Account Scope

Merchant account scope allows access across assigned merchant account.

Use for:

Merchant Owner
account-level manager
HQ operator assigned to merchant
Merchant Ops owner

Merchant account scope may include multiple stores.

But permissions still define allowed actions.

Example:

merchant\_account scope \+ menu.read
does not mean billing.update

41\. Merchant Store Scope

Merchant store scope limits access to specific stores.

Use for:

Store Manager
Store Staff Viewer
Request Board Viewer
Field Operator
store-specific support case

Core rule:

Store scope must not expand to account scope silently.

42\. Entry Media Scope

Entry Media scope limits actions to specific Entry Media asset or mapping.

Use for:

Inventory Operator
Field Operator
Support Operator
HQ Admin

High-risk Entry Media actions require audit and possibly reauthentication.

Examples:

entry\_media.deactivate\_mapping
entry\_media.reallocate
entry\_media.mark\_lost
entry\_media.reactivate\_after\_lost

43\. Menu Context Scope

Menu context scope limits menu-related actions.

Use for:

Menu Editor
Merchant Owner
AI Menu Reviewer
Store Manager
HQ Admin

Menu publish may require stronger permission than menu edit.

Critical warning override must be high-risk.

44\. Request Scope

Request scope limits request board and request handling authority.

Use for:

Store Staff Viewer
Request Board Viewer
Store Manager
Support Operator

Request permissions:

request.read
request.detail\_read
request.confirm
request.done
request.escalate

Prohibited without proper permission:

request.force\_complete\_unconfirmed
request.delete\_history
request.mark\_payment\_complete

45\. Evidence Packet Scope

Evidence Packet scope limits access to support evidence.

Default access:

masked\_read

High-risk access:

unmask
export
raw\_event\_view

Evidence access must be:

case-scoped
reason-scoped
time-scoped if support session
audited

46\. Audit Scope

Audit scope controls who can view audit events.

Audit permissions:

audit.read\_own\_scope
audit.read\_merchant\_scope
audit.read\_platform
audit.export
audit.exception\_review

Audit export is high-risk.

Audit visibility must not expose unrelated sensitive records.

47\. Cross-Business Scope

Cross-business scope controls Franchise OS and CatchMenu links.

Permissions:

cross\_business\_link.read
cross\_business\_link.create
cross\_business\_link.approve
cross\_business\_link.suspend
cross\_business\_link.terminate
cross\_business\_access.review

Cross-business approval is high-risk.

Core rule:

Cross-business link is reference.
Cross-business access requires explicit permission and scope.

48\. Permission Evaluation

Permission evaluation should check:

user account active
session valid
role assignment active
permission exists for role
scope matches target
target status allows action
sensitive action requirements satisfied
cross-business boundary not violated
audit can be created

If any check fails, deny.

Core rule:

All authorization checks must pass.

49\. Target Status Check

Target status may affect permission.

Examples:

terminated merchant
\= no normal owner console access

suspended store
\= request board disabled unless support/admin mode

lost Entry Plate
\= reactivation denied without review

retired Entry Plate
\= normal reallocation denied

expired trial
\= owner access limited or suspended by policy

Core rule:

Permission must respect target state.

50\. Sensitive Action Requirement

Sensitive actions may require:

reauthentication
reason
audit event
two-person review if needed
HQ approval
support signal if abnormal

Sensitive actions include:

role.grant\_hq\_admin
evidence.unmask
service\_status.terminate
entry\_media.deactivate\_mapping
cross\_business\_link.approve
menu.critical\_warning.override
audit.export

Detailed policy belongs to:

00460\_Sensitive\_Action\_Reauthentication\_And\_Audit\_Policy.md

51\. Role Conflict

Role conflict occurs when a user holds roles that should not be combined.

Examples:

same user approves and audits same high-risk action
support operator unmasking evidence they created
field operator approving own lost asset recovery
AI reviewer overriding own critical warning without review

MVP may detect only high-risk conflicts.

Core rule:

Conflict of duty should be detected for sensitive actions.

52\. Role Review

Roles should be reviewed periodically.

Review targets:

HQ admin roles
support operator roles
temporary access
backup authority
cross-business access
inactive merchant owner access
terminated merchant access

MVP may support manual review signals.

53\. Access Suspension

Role assignment may be suspended independently of account.

Examples:

user account active
merchant role suspended

Meaning:

user can log in
but cannot access that merchant/store role

Core rule:

Account status and role assignment status are separate.

54\. Access Revocation

Role assignment revocation removes authority.

Revocation must be audited.

Revocation must not delete historical events.

Examples:

merchant owner removed
store manager no longer employed by merchant
support temporary access ended
HQ admin role revoked

55\. Permission Audit Events

Recommended audit events:

ROLE\_CREATED
ROLE\_UPDATED
PERMISSION\_CREATED
PERMISSION\_UPDATED
ROLE\_PERMISSION\_GRANTED
ROLE\_PERMISSION\_REVOKED
USER\_ROLE\_ASSIGNED
USER\_ROLE\_SUSPENDED
USER\_ROLE\_REVOKED
SCOPE\_GRANTED
SCOPE\_CHANGED
SCOPE\_REVOKED
TEMPORARY\_PERMISSION\_GRANTED
TEMPORARY\_PERMISSION\_EXPIRED
BACKUP\_AUTHORITY\_ACTIVATED
PERMISSION\_DENIED
SENSITIVE\_PERMISSION\_USED

Minimum audit fields:

event\_id
actor\_user\_id
target\_user\_id
role\_id
permission\_id
scope\_type
scope\_id
action
previous\_value
new\_value
reason
created\_at
trace\_id

56\. Permission Failure Events

Invalid authorization actions should create failure events.

Examples:

role assignment without scope
permission outside scope
support access without case
cross-business access through link only
sensitive permission without reauth
temporary permission without expiry
role grant without authority

Example failure codes:

WOH.IDENTITY.ROLE\_ASSIGNMENT.SCOPE\_REQUIRED
WOH.IDENTITY.PERMISSION.OUT\_OF\_SCOPE\_DENIED
WOH.IDENTITY.SUPPORT\_ACCESS.CASE\_SCOPE\_REQUIRED
WOH.IDENTITY.CROSS\_BUSINESS.LINK\_ONLY\_ACCESS\_DENIED
WOH.IDENTITY.SENSITIVE\_ACTION.REAUTH\_REQUIRED
WOH.IDENTITY.TEMPORARY\_PERMISSION.EXPIRY\_REQUIRED
WOH.IDENTITY.ROLE\_GRANT.AUTHORITY\_REQUIRED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

57\. Support Signals

Support signals may include:

ROLE\_SCOPE\_MISSING
ROLE\_PERMISSION\_CONFLICT
TEMPORARY\_PERMISSION\_EXPIRED
BACKUP\_AUTHORITY\_ACTIVE
SUPPORT\_ACCESS\_SCOPE\_MISMATCH
HQ\_ADMIN\_ROLE\_REVIEW\_REQUIRED
CROSS\_BUSINESS\_ACCESS\_ATTEMPT\_DENIED
SENSITIVE\_PERMISSION\_USED
ROLE\_REVIEW\_OVERDUE

Support Signal alerts.

It does not grant or revoke access by itself.

58\. Relationship To User Account And Login

User Account and Login policy defines:

user account
login identity
session class
account status
login foundation application

This document defines:

role
permission
scope
authorization after login

Core separation:

Login authenticates.
Role permission authorizes.

59\. Relationship To Merchant User Access

Merchant User Access uses this policy for:

merchant owner role
store manager role
store staff role
menu editor role
request board viewer role
merchant/store scope

Detailed merchant-side policy is defined in:

00430\_Merchant\_User\_And\_Store\_Access\_Policy.md

60\. Relationship To HQ Admin Access

HQ Admin Access uses this policy for:

HQ admin role
HQ manager role
backup authority
high-risk action control
platform scope

Detailed HQ policy is defined in:

00440\_HQ\_Admin\_Access\_And\_Backup\_Policy.md

61\. Relationship To Support Access

Support Access uses this policy for:

support operator role
case scope
masked evidence permission
temporary support access

Detailed support masking policy is defined in:

00450\_Support\_Access\_Masking\_And\_Evidence\_View\_Policy.md

62\. Relationship To Entry Media Inventory

Entry Media Inventory uses this policy for:

entry\_media.read
entry\_media.register
entry\_media.assign
entry\_media.mark\_recovered
entry\_media.mark\_lost
entry\_media.deactivate\_mapping
entry\_media.reallocate

Entry Media actions must be asset-scoped and audited.

63\. Relationship To Stage Runtime

Stage runtime uses this policy for:

request.read
request.confirm
request.done
request.escalate
support\_case.create

Public Guest does not use admin role permission.

Store staff and support actors must be authorized.

64\. Relationship To AI Menu Intake

AI Menu Intake uses this policy for:

menu\_ai\_draft.read
menu\_ai\_draft.review
menu.update
menu.publish
critical\_warning.override
translation.publish

AI draft review and live publish should be separate.

65\. MVP Requirements

Role Permission MVP should support at least:

role
permission
role\_permission mapping
user\_role\_assignment
scope\_type
scope\_id
merchant\_account scope
merchant\_store scope
support\_case scope
entry\_media scope
menu\_context scope
HQ admin role
merchant owner role
store manager role
store staff viewer role
support operator role
field operator role
inventory operator role
AI menu reviewer role
system job role
temporary permission
basic audit event
permission denied failure event

MVP may defer:

advanced ABAC
policy engine DSL
complex separation-of-duty engine
enterprise directory role sync
full group federation
automatic role review workflow
complex delegated administration

66\. Suggested Conceptual Entities

Suggested entities:

roles
permissions
role\_permissions
user\_role\_assignments
access\_scopes
temporary\_permission\_grants
permission\_audit\_events
permission\_failure\_events
role\_review\_signals

This document defines policy.

Actual schema may be designed later.

67\. Risk If Skipped

If role, permission, and scope are skipped, risks include:

logged-in user receives too much authority
merchant owner accesses another merchant
store staff edits menu accidentally
support sees unrelated evidence
field operator changes service status
inventory operator controls merchant business status
Franchise OS role leaks into CatchMenu
cross-business link becomes access
sensitive action happens without trace

Therefore, role, permission, and scope must be defined before Owner Console, Merchant Ops, and HQ features are finalized.

68\. Final Rule

CatchMenu authorization must be explicit, scoped, and auditable.

Final rule:

Authenticate first.
Authorize through role.
Limit by scope.
Check permission.
Respect target status.
Deny by default.
Grant least privilege.
Expire temporary access.
Audit role and permission changes.
Never treat login, responsibility, or cross-business link as authority by itself.
