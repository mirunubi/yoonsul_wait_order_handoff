# 020330_Policy_Merchant_User_And_Store_Access

Legacy path: $old.

1\. Purpose

This document defines the merchant user and store access policy for CatchMenu / Wait Order Handoff.

CatchMenu merchant users are customer-side users who operate Owner Console, request board, menu context, store setup, trial status view, usage view, and support entry points.

Merchant access must be scoped by merchant account and merchant store.

Core purpose:

Define merchant-side user access.
Separate merchant account access from store access.
Define Merchant Owner, Store Manager, Store Staff Viewer, Request Board Viewer, Menu Editor, and Billing Contact boundaries.
Prevent one merchant from accessing another merchant.
Prevent store staff from receiving broad owner authority.
Prepare Owner Console, Stage 0 request board, AI Menu Intake, Merchant Ops, and Support workflows.

Korean purpose:

고객사 측 사용자 접근을 정의한다.
Merchant Account 접근과 Merchant Store 접근을 분리한다.
Merchant Owner, Store Manager, Store Staff Viewer, Request Board Viewer, Menu Editor, Billing Contact 경계를 정의한다.
한 고객사가 다른 고객사에 접근하지 못하게 한다.
매장 직원이 넓은 업주 권한을 갖지 않게 한다.
Owner Console, Stage 0 요청판, AI Menu Intake, Merchant Ops, Support 흐름을 준비한다.

2\. Scope

This document covers:

merchant user
merchant owner
store manager
store staff viewer
request board viewer
menu editor
billing contact
merchant account scope
merchant store scope
owner console access
request board access
menu access
store user invitation
trial status visibility
service status visibility
support entry point
merchant access suspension
merchant access revocation

This document does not define:

global login foundation
HQ admin authority
support operator masking detail
internal operator assignment
Entry Media physical lifecycle
Stage 0 request state machine
billing engine
payment integration
Franchise OS HR

Related documents:

00400\_Identity\_Access\_Readme.md
00410\_User\_Account\_And\_Login\_Policy.md
00420\_Role\_Permission\_And\_Scope\_Policy.md
00440\_HQ\_Admin\_Access\_And\_Backup\_Policy.md
00450\_Support\_Access\_Masking\_And\_Evidence\_View\_Policy.md
02400\_owner\_console/
01100\_stage\_0\_entry\_runtime/
00530\_Merchant\_Account\_Company\_And\_Store\_Context\_Policy.md

3\. Core Principle

Merchant access is scoped.

Core rule:

Merchant user access must be limited to assigned merchant account and store scope.

Korean rule:

고객사 사용자 접근은 배정된 Merchant Account와 Merchant Store 범위로 제한되어야 한다.

A merchant user must never see another merchant by accident.

4\. Merchant Account Versus Merchant Store

Merchant Account is the SaaS customer relationship.

Merchant Store is the actual operating location.

Access may be assigned to:

merchant\_account
merchant\_store
both merchant\_account and selected merchant\_stores

Example:

Merchant Owner
\= merchant\_account scope

Store Manager
\= selected merchant\_store scope

Store Staff Viewer
\= selected merchant\_store request board scope

Core rule:

Account-level access and store-level access must not be collapsed.

5\. Merchant User Types

Merchant-side user types may include:

MERCHANT\_OWNER
STORE\_MANAGER
STORE\_STAFF\_VIEWER
REQUEST\_BOARD\_VIEWER
MENU\_EDITOR
BILLING\_CONTACT

MVP may start with:

MERCHANT\_OWNER
STORE\_MANAGER
STORE\_STAFF\_VIEWER

Optional early addition:

MENU\_EDITOR
REQUEST\_BOARD\_VIEWER

Billing Contact may be deferred if billing is not in MVP.

6\. Merchant Owner

Merchant Owner is the highest merchant-side role.

Merchant Owner may be allowed to:

view merchant account
view assigned stores
view service status
view trial status
view usage summary
view owner console
invite limited store users
manage store users if enabled
view menu context
edit menu if granted
review AI menu draft if granted
approve menu draft if policy allows
view request board
contact support
create support case

Merchant Owner must not automatically:

access CatchMenu HQ
access other merchants
grant HQ roles
grant support roles
view internal support notes by default
unmask evidence
change Entry Media global status
deactivate Entry Media mapping
approve cross-business link
access Franchise OS data

Core rule:

Merchant Owner is merchant-side high authority.
Merchant Owner is not CatchMenu internal authority.

7\. Store Manager

Store Manager is a store-scoped merchant role.

Store Manager may be allowed to:

view assigned store
view request board
view request detail
confirm request if enabled
mark done if enabled
view store menu
edit store menu if granted
view store usage summary
view trial status for assigned store
create support case

Store Manager must not automatically:

access all merchant stores
change merchant account-level settings
change billing
change service plan
invite merchant owner
grant HQ/admin roles
deactivate Entry Media mapping
view unrelated support cases
access CatchMenu HQ

Core rule:

Store Manager authority is store-scoped.

8\. Store Staff Viewer

Store Staff Viewer is a narrow daily operations role.

Store Staff Viewer may be allowed to:

open request board
view request list
view request detail
view selected items
view guest language summary
view critical warning labels

Optional if explicitly granted:

confirm request
mark done

Store Staff Viewer must not automatically:

edit menu
change prices
change store settings
invite users
view billing
view usage analytics beyond basic board
change service status
access support evidence
access CatchMenu HQ

Core rule:

Store Staff Viewer should be operational, narrow, and safe for daily store use.

9\. Request Board Viewer

Request Board Viewer is the narrowest request-board-specific role.

Allowed:

request\_board.read
request.detail\_read
critical\_warning.read

Optional if granted:

request.confirm
request.done

Not allowed:

menu.update
menu.publish
store.update
merchant.update
billing.read
service\_status.update
support\_evidence.read
entry\_media.update

This role is useful for POS-less Stage 0C where a store device or staff member only needs request board access.

Core rule:

Request Board Viewer sees requests, not merchant administration.

10\. Menu Editor

Menu Editor may be assigned to a merchant user when menu editing should be separated from owner/admin access.

Menu Editor may be allowed to:

menu.read
menu.item.create
menu.item.update
menu.category.update
menu.price.update
menu.option.update
menu.ai\_draft.review
menu.submit\_for\_publish

High-risk menu actions may require stronger authority:

menu.publish
menu.bulk\_price\_update
menu.critical\_warning.override
menu.translation.publish

Menu Editor must not automatically:

change service status
invite users
view billing
deactivate Entry Media
view support evidence
access HQ

Core rule:

Menu editing and menu publishing may be separate permissions.

11\. Billing Contact

Billing Contact may be used when paid service begins.

Billing Contact may be allowed to:

billing.read
plan.read
invoice\_reference.read
payment\_status.read
billing\_support\_case.create

Billing Contact must not automatically:

edit menu
confirm request
mark done
invite store users
terminate service
deactivate Entry Media
access support evidence

MVP may defer Billing Contact until paid plan operation begins.

12\. Merchant User Invitation

Merchant user invitation should be controlled.

Invitation may include:

invitation\_id
merchant\_account\_id
merchant\_store\_id optional
target\_role
target\_scope
invited\_by
expires\_at
status

Allowed inviters may include:

Merchant Owner
HQ Admin
authorized Merchant Ops Operator

Store Manager may invite staff only if policy allows.

Core rule:

Invitation must include role and scope.

13\. Store User Invitation

Store user invitation should be store-scoped.

Examples:

invite Store Manager to store\_001
invite Store Staff Viewer to store\_001
invite Request Board Viewer to store\_001

Prohibited:

store-scoped inviter grants merchant account-wide access
store-scoped inviter grants HQ access
store-scoped inviter grants billing authority without permission

Core rule:

Store user invitation cannot exceed inviter authority.

14\. Merchant Owner Verification

Merchant Owner should require stronger verification than Store Staff Viewer.

Verification may include:

email verification
phone verification
merchant confirmation
HQ or Merchant Ops approval
contract or trial approval context

MVP may start with email/phone verification and HQ/Merchant Ops creation.

Core rule:

Merchant Owner controls merchant-side access.
Merchant Owner identity must be reliable.

15\. Store Operation Session

Store operation access may use a controlled store operation session.

Applicable roles:

Store Staff Viewer
Request Board Viewer
Store Manager request board mode

Store operation session should follow Login Foundation but may have approved operation-mode handling.

Allowed exception if approved:

screen lock instead of full logout
quick recheck instead of full login
store-scoped request board session
limited action set
no access to owner/admin settings

Core rule:

Store operation convenience must not expand authority.

16\. Owner Console Access

Owner Console access is merchant-facing.

Owner Console may expose:

merchant account profile
store list
store settings
menu context
AI menu draft
request board
usage summary
trial status
service status
support entry point
user management if permitted

Owner Console must only show content within the user's merchant/store scope.

Core rule:

Owner Console must evaluate merchant scope and store scope on every sensitive view and action.

17\. Request Board Access

Request Board access is store-scoped.

Request Board may show:

request time
selected items
quantity
options
guest language summary
store language summary
critical warning
request status
confirm action
done action

Request Board must not show:

unrelated stores
unrelated merchants
billing
HQ tools
internal support notes
raw evidence packet unless support/HQ authorized

Core rule:

Request Board access must stay operational and narrow.

18\. Confirm Request Authority

Confirm Request is not payment confirmation.

Confirm Request means the store acknowledged the request in CatchMenu Stage 0C.

Allowed roles may include:

Store Manager
Store Staff Viewer if granted
Request Board Viewer if granted
Merchant Owner

Confirm Request must be:

store-scoped
request-scoped
version-checked
event-logged

Core rule:

Confirm Request acknowledges request handling.
It does not create POS, KDS, payment, or settlement authority.

19\. Mark Done Authority

Mark Done means the store has completed CatchMenu handling for that request.

Allowed roles may include:

Store Manager
Store Staff Viewer if granted
Request Board Viewer if granted
Merchant Owner

Mark Done must not be used to claim:

payment completed
POS order completed
KDS fulfilled
settlement completed
legal order finalization

Core rule:

Done is CatchMenu handling completion.
Done is not payment or POS completion.

20\. Menu Access

Menu access should be separated by action.

Possible permissions:

menu.read
menu.item.update
menu.price.update
menu.option.update
menu.ai\_draft.review
menu.publish
menu.critical\_warning.override

Read access may be broad for merchant users.

Edit and publish access should be more controlled.

Critical warning override must be high-risk.

Core rule:

Menu read, edit, review, and publish are different authorities.

21\. AI Menu Draft Access

AI Menu Draft access may be allowed to:

Merchant Owner
Menu Editor
Store Manager if granted
AI Menu Reviewer
HQ Admin

AI draft visibility should include:

extracted item name
extracted price
category candidate
option candidate
allergy/critical warning candidate
translation candidate
confidence indicator if available

AI draft must not silently become live menu without approval policy.

Core rule:

AI draft is draft.
Live menu requires approved authority.

22\. Trial Status Visibility

Merchant users may see trial status if allowed.

Visible states may include:

trial active
trial expiry date
usage summary
conversion prompt
service limitation notice

Merchant users should not see internal operator notes by default.

Core rule:

Merchant sees operational status.
Internal reasoning remains internal unless intentionally shown.

23\. Service Status Visibility

Merchant users may see service status.

Examples:

TRIAL\_ACTIVE
TRIAL\_EXPIRED
ACTIVE\_PAID
SUSPENDED
TERMINATION\_PENDING
TERMINATED
REACTIVATION\_PENDING

If service is suspended, Owner Console may show limited explanation and support contact.

Merchant users should not see sensitive internal audit or support notes.

24\. Usage Summary Access

Merchant users may see usage summary if allowed.

Examples:

scan count
menu open count
request count
show-to-staff count
confirmed request count
last activity date
trial usage level

Usage summary should be merchant/store-scoped.

Core rule:

Usage visibility helps adoption.
It must not expose other merchants.

25\. Support Entry Access

Merchant users may create or view support cases if allowed.

Merchant support access may include:

create support case
view own support cases
add merchant note
view status
view public support response

Merchant users should not see:

internal support notes by default
unmasked evidence
other merchant cases
Franchise OS support data

Core rule:

Merchant support view is customer-facing, not internal evidence view.

26\. Store-Level Access Boundary

Store-level access must not expand to account-level access silently.

Example:

Store Manager for store\_001

must not access:

store\_002
merchant account billing
all merchant users
other stores' request boards

unless explicitly scoped.

Core rule:

Store scope stays store scope.

27\. Multi-Store Merchant Access

A Merchant Account may have multiple stores.

Access options:

all stores under merchant account
selected stores only
single store only
feature-limited store access

Example:

Merchant Owner
\= all stores under account

Regional Store Manager
\= selected stores

Store Staff Viewer
\= one store request board

MVP may support selected store scope if multi-store is expected.

28\. Access During Trial

Trial merchant access may be limited.

Trial access may include:

Owner Console limited access
menu view
menu draft setup
request board if enabled
usage summary
support contact
trial status

Trial access may not include:

advanced analytics
paid plan features
API integrations
POS/KDS adapter
billing exports
full user delegation

Core rule:

Trial access is real access but may be limited by service plan and status.

29\. Access After Trial Expiry

After trial expiry, merchant access may become limited.

Allowed:

view trial expired notice
view limited usage summary
contact support
request conversion
download or view limited own data if policy allows

Restricted:

new request receiving
menu publishing
user invitation
advanced owner console features

Entry Media and admin access handling must follow service termination and Entry Media policies.

Core rule:

Trial expiry limits future use.
It does not erase history.

30\. Suspended Merchant Access

If merchant service is suspended, access should be limited.

Allowed:

view suspension notice
contact support
view limited account status
possibly resolve billing or admin issue

Restricted:

guest request receiving
request board operation
menu publish
new user invitation
Entry Media activation

Core rule:

Suspension blocks operational use while preserving account history.

31\. Terminated Merchant Access

If merchant service is terminated, access should be revoked or heavily limited according to policy.

Allowed if policy permits:

view termination notice
contact support
access limited historical documents if permitted

Not allowed:

operate request board
receive guest requests
publish menu
invite users
reactivate Entry Media without review

Core rule:

Termination ends operational access.
History remains preserved.

32\. Merchant Access Suspension

Merchant user access may be suspended.

Suspension reasons:

trial expired
merchant service suspended
merchant terminated
owner changed
staff left store
security concern
temporary access expired

Suspension must be audited.

Suspension must not delete historical user actions.

33\. Merchant Access Revocation

Merchant user access may be revoked when authority should be removed.

Examples:

employee left merchant
owner changed
merchant requested removal
HQ removed invalid access
security concern exists

Revocation must be audited.

Revocation must not delete request/action history.

34\. Owner Change

Merchant Owner may change.

Owner change requires controlled workflow.

Possible requirements:

existing owner approval
HQ approval
merchant verification
support evidence
reason
audit event
role revocation for old owner
role assignment for new owner

Core rule:

Merchant owner change is sensitive.
It must not be a simple self-service overwrite without guard.

35\. Staff Turnover

Store staff may change frequently.

Staff turnover workflow should allow safe revocation.

Examples:

revoke Store Staff Viewer
revoke Request Board Viewer
revoke Store Manager
rotate shared store device access if used

Shared accounts should be avoided where possible.

If shared store operation mode exists, it must be tightly store-scoped.

36\. Shared Store Device

Some stores may use a store tablet or shared device.

Shared device must not become broad merchant admin.

Allowed:

store-scoped request board
limited confirm/done
screen lock or quick recheck
no billing
no user management
no HQ access

Core rule:

Shared device may support operations.
Shared device must not hold broad owner authority.

37\. Merchant User Audit Events

Recommended audit events:

MERCHANT\_USER\_INVITED
MERCHANT\_USER\_ACCEPTED
MERCHANT\_USER\_ROLE\_GRANTED
MERCHANT\_USER\_ROLE\_REVOKED
MERCHANT\_USER\_SCOPE\_CHANGED
MERCHANT\_OWNER\_CHANGED
STORE\_MANAGER\_ASSIGNED
STORE\_STAFF\_ACCESS\_GRANTED
STORE\_STAFF\_ACCESS\_REVOKED
REQUEST\_BOARD\_ACCESS\_GRANTED
REQUEST\_CONFIRMED\_BY\_MERCHANT\_USER
REQUEST\_MARKED\_DONE\_BY\_MERCHANT\_USER
MENU\_UPDATED\_BY\_MERCHANT\_USER
MENU\_PUBLISH\_REQUESTED\_BY\_MERCHANT\_USER
MERCHANT\_ACCESS\_SUSPENDED
MERCHANT\_ACCESS\_REVOKED

Minimum audit fields:

event\_id
merchant\_account\_id
merchant\_store\_id
actor\_user\_id
target\_user\_id
role
scope
action
previous\_value
new\_value
reason
created\_at
trace\_id

38\. Merchant Access Failure Events

Invalid merchant access actions should create failure events.

Examples:

merchant user accesses another merchant
store user accesses another store
store staff attempts menu edit
request board viewer attempts billing access
suspended merchant user attempts request board access
terminated merchant attempts menu publish
inviter grants role outside own scope

Example failure codes:

WOH.IDENTITY.MERCHANT\_ACCESS.OTHER\_MERCHANT\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.OTHER\_STORE\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.STAFF\_MENU\_EDIT\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.REQUEST\_BOARD\_BILLING\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.SUSPENDED\_ACCESS\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.TERMINATED\_OPERATION\_DENIED
WOH.IDENTITY.MERCHANT\_ACCESS.INVITE\_SCOPE\_EXCEEDED

Failure/error naming is governed by:

docs/000080_Governance_CatchMenu_Failure_Error_Code_Naming_And_Diagnostic_Hierarchy.md

39\. Support Signals

Support signals may include:

MERCHANT\_OWNER\_MISSING
MERCHANT\_OWNER\_CHANGE\_REVIEW\_REQUIRED
STORE\_MANAGER\_MISSING
REQUEST\_BOARD\_ACCESS\_MISSING
MERCHANT\_USER\_SCOPE\_CONFLICT
SUSPENDED\_MERCHANT\_ACCESS\_ATTEMPT
TERMINATED\_MERCHANT\_ACCESS\_ATTEMPT
SHARED\_DEVICE\_REVIEW\_REQUIRED
STAFF\_ACCESS\_REVIEW\_OVERDUE

Support Signal alerts.

It does not grant or revoke access by itself.

40\. Relationship To Login Foundation

Merchant user login follows the common Login Foundation.

This document only defines merchant-side account and access application.

Session behavior may vary by session class:

MERCHANT\_ADMIN\_SESSION
STORE\_OPERATION\_SESSION
PUBLIC\_GUEST\_SESSION

Store operation exceptions must be explicit and must not expand authority.

41\. Relationship To Role Permission

This document applies Role Permission policy to merchant users.

Role Permission defines:

role
permission
scope
deny by default
least privilege
temporary permission
sensitive action

This document defines merchant-specific boundaries.

42\. Relationship To Owner Console

Owner Console must enforce this policy.

Owner Console should show:

only assigned merchant account
only assigned stores
only allowed menus
only allowed request boards
only allowed support cases
only allowed user management actions

Owner Console must not rely on UI hiding alone.

Server-side authorization is required.

43\. Relationship To Stage 0 Runtime

Stage 0 request board actions must respect merchant user access.

Examples:

request.confirm requires request.confirm permission
request.done requires request.done permission
request detail read requires store/request scope

Stage 0 must not treat store device or QR scan as admin authority.

44\. Relationship To AI Menu Intake

AI Menu Intake must respect merchant user access.

Examples:

menu image upload may be allowed to Merchant Owner or Menu Editor
AI draft review may be allowed to Menu Editor or Merchant Owner
high-risk publish may require stronger permission
critical warning override may require review

AI draft does not become live menu without approved authority.

45\. Relationship To Entry Media Inventory

Merchant users may see limited Entry Media status if policy allows.

Allowed examples:

Entry Plate installed
QR/NFC active
service inactive notice
support needed

Merchant users should not directly:

reassign Entry Media
deactivate mapping
mark lost/damaged/retired
approve reallocation

Those belong to internal inventory/HQ workflows.

46\. Relationship To Merchant Ops

Merchant Ops may manage merchant user access during onboarding, trial, conversion, suspension, or termination.

Merchant Ops actions must be scoped and audited.

Merchant Ops must not bypass owner verification or HQ rules for sensitive changes.

47\. Relationship To CatchMenu HQ

CatchMenu HQ may manage or override merchant access when authorized.

HQ override may be needed for:

merchant owner missing
owner dispute
security concern
merchant termination
trial abuse
wrong access assignment

HQ override must be audited and may require reauthentication.

48\. MVP Requirements

Merchant User and Store Access MVP should support at least:

Merchant Owner
Store Manager
Store Staff Viewer
merchant\_account scope
merchant\_store scope
request board access
confirm request permission
mark done permission
menu read permission
menu update permission optional
trial status visibility
service status visibility
support case creation
merchant user invitation limited
access suspension
access revocation
basic audit events
basic failure events

MVP may defer:

Billing Contact
advanced multi-store regional roles
complex owner transfer workflow
shared device advanced policy
fine-grained menu publish workflow
self-service role delegation
advanced staff access review automation

49\. Suggested Conceptual Entities

Suggested entities:

merchant\_user\_access
merchant\_store\_user\_access
merchant\_user\_invitations
merchant\_access\_status\_events
merchant\_user\_audit\_events
merchant\_user\_support\_signals

This document defines policy.

Actual schema may be designed later.

50\. Risk If Skipped

If merchant and store access is not defined, risks include:

merchant owner sees another merchant
store manager accesses all stores
store staff edits menu by mistake
request board device becomes admin console
trial merchant keeps operating after expiry
terminated merchant still receives requests
owner change becomes unsafe
support cannot explain access history

Therefore, merchant user and store access must be defined before Owner Console and request board implementation.

51\. Final Rule

Merchant access must be scoped, narrow, and auditable.

Final rule:

Merchant Owner is merchant-scoped.
Store Manager is store-scoped.
Store Staff Viewer is operational and narrow.
Request Board Viewer sees requests, not administration.
Menu Editor edits menu, not service authority.
Billing Contact sees billing, not operations.
Trial and service status affect access.
Suspension blocks future use without erasing history.
Every merchant access change must be auditable.
No merchant user may access another merchant by default.
