# 020310_Policy_User_Account_And_Login

Legacy path: $old.

1\. Purpose

This document defines the CatchMenu-specific user account and login application policy.

CatchMenu / Wait Order Handoff does not redefine the global Login Foundation.

CatchMenu follows the common Login Foundation for authentication security, duplicate login prevention, single active session policy, idle timeout, auto logout, session expiry, session revocation, device/session control, and reauthentication baseline.

This document defines how those foundation rules apply to CatchMenu user categories, merchant users, internal operators, public guest sessions, and system jobs.

Core purpose:

Apply the common Login Foundation to CatchMenu.
Define CatchMenu user account categories.
Define merchant user account boundary.
Define internal operator account boundary.
Define public guest session boundary.
Define system job identity boundary.
Separate login from authorization.
Prepare role, permission, scope, support access, and audit governance.
Prevent Franchise OS login or role from becoming CatchMenu authority by default.

Korean purpose:

공통 Login Foundation을 CatchMenu에 적용한다.
CatchMenu 사용자 계정 유형을 정의한다.
고객사 사용자 계정 경계를 정의한다.
내부 운영자 계정 경계를 정의한다.
공개 손님 세션 경계를 정의한다.
시스템 작업 identity 경계를 정의한다.
로그인과 권한을 분리한다.
역할, 권한, 범위, 지원 접근, 감사 거버넌스를 준비한다.
Franchise OS 로그인 또는 역할이 CatchMenu 권한으로 자동 전환되지 않게 한다.

2\. Foundation Compliance

CatchMenu follows the common Login Foundation.

This document does not redefine:

duplicate login prevention
single active session policy
idle timeout
auto logout
session expiry
session revocation
authentication security
passwordless login security
OTP or magic-link rules
device/session control
basic reauthentication rules
login failure handling baseline

Those belong to the shared Login Foundation.

CatchMenu only defines:

which user categories exist in CatchMenu
how merchant users relate to merchant accounts and stores
how internal operators relate to CatchMenu organization
how public guest sessions differ from user accounts
how system jobs are represented
how CatchMenu denies Franchise OS authority by default
how CatchMenu applies session strictness by actor type

Core rule:

CatchMenu consumes Login Foundation.
CatchMenu does not own global login rules.

Korean rule:

CatchMenu는 Login Foundation을 따른다.
CatchMenu는 전역 로그인 규칙을 소유하지 않는다.

3\. Scope

This document covers:

CatchMenu user account
CatchMenu login identity application
merchant user account
internal operator account
public guest session
system job identity
account type
account status
invitation
verification status
session class application
account suspension
account revocation
cross-business login boundary
Franchise OS login boundary

This document does not define:

global login foundation itself
full permission matrix
role hierarchy
support evidence masking detail
sensitive action reauthentication detail
Franchise OS HR
attendance
payroll
merchant billing engine
Stage 0 request state machine
Entry Media asset lifecycle

Related documents:

00400\_Identity\_Access\_Readme.md
00420\_Role\_Permission\_And\_Scope\_Policy.md
00430\_Merchant\_User\_And\_Store\_Access\_Policy.md
00440\_HQ\_Admin\_Access\_And\_Backup\_Policy.md
00450\_Support\_Access\_Masking\_And\_Evidence\_View\_Policy.md
00460\_Sensitive\_Action\_Reauthentication\_And\_Audit\_Policy.md
00470\_Cross\_Business\_Access\_And\_Federation\_Boundary\_Policy.md
00500\_organization\_core/

4\. Core Principle

Authentication and authorization must be separated.

Core rule:

Login proves who the user is.
Role and scope decide what the user may do.

Korean rule:

로그인은 사용자가 누구인지 확인한다.
역할과 범위는 사용자가 무엇을 할 수 있는지 결정한다.

A successful login does not automatically grant merchant, store, HQ, support, inventory, AI review, or cross-business authority.

5\. Login Foundation Relationship

Login Foundation defines global session and authentication rules.

Examples:

one account cannot remain active in multiple uncontrolled locations
new login may revoke or invalidate previous session
idle timeout may lock or logout the session
sensitive action may require reauthentication
expired session must not continue privileged action
revoked session must fail closed

CatchMenu applies these rules based on actor context.

Examples:

HQ Admin follows strict admin session policy.
Support Operator follows short, case-scoped session policy.
Merchant Owner follows merchant admin session policy.
Store Staff Viewer follows store operation session policy.
Public Guest follows guest session policy without admin authority.
System Job follows controlled machine identity policy.

Core rule:

Foundation defines session law.
CatchMenu defines actor application.

6\. Duplicate Login And Single Session Policy

CatchMenu follows the Login Foundation duplicate login and single active session policy.

Default behavior:

same account must not hold uncontrolled active sessions in multiple locations
new login may invalidate the previous active session
session conflict must fail safely
admin/support sessions should be stricter than guest sessions

CatchMenu-specific application:

HQ Admin
\= strict single active session

Support Operator
\= strict single active session or case-scoped session restriction

Merchant Owner
\= single active admin session unless foundation permits approved exception

Store Staff Viewer
\= controlled store operation session, subject to store-mode exception if approved

Public Guest
\= guest session; not treated as admin login

System Job
\= machine identity; no human duplicate login behavior

Core rule:

Duplicate login policy follows Login Foundation.
CatchMenu may only define approved actor-specific application.

7\. Idle Timeout And Auto Logout

CatchMenu follows Login Foundation idle timeout and auto logout rules.

Default:

admin and support surfaces should lock or logout quickly when idle
sensitive surfaces require shorter idle tolerance
guest sessions expire naturally
store operation surfaces may require a controlled operation-mode exception

Actor-level application:

HQ Admin
\= short idle timeout, lock or logout according to Login Foundation

Support Operator
\= short idle timeout, case-scoped session, masked view

Merchant Owner
\= merchant admin idle timeout, sensitive action reauthentication

Store Manager
\= store admin idle timeout, operational balance required

Store Staff Viewer / Request Board Viewer
\= store operation session may need controlled screen-lock or recheck behavior

Public Guest
\= guest session expiry; no admin authority

System Job
\= scheduled/process identity, no human idle session

Important note:

If Login Foundation sets 1-minute idle auto logout for admin/security surfaces,
CatchMenu must apply it to HQ/Admin/Support surfaces unless an approved exception exists.

Request Board or store operation surfaces may need a separate approved operation-mode rule
so that normal store work is not broken.

Core rule:

Idle timeout follows Login Foundation.
Operational exceptions must be explicit.

8\. Session Class

CatchMenu should classify sessions by risk and actor type.

Suggested session classes:

PUBLIC\_GUEST\_SESSION
STORE\_OPERATION\_SESSION
MERCHANT\_ADMIN\_SESSION
SUPPORT\_SESSION
HQ\_ADMIN\_SESSION
FIELD\_OPERATOR\_SESSION
INVENTORY\_OPERATOR\_SESSION
AI\_REVIEW\_SESSION
SYSTEM\_JOB\_SESSION

Session class helps apply Login Foundation rules.

Example:

HQ\_ADMIN\_SESSION
\= stricter timeout, single active session, sensitive action reauth

SUPPORT\_SESSION
\= short timeout, case scope, masking, audit

STORE\_OPERATION\_SESSION
\= store-scoped, operational convenience, approved timeout handling

PUBLIC\_GUEST\_SESSION
\= temporary guest flow, no admin authority

Core rule:

Session class applies foundation rules to business context.
Session class does not create permission by itself.

9\. User Account Definition

User Account represents a person or controlled non-human actor known to CatchMenu.

User Account may represent:

merchant owner
store manager
store staff viewer
request board viewer
menu editor
CatchMenu internal operator
support operator
field operator
inventory operator
AI menu reviewer
HQ admin
system job

Recommended fields:

user\_id
display\_name
primary\_email
primary\_phone
account\_type
account\_status
created\_at
created\_by
last\_login\_at

User account is not the same as role.

10\. Login Identity Definition

Login Identity represents the method or credential used to authenticate a user.

Login identity may include:

email login
phone login
passwordless login
magic link
OTP
social login
SSO identity later
system credential

Recommended fields:

login\_identity\_id
user\_id
identity\_provider
provider\_subject
login\_identifier
verified\_at
status
created\_at

A user may have multiple login identities if Login Foundation allows it.

Core rule:

One user may have multiple login identities.
One login identity must resolve to one controlled user account.

11\. Account Versus Role

Account and role must be separate.

Example:

user account \= owner@example.com
role \= Merchant Owner
scope \= merchant\_account\_001

Example:

user account \= support01@catchmenu
role \= Support Operator
scope \= assigned support cases

Core rule:

Account identity is not permission.
Permission comes from role and scope assignment.

12\. Account Types

Suggested account types:

PUBLIC\_GUEST\_SESSION
MERCHANT\_USER
INTERNAL\_OPERATOR
SYSTEM\_JOB
FEDERATED\_USER
TEST\_USER

Meaning:

PUBLIC\_GUEST\_SESSION
\= temporary guest actor for QR/NFC menu and request flow

MERCHANT\_USER
\= merchant-side user such as owner, manager, staff viewer

INTERNAL\_OPERATOR
\= CatchMenu internal operator or admin

SYSTEM\_JOB
\= automated process identity

FEDERATED\_USER
\= user authenticated through external or group identity later

TEST\_USER
\= controlled test account

13\. Account Status

Suggested account statuses:

INVITED
PENDING\_VERIFICATION
ACTIVE
SUSPENDED
REVOKED
DISABLED
ARCHIVED
DELETED\_PLACEHOLDER

Meaning:

INVITED
\= invitation sent but not accepted

PENDING\_VERIFICATION
\= account exists but verification is incomplete

ACTIVE
\= account can authenticate if login method is valid

SUSPENDED
\= future access blocked temporarily

REVOKED
\= access intentionally removed

DISABLED
\= account disabled by admin/security decision

ARCHIVED
\= account retained for history but not active

DELETED\_PLACEHOLDER
\= personal details minimized where legally allowed while audit references remain

Core rule:

Account status controls login eligibility.
Role status controls authority.

14\. Merchant User Account

Merchant user account belongs to a merchant account or merchant store scope.

Merchant users may include:

Merchant Owner
Store Manager
Store Staff Viewer
Request Board Viewer
Menu Editor
Billing Contact

Merchant user account should be linked to:

merchant\_account\_id
merchant\_store\_id optional
role assignment
access status
invitation source

Merchant user must not access another merchant unless explicitly scoped.

15\. Internal Operator Account

Internal operator account belongs to CatchMenu organization context.

Internal operator may include:

HQ Admin
HQ Manager
Support Operator
Field Operator
Inventory Operator
AI Menu Reviewer
Sales Operator
Finance Operator
Engineering Operator
Audit Reviewer

Internal operator account should be linked to:

company\_id
business\_unit\_id
team\_id
operator\_id
role assignment
access status
session\_class

Internal operator account must not receive cross-business authority by default.

16\. Public Guest Session

Public Guest Session is a temporary actor created by QR/NFC/Web guest flow.

Public guest may:

open guest menu
select language
view menu
select items
show selection to staff
send request if enabled
view own request status if session allows

Public guest must not:

create account authority
access Owner Console
access request board as staff
confirm request
mark done
edit menu
view support evidence
access HQ
access merchant internal data

Core rule:

Guest session is runtime convenience.
Guest session is not account authority.

17\. System Job Identity

System Job identity represents automated internal processes.

System jobs may:

aggregate scan usage
detect trial expiration
detect unconfirmed request warning
detect orphaned responsibility
generate support signal
run cleanup candidate check
run consistency check

System jobs must be scoped.

System jobs must not silently perform high-risk human authority actions unless explicitly designed.

Core rule:

System job may detect and signal.
Sensitive authority remains governed.

18\. Invitation

Invitation may be used to create merchant users or internal operators.

Invitation should include:

invitation\_id
target\_email\_or\_phone
invited\_by
invitation\_type
target\_role
target\_scope
expires\_at
accepted\_at
status

Invitation types:

MERCHANT\_OWNER\_INVITE
STORE\_MANAGER\_INVITE
STORE\_STAFF\_INVITE
INTERNAL\_OPERATOR\_INVITE
SUPPORT\_OPERATOR\_INVITE
AI\_REVIEWER\_INVITE

Invitation must not bypass role and scope assignment.

Core rule:

Invitation creates onboarding path.
Invitation does not create unlimited authority.

19\. Invitation Status

Suggested invitation statuses:

PENDING
ACCEPTED
EXPIRED
REVOKED
FAILED

Expired or revoked invitation must not be usable.

Accepted invitation should create or link user account and role-scope assignment.

20\. Account Verification

Account verification follows Login Foundation.

CatchMenu may apply stronger verification for higher-risk users.

Verification may include:

email verification
phone verification
OTP verification
admin approval
merchant owner approval
HQ approval

Merchant Owner and HQ Admin roles should require stronger verification than public guest sessions.

Core rule:

Higher-risk roles require stronger verification.
Verification baseline follows Login Foundation.

21\. Login Session

Login session represents authenticated use.

Session should include:

session\_id
user\_id
login\_identity\_id
session\_class
created\_at
expires\_at
last\_seen\_at
client\_context
risk\_context optional

Session should not store permanent authority.

Authority should be evaluated through role and scope.

Core rule:

Session proves current login.
Session does not replace role and scope check.

22\. Session Expiry

Session expiry follows Login Foundation.

CatchMenu applies session expiry by session class.

Examples:

HQ\_ADMIN\_SESSION
\= short expiry and strict idle timeout

SUPPORT\_SESSION
\= short expiry, case-scoped, masked

MERCHANT\_ADMIN\_SESSION
\= merchant admin expiry

STORE\_OPERATION\_SESSION
\= operational expiry or lock behavior per approved policy

PUBLIC\_GUEST\_SESSION
\= short-lived guest flow expiry

SYSTEM\_JOB\_SESSION
\= controlled process credential lifecycle

Sensitive action may require reauthentication even inside active session.

23\. Session Revocation

Session revocation follows Login Foundation.

Revocation may occur when:

new login invalidates previous session
account is suspended
role is revoked
temporary access expires
support session ends
security concern exists
device/session conflict is detected

Core rule:

Revoked session must fail closed.

24\. Login Failure

Login failure must be safely handled according to Login Foundation.

Failure examples:

unknown account
wrong credential
expired magic link
expired OTP
suspended account
revoked account
disabled login identity
unverified account
cross-business identity not linked
duplicate login conflict
session expired

Failure should avoid exposing unnecessary information.

Core rule:

Fail closed.
Reveal minimal account existence detail.

25\. Account Suspension

Account suspension blocks future login or access depending on policy.

Suspension reasons:

trial expired
merchant service suspended
merchant terminated
operator left team
temporary access expired
security concern
support session ended
role no longer needed

Suspension must not erase:

past audit events
past request handling
past support actions
past responsibility assignments

Core rule:

Suspend future access.
Preserve history.

26\. Account Revocation

Revocation removes account authority more strongly than suspension.

Use revocation when:

merchant user no longer valid
operator no longer belongs to CatchMenu
security concern exists
temporary admin access ended
support access should permanently close

Revocation must be audited.

Revocation should not delete audit trail.

27\. Account Archiving

Archiving preserves historical references while removing active usage.

Archive when:

merchant relationship ended
operator left company
test account retired
old login identity replaced

Archived account should not be able to login.

Historical references remain.

28\. Deletion And Placeholder

Hard deletion should be restricted.

If personal data deletion or minimization is required, use placeholder where possible while preserving operational audit references.

Possible placeholder fields:

deleted\_user\_ref
redacted\_display\_name
redacted\_contact
retained\_audit\_reference

Core rule:

Minimize personal data when required.
Do not destroy operational audit integrity.

29\. Login Boundary With Franchise OS

Franchise OS login does not grant CatchMenu access by default.

CatchMenu login does not grant Franchise OS access by default.

Possible future integration:

shared login
SSO
federated identity
group identity provider

Even with shared login:

role remains separate
scope remains separate
audit remains separate
support access remains separate
session class remains business-specific

Core rule:

Shared authentication is not shared authorization.

30\. Federated Identity Future

Federated Identity may later link CatchMenu user with a group-level identity.

Federated identity must define:

source identity provider
linked user account
business scope
role mapping
revocation method
audit event
session class mapping

Federation must not copy Franchise OS roles into CatchMenu automatically.

31\. Duplicate Account Handling

Duplicate accounts may occur when users sign up with different identifiers.

Examples:

same owner uses phone and email separately
same operator invited twice
merchant staff changes device
social login and email login mismatch

Duplicate merge must be controlled.

Merge should require:

identity verification
role-scope review
audit event
conflict review if both accounts have history

Core rule:

Do not merge accounts silently when authority or audit history exists.

32\. Test Accounts

Test accounts must be marked clearly.

Test account types:

INTERNAL\_TEST\_USER
DEMO\_MERCHANT\_USER
FIELD\_SAMPLE\_USER
QA\_OPERATOR

Test accounts must not access production merchant data unless explicitly authorized.

Core rule:

Test identity must not leak into production authority.

33\. Device Context

Device context follows Login Foundation where applicable.

Device context may be recorded for security and support.

Examples:

browser
mobile device
store tablet
owner phone
field operator phone
support console device
HQ admin device

Device context may support:

risk review
support session review
login anomaly detection
duplicate login conflict detection
request board usage context

MVP may record basic client context only.

34\. Store Operation Session Exception

Store operation surfaces may require approved handling different from normal admin screens.

Examples:

Request Board Viewer
Store Staff Viewer
store tablet request board
POS-less confirmation board

Potential issue:

A strict 1-minute full logout may interrupt store operations.

Allowed approach if approved:

screen lock instead of full logout
quick recheck instead of full login
store-scoped operation mode
short-lived renewal under controlled device
no access to admin settings
no access to billing or HQ data

Core rule:

Store operation exception must be explicit.
Exception must not expand authority.

35\. HQ And Support Strict Session

HQ and Support sessions should be strict.

Examples:

HQ Admin
\= short idle timeout, single active session, reauth for sensitive action

Support Operator
\= short idle timeout, case-scoped session, masked evidence, audit

Audit Reviewer
\= strict session, audit read scope, export control

Core rule:

Privileged surfaces must follow strict Login Foundation controls.

36\. Sensitive Action Reauthentication Reference

This document does not define all sensitive action reauthentication details.

Sensitive reauthentication is defined in:

00460\_Sensitive\_Action\_Reauthentication\_And\_Audit\_Policy.md

This document only states:

login session alone is not enough for sensitive action
reauthentication follows Login Foundation and CatchMenu sensitive action policy

Examples:

grant HQ admin role
unmask evidence
terminate merchant service
deactivate Entry Media mapping
approve cross-business link
override critical menu warning

37\. Login Audit Events

Recommended login audit events:

USER\_ACCOUNT\_CREATED
USER\_ACCOUNT\_INVITED
USER\_INVITATION\_ACCEPTED
LOGIN\_SUCCEEDED
LOGIN\_FAILED
LOGIN\_DUPLICATE\_SESSION\_REVOKED
LOGIN\_SESSION\_CONFLICT\_DENIED
LOGIN\_IDENTITY\_LINKED
LOGIN\_IDENTITY\_DISABLED
ACCOUNT\_VERIFIED
ACCOUNT\_SUSPENDED
ACCOUNT\_REVOKED
ACCOUNT\_ARCHIVED
ACCOUNT\_REACTIVATED
SESSION\_CREATED
SESSION\_EXPIRED
SESSION\_REVOKED
SESSION\_IDLE\_TIMEOUT
SESSION\_AUTO\_LOGOUT
STORE\_OPERATION\_SESSION\_LOCKED
STORE\_OPERATION\_SESSION\_RECHECKED

Minimum audit fields:

event\_id
user\_id
login\_identity\_id
session\_id
session\_class
actor\_type
actor\_id
action
reason
client\_context
created\_at
trace\_id

38\. Account Failure Events

Invalid account actions should create failure events.

Examples:

accept expired invitation
login suspended account
login revoked account
create merchant user without merchant scope
create operator without company context
merge accounts with conflicting authority
use Franchise OS identity without CatchMenu link
duplicate login conflict denied
session class mismatch

Example failure codes:

WOH.IDENTITY.ACCOUNT.INVITE.EXPIRED\_DENIED
WOH.IDENTITY.ACCOUNT.LOGIN.SUSPENDED\_DENIED
WOH.IDENTITY.ACCOUNT.LOGIN.REVOKED\_DENIED
WOH.IDENTITY.ACCOUNT.CREATE.MERCHANT\_SCOPE\_REQUIRED
WOH.IDENTITY.ACCOUNT.CREATE.COMPANY\_CONTEXT\_REQUIRED
WOH.IDENTITY.ACCOUNT.MERGE.CONFLICT\_REVIEW\_REQUIRED
WOH.IDENTITY.ACCOUNT.FEDERATION.CATCHMENU\_LINK\_REQUIRED
WOH.IDENTITY.SESSION.DUPLICATE\_LOGIN\_DENIED
WOH.IDENTITY.SESSION.CLASS\_MISMATCH\_DENIED

Failure/error naming is governed by:

docs/00000\_foundation/00080\_Failure\_Error\_Code\_Naming\_And\_Diagnostic\_Hierarchy.md

39\. Support Signals

Support signals may include:

ACCOUNT\_INVITATION\_EXPIRED
ACCOUNT\_VERIFICATION\_PENDING\_TOO\_LONG
MERCHANT\_OWNER\_ACCOUNT\_MISSING
STORE\_MANAGER\_ACCOUNT\_MISSING
SUPPORT\_OPERATOR\_ACCOUNT\_SUSPENDED
DUPLICATE\_ACCOUNT\_CANDIDATE
CROSS\_BUSINESS\_IDENTITY\_LINK\_MISSING
LOGIN\_FAILURE\_SPIKE
DUPLICATE\_LOGIN\_CONFLICT\_SPIKE
STORE\_OPERATION\_SESSION\_EXCEPTION\_REVIEW\_REQUIRED

Support Signal alerts.

It does not grant or remove access by itself.

40\. Relationship To Role Permission

User account and login policy does not define final permission.

After login, Role Permission policy determines:

role
permission
scope
action authority
sensitive action requirement

Core rule:

Authenticated user still needs authorization.

41\. Relationship To Merchant User Access

Merchant User Access depends on user account.

Merchant users must have:

user account
merchant account scope
store scope if needed
role assignment
access status
session class

Owner Console should evaluate both login and scope.

42\. Relationship To HQ Admin Access

HQ Admin Access depends on user account.

HQ admin must have:

internal operator account
company context
HQ role
admin scope
strict session class
reauthentication for sensitive action
audit event

A login alone is not HQ authority.

43\. Relationship To Support Access

Support Access depends on user account and support session.

Support access should be:

case-scoped
time-scoped
reason-scoped
masked by default
strict session controlled
audited

Support user account does not grant broad merchant visibility by itself.

44\. Relationship To Entry Media Inventory

Entry Media actions require authenticated user or system job.

Examples:

register Entry Plate
assign Entry Media
mark recovered
mark damaged
deactivate mapping
approve reallocation

Login identity must be combined with role and scope.

45\. Relationship To Stage Runtime

Stage runtime uses different identity levels.

Public guest:

guest session
no account required
no admin authority

Store staff:

login or controlled store operation session
request board scope

Support/HQ:

authenticated internal account
strict session class
case or admin scope

Core rule:

Runtime action must know actor type and session class.

46\. MVP Requirements

User Account and Login MVP should support at least:

user account
login identity
account type
account status
merchant user account
internal operator account
public guest session
system job identity
invitation
verification status
session class
single active session compliance through Login Foundation
idle timeout compliance through Login Foundation
login audit event
account suspension
account revocation
cross-business login denial by default

MVP may defer:

full SSO
group identity provider
enterprise directory
advanced MFA policy
complex account merge workflow
device trust scoring
risk engine
advanced store operation exception workflow

47\. Suggested Conceptual Entities

Suggested entities:

users
user\_profiles
login\_identities
user\_account\_status\_events
user\_invitations
login\_sessions
guest\_sessions
system\_job\_identities
session\_class\_policies
account\_audit\_events

This document defines policy.

Actual schema may be designed later.

48\. Risk If Skipped

If account and login boundary is skipped, risks include:

merchant owner cannot be distinguished from store staff
logged-in user receives authority accidentally
Franchise OS login leaks into CatchMenu access
support users see too much
guest session becomes admin-like
account suspension deletes history
duplicate accounts corrupt audit trail
store operation screen breaks under wrong session policy
admin session remains open too long
duplicate login creates uncontrolled access

Therefore, user account and login application must be defined before role and permission policy.

49\. Final Rule

CatchMenu user account and login must follow the common Login Foundation and apply it to CatchMenu actor contexts.

Final rule:

Follow Login Foundation.
Do not redefine global login rules.
Create CatchMenu user account.
Link login identity.
Classify session by actor type.
Authenticate the actor.
Authorize through role and scope.
Separate CatchMenu login from Franchise OS authority.
Allow guest sessions without admin power.
Use system job identity for automation.
Suspend without erasing history.
Audit account, login, and session events.
